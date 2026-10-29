# pml-graph — queryable code graph for PML

Builds a structural graph of AVEVA PML sources (PML 1 and PML 2) and answers
"who calls this", "what does this form wire up", "which code touches this CDB
element" without re-reading the 6,075-file PMLLIB snapshot every time.

Zero new dependencies: it reuses the tree-sitter CLI and the compiled PML grammar
that already ship in [`../pml-parse/bin/`](../pml-parse/bin/). No Node.js, no
compiler, no network, no Graphviz.

## Contents

| File | What |
| --- | --- |
| `queries/pml-graph.scm` | the one tree-sitter query the builder runs (capture names are the contract) |
| `build-pml-graph.ps1` | build the graph: enumerate → query → normalise → resolve → write |
| `query-graph.ps1` | six query modes over the built graph |
| `tests/run-tests.ps1` | fixture-based regression test (38 assertions, incl. determinism) |
| `../../graph/pml-graph.tsv.gz` | the generated graph for the bundled PMLLIB (committed) |
| `../../graph/pml-graph.meta.json` | counts, resolution rates, unresolved names, source fingerprint |

## Quick start

```powershell
# answer a question (reads the committed graph, ~12 s under PS 5.1)
.\query-graph.ps1 -WhoCalls '!!kRestoreUnits'
.\query-graph.ps1 -CallbacksInto .setSize
.\query-graph.ps1 -FilesForDbPath /TT/AssemblyADP
.\query-graph.ps1 -CallsOf 'aba/Forms/abaarea.pmlfrm#abaarea.setsize'
.\query-graph.ps1 -Module aba
.\query-graph.ps1 -Find 'hull'
```

## Lookup contract (-WhoCalls / -CallbacksInto / -CallsOf, since 2026-10-29)

- A **full node id** (containing `#` or `::`) matches the whole id in all three
  modes: exact first, then case-insensitive (ids embed path segments like
  `Forms/`, and PML names are case-insensitive). A wrong id is a loud error
  pointing at `-Find` — ids are never truncated to a name prefix any more (the
  pre-fix regex `^(?:!!|!|\.)?([A-Za-z0-9_]+)` silently turned
  `x.pmlobj#obj.method` into a lookup for `x`).
- A **qualified name** (`!!obj.method`, `.method`) resolves on the LAST dot segment
  — the segment a callback string like `|!this.functions.includeFields()|` actually
  drives. The builder keys chained receivers on the member (`functions`), so query
  chains by that member name (`-CallbacksInto 'spooler.functions'` finds the four
  toolbar buttons in `spooler.pmlfrm`).
- A **bare name** merges every node sharing it (overloads `~2` included); when you
  need one node's edges precisely, `-Find` the id first and pass the id.

# rebuild after the sources change (~4.5 min for the full PMLLIB)
.\build-pml-graph.ps1

# CI / staleness check: exit 2 when the committed graph no longer matches
.\build-pml-graph.ps1 -Check

# the tool's own test suite
.\tests\run-tests.ps1
```

If script execution is blocked:
`powershell -NoProfile -ExecutionPolicy Bypass -File .\build-pml-graph.ps1`

## What the graph contains

Nodes (69,458 for the bundled snapshot):

| kind | count | id shape | example |
| --- | ---: | --- | --- |
| `function` | 3,691 | `<file>#<name>` | `mds/common/functions/krestoreunits.pmlfnc#krestoreunits` |
| `object` | 988 | `<file>#<name>` | `aba/Objects/abadefaults.pmlobj#abadefaults` |
| `form` | 1,361 | `<file>#<name>` | `aba/Forms/abaarea.pmlfrm#abaarea` |
| `method` | 25,789 | `<container>.<name>` | `aba/Forms/abaarea.pmlfrm#abaarea.setsize` |
| `member` | 18,579 | `<container>.<name>` | `aba/Objects/abadefaults.pmlobj#abadefaults.template` |
| `gadget` | 19,050 | `<owner>::<name>` | `aba/Forms/abaarea.pmlfrm#abaarea::t1` |
| `label` | 0 | `<file>@label:<name>` | PML 1 `$LABEL` (none in the shipped snapshot) |

Overloaded methods (1,562 `(file, method)` pairs repeat, because PML overloads by
parameter list) get a `~2`, `~3` … suffix and an `overload` flag.

Edges (218,161 for the bundled snapshot) — every edge carries its call site, so a
helper invoked twice from one routine stays two sites:

| type | what it links |
| --- | --- |
| `calls_global` | caller → `!!function` / `!!object` / `!!form`, resolved to the declaring file |
| `calls_unresolved` | caller → `unresolved:<name>` (a `!!` target with no file and no declaration) |
| `calls_builtin` | caller → `builtin:<name>` (`STRING()`, `array()`, `undefined()`, …) |
| `callback_invokes` | form gadget → method, global function, or the gadget it reads |
| `form_hook` | form → method named in `init` / `okcall` / `cancelcall` / `applycall` |
| `reads_global` / `writes_global` | caller → `global:<obj>.<member>` (`!!ce`, `!!error`, `!pml`, …) |
| `touches_cdbpath` | caller → `cdb:/SITE/AREA/...` element path |
| `instantiates` | caller → `type:<NAME>` from `object NAME(...)` |
| `imports_dll` / `uses_namespace` | caller → `dll:<name>` / `ns:<name>` |
| `member_of` | object or form → its declared member |
| `goto_label` | caller → `<file>@label:<name>` from PML 1 `$GOTO` |

## File format

`graph/pml-graph.tsv.gz` is UTF-8 (no BOM), tab separated, one record per line,
sorted ordinally so builds are byte-identical:

```
N <kind> <id> <file> <line> <name> <flags>
E <type> <src> <dst> <file> <line> <detail>
```

`file` is relative to `PMLLIB/`, `line` is 1-based, and `detail` keeps the source
text (`!!kRestoreUnits`, `|!this.setSize(...)|`, `/TT/...`) so hits can be read
without opening the file. Node lines come first, then edges.

The generated text is ~12.8 MB and compresses to **2.9 MB** gzip; scanning it
takes under a second, which is why the query tool streams lines and only formats
the matches it needs.

## Measured coverage (bundled PMLLIB, 6,075 files)

| metric | value |
| --- | ---: |
| global calls resolved to a declaring file | **99.76 %** (18,012 resolved / 52 unresolved) |
| callback call targets resolved | **96.12 %** (15,082 calls, 585 unresolved) |
| files containing `(ERROR)` recovery nodes | 354 (matches the parser's own 94.02 % baseline) |
| build time, full corpus | ~4.5 min (query ~2 min, rest PowerShell post-processing) |

The 38 unresolved global names are genuinely absent from the snapshot — mostly
runtime-provided helpers (`warning`, `error`, `kLoadobject`, `mdsRecognizeHangerif`).
They are listed verbatim in `pml-graph.meta.json → unresolvedGlobals`, and they
are kept as `calls_unresolved` edges rather than dropped.

The 585 unresolved callbacks fall into two groups, both real:

1. **Runtime/built-in form methods** — `.hide()`, `.cancel()`, `.show()` called on
   `!this` where the form never declares them (the runtime supplies them).
2. **Gadget and member references to dynamically created controls** — e.g.
   `!this.tlength.val` where `tlength` is created at run time and never declared
   in `setup form` (141 occurrences in `mds/design/forms`).

Neither is a graph bug; raising the rate would need type/flow analysis that
tree-sitter alone cannot provide.

## Deliberate scope limits

- **Syntax-level graph, not a type-resolved one.** `!!name` resolves by file
  basename (the PMLLIB naming contract), not by a symbol table, so an alias
  declared under a different basename is linked through a name alias rather than
  inferred. 22 files declare a name that differs from their basename (e.g.
  `common/functions/complotform.pmlfnc` declares `!!comPropPlot`); both the
  basename and the declared name resolve to the same node.
- **Method calls on local variables are not tracked.** `!obj.doThing()` where
  `!obj` is a local would need type inference; 13,543 distinct local receiver
  names exist in the snapshot and the capture alone triples the graph size. Calls
  on `!this` and on `!!global` receivers *are* tracked.
- **Duplicated global function names** (6 names, e.g. `compropplot`,
  `mdscollectall`) resolve to every candidate; those edges are tagged
  `[ambiguous]` in the detail column.
- **No PML 1 macro flow.** `$GOTO`/`$LABEL` support exists but the shipped
  snapshot contains zero of them; the 4 `.pmlmac`/`.mac` files are otherwise
  captured like any other source.
- **`$!<...>` dynamic evaluation** is not resolved — such sites land in
  `calls_unresolved` (e.g. `!!$!<dbType>CE`).

## Why not an existing graph project?

- **ast-grep** can load `pml.dll` as a custom language (`customLanguages` in
  `sgconfig.yml`), but that needs a second binary plus `--custom-languages
  allow/trust`, and its rule engine duplicates what `tree-sitter query` already
  gives us here. It also does not build a graph.
- **code-graph-rag / Joern / SCIP** have no PML front end, and there is no public
  `tree-sitter-pml` package (`npm view tree-sitter-pml` → 404), so the bundled
  grammar is the only PML parser available.
- **`tree-sitter parse --dot`** is not an option: the CLI shells out to Graphviz,
  which is not installed, and it panics rather than degrading. `tree-sitter tags`
  rejects `-l`/`--lang-name`, so it cannot be pointed at `pml.dll` at all.

## Regenerating

`build-pml-graph.ps1` writes `graph/pml-graph.tsv.gz` and
`graph/pml-graph.meta.json`. Both are committed so the graph is usable offline
without a build step. If you prefer to keep build artifacts out of git, delete
them and add `graph/` to `.gitignore` — the tooling needs no other change.

After any PMLLIB change, run `.\build-pml-graph.ps1` and commit both files; the
`sourceHash` in the metadata covers (path, size) for every scanned file, so
`-Check` catches a stale graph even when the node/edge counts happen to match.

## Implementation notes (things that cost a debugging session)

- **`cmd /c` redirection is mandatory.** A PowerShell `>` on 5.1 writes UTF-16LE;
  `cmd /c` preserves the CLI's UTF-8 bytes, so non-ASCII callback text survives.
- **Never enumerate a hashtable's `.Keys`.** PML has methods named `keys` and
  `count`, so `$hash.Keys` resolves to that entry's *value* instead of the key
  collection. All tables that hold PML names are arrays or accessed through
  `ContainsKey`.
- **A function returning `List[string]` unrolls into the pipeline.** `$x[0]` then
  indexes the first string and yields a character. `Resolve-Global` returns
  `,$array` for exactly this reason.
- **Capture names, not pattern indices, drive dispatch.** Appending a pattern to
  the `.scm` cannot shift behaviour; renaming a capture is a breaking change and
  needs a `GRAPH_SCHEMA` bump.
- **`(ERROR)` captures are the authoritative syntax signal.** The parser README
  documents that the CLI's quiet `--stat` mode can report success on a recovery
  tree, so the builder counts `@parse.error` nodes instead (354 files here).
- **The CLI drops a stub `log.html` into the CWD** while initialising its config;
  the builder removes it in a `finally` block.
