# pml-parse — offline PML syntax checker

Self-contained tree-sitter parser for AVEVA PML (PML 1 + PML 2, all
extensions: `.pml .pmlobj .pmlfnc .pmlfrm .pmlmac .mac`). Zero dependencies:
no node, no compiler, no network. Built from the `tree-sitter-pml` grammar.

## Contents

| File | What |
| --- | --- |
| `bin/tree-sitter.exe` | tree-sitter 0.27.1 CLI (standalone, no node needed when used with `-l`) |
| `bin/pml.dll` | compiled PML grammar. Baseline: **94.02%** clean parse on the bundled 6,075-file PMLLIB, 22/22 unit corpus (previous 93.61% build kept as `pml-93.61.dll.bak`) |
| `parse-pml.ps1` | check one file or a folder; prints per-file ERROR locations + summary; exit 0 clean / 2 findings |
| `bench-pmllib.ps1` | re-run the full-coverage benchmark against `../../PMLLIB` (parser sanity gate) |

## Usage

```powershell
# single file — verdict + failure location
.\parse-pml.ps1 MyScript.pmlfnc

# single file — full syntax tree (for structure questions)
.\parse-pml.ps1 MyScript.pmlfnc -Tree

# whole project folder, write failure details to a file
.\parse-pml.ps1 C:\work\myapp -Recurse -Out parse-report.txt

# verify the bundled parser still matches its baseline (≈ 94.02%)
.\bench-pmllib.ps1
```

If script execution is blocked:
`powershell -NoProfile -ExecutionPolicy Bypass -File .\parse-pml.ps1 <args>`

## How to read the results (IMPORTANT)

A `FAIL` line marks a construct the grammar could not place in the tree; the
file still yields a usable tree around the ERROR node. **A FAIL is a
"review this construct" signal, not proof AVEVA's compiler rejects it.**
Baseline failures concentrate in known pathological delivered code
(unterminated quotes glued to code, `*/` comment tails, `$!<arr[$!i].x>`
eval-with-subscript, `=0/0` placeholder lines). For new generated code,
0 FAIL is the quality gate; any FAIL means look at the reported line.

## Known false positives — RESOLVED 2026-10-27 (grammar fixes)

Two families that used to FAIL the gate while being perfectly legal product
syntax are now fixed in `pml.dll` (tree-sitter-pml grammar; regression tests
`Real-world: numericinput gadget clauses` and `Real-world: print statement
dollar P free text`). **Do not "work around" these patterns in new code —
they parse clean now:**

| Construct (product-legal) | Old verdict | Fix in grammar |
| --- | --- | --- |
| `$P` free text ending in stray dots: `$P Total 5.`, `$P ...values.`, `$P Done...` | FAIL on the trailing dot | `print_statement`: after `$P`+whitespace the whole rest of the line is literal text (matching the command processor's semantics; `$!x` expands at execution, not parse time) |
| `numericinput .g 'Label' tagwidth N anchor ... at ... callback '..' range a b ndp 0 width N` | FAIL once a label string or most clauses were present (keyword was simply missing from `ui_control_type`) | `numericinput` added to the control keyword table; clause slots reuse the existing generic clause machinery |

Measured on this skill's own PMLLIB snapshot (set-diff of per-file FAIL
lists, old vs new DLL): **25 files rescued (3 numericinput + 22 with `$P`
lines), 0 regressions; 388 FAIL -> 363 FAIL = 94.02%**. Verified delivered witnesses that
now parse 100% OK: `accommodation/forms/slopeangle.pmlfrm`,
`assembly/data/assembly_library_upgrade.mac` (line 10 `$P ... starts...`),
`design/forms/cblmtrl.pmlfrm`, `hulldesign/functions/hullCheckManpkg.pmlfnc`
(line 49 `$p Working....`). Note the old root-cause folklore was wrong in
detail: the `$P` trigger was **any stray dot** (`$P a.` and `$P 5.` failed,
`$P E 0.5` always parsed fine — decimals were never a problem).

## Verdict caveat: false OK from the CLI quiet channel

`parse-pml.ps1`/`bench-pmllib.ps1` trust the tree-sitter CLI exit code
(`-q --stat`). On some recovery trees the CLI reports `successful parses`
even though the printed tree contains ERROR nodes (reproduced: pre-fix
`design/forms/cblmtrl.pmlfrm` → exit 0, but tree had 3 ERROR nodes; a
401-line prefix of the same file fails, a 1066-line prefix reports OK).
When auditing pre-fix parser output, double-check suspects via the tree
channel: `parse-pml.ps1 <file> -Tree` and grep for `(ERROR`. Post-fix this
rarely bites (the main producers of those recovery trees now parse), but the
divergence is a CLI-level behaviour, not something the grammar can remove.

## Still-failing taxonomy (review, usually product-legal but pathological)

The remaining 363 baseline FAILs concentrate in: `*/` comment tails,
unterminated quotes glued to code, eval-with-subscript `$!<arr[$!i].x>`,
`=0/0` placeholders, word-led multi-word expressions (`POINTR of RPATH 1 of
owner of $!a[1]`, `e $!w[1] n $!w[2] u $!w[3] wrt world`). Arbitration before
"fixing" generated code to appease the gate: grep the same construct in
[PMLLIB/](../../PMLLIB/) — a delivered witness means false positive, keep
the code.

Raw CLI (identical to what the scripts wrap):

```powershell
.\bin\tree-sitter.exe parse -l .\bin\pml.dll --lang-name pml -- MyScript.pmlfnc          # tree
.\bin\tree-sitter.exe parse -l .\bin\pml.dll --lang-name pml -q --stat --paths list.txt  # batch
```
