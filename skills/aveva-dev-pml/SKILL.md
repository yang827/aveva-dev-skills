---
name: aveva-dev-pml
description: "Knowledge base for AVEVA PML secondary development (part of the aveva-dev-skills suite). Covers PML 1 and PML 2 macros, functions, forms, gadgets, Event Driven Graphics, Marine Drafting automation, and DABACON database queries."
metadata:
  suite: aveva-dev-skills
  version: "0.4.0"
---

<!-- argument-hint: [topic, framework name, or chapter number] -->

# AVEVA PML & Marine Customisation Guide
**Source**: AVEVA Official Documentation (~858 pages) | **Maintained by**: aveva-dev-skills | **Chapters**: 20

## How to Use This Skill

- **Without arguments** — loads the core PML frameworks, syntax rules, and mental models below.
- **With a topic** — ask about `forms`, `gadgets`, `collections`, `edg`, `marapi`, or `primitives`; I will navigate to and load the relevant chapter.
- **With a chapter** — ask for `ch01` through `ch20` to load that specific chapter directly.
- **Browse** — ask for the chapter index or consult supporting documents.

When you ask about a topic not covered in the Core Frameworks below, I will read the corresponding chapter file before answering.

---

## Core Frameworks & Mental Models

### 1. Dual-Architecture Paradigm (PML 1 vs PML 2)
AVEVA's scripting environment comprises two distinct tiers:
- **PML 1 (Command Macros - `.mac`)**: Procedural command-stream replays using positional parameters (`$1`–`$9`), parameter defaults (`$d1=`), full-line comments (`$*`), and unconditional jumps (`$GOTO`, `$LABEL`). Variables are expanded using the dollar prefix (`$!var`).
- **PML 2 (Object-Oriented Architecture)**: Fully structured, object-oriented runtime introducing standalone functions (`.pmlfnc`), User-Defined Objects (`.pmlobj`), and GUI forms (`.pmlfrm`). Evaluates native typed expressions (`!var`) without `$`, supports method chaining (`!obj.method1().method2()`), and provides lexical variable scope.
- **Comment Syntax (MANDATORY)**: `--` must be the **first token on its line** (leading indentation allowed). Trailing/inline comments after a statement (`!a = 1 -- note`) are **invalid syntax** and appear nowhere in the delivered PMLLIB sources. Put explanatory notes on their own `--` line **above** the statement they describe. PML 1 macros comment with `$*`, also full-line only.
- **Rule of Thumb**: Never mix PML 1 `$GOTO` inside PML 2 functions or methods. Reserve `.mac` files for linear command scripts; use `.pmlfnc`, `.pmlobj`, and `.pmlfrm` for applications.

### 2. Runtime Resolution & The PMLLIB Contract
PML 2 files are dynamically loaded on-demand across directories listed in the operating system environment variable `PMLLIB`:
- **File Naming Rule**: Filenames must be **strictly lowercase** and match the declared object/function/form name exactly:
  - Function `!!myFunction` -> `myfunction.pmlfnc`
  - Object `myObject` -> `myobject.pmlobj`
  - Form `!!myForm` -> `myform.pmlfrm`
- **Rehash Command**: The command processor builds an in-memory symbol table on startup. Whenever files in `PMLLIB` are added, modified, or renamed, developers must execute:
  ```pml
  pml rehash all
  ```
- **Form Hot-Reload**: Active forms can be recompiled in memory without restarting AVEVA using:
  ```pml
  pml reload form !!formname
  ```

### 2b. Bundled Delivered Source (PMLLIB snapshot inside this skill)

A snapshot of the AVEVA-delivered PML source tree ships with this skill at [PMLLIB/](PMLLIB/) (6075 source files: 1380 `.pmlfrm`, 3703 `.pmlfnc`, 988 `.pmlobj`; version.dat + pml.index included). This is real, production-grade official code — the authoritative reference for verified syntax.

- **On AVEVA installs**, runtime PMLLIB directories come from the instance environment (set by `evars.bat`); read env values in PML with `var !x EVAR <name>` or `!!evar()` / `!!evarSplit()`. The bundled snapshot works offline: it is plain text under this skill folder, no environment lookup needed.
- **Lookup order when official usage is uncertain**: (1) [references/pmllib-idioms.md](references/pmllib-idioms.md) — verified idioms with citations; (2) grep [references/pmllib-index.md](references/pmllib-index.md) (module, gadget, flag, description) to locate candidate files; (3) open the real source under [PMLLIB/](PMLLIB/) via the index path.
- **Priority**: module order of interest is `common` → `design` → `draft`/`marinedrafting`/`isodraft` → `admin`/`global` → others; treat `mds` (scantling formula library, 2504 files) as low priority unless the task is MDS-specific.
- **Copyright**: delivered AVEVA source — cite paths in answers, do not bulk-copy large extracts into user deliverables.

### 2c. Offline Syntax Gate — Bundled PML Parser (MANDATORY after code generation)

A standalone PML syntax checker ships at [tools/pml-parse/](tools/pml-parse/) (tree-sitter CLI + compiled `pml.dll` + PowerShell wrappers; no node, no compiler, no network). It parses PML 1 and PML 2 sources; grammar baseline: **94.02%** clean parse on the 6,075-file bundled PMLLIB with 22/22 unit tests.

- **After writing or editing any `.pmlfnc` / `.pmlobj` / `.pmlfrm` / `.mac` file**, run `tools/pml-parse/parse-pml.ps1 <file-or-folder> [-Recurse]`. New generated code must reach **0 FAIL** before delivery; the report prints `file -> ERROR [line, col]` for each finding.
- **A FAIL is a review signal, not a compiler verdict** — delivered PMLLIB itself has 363 known-failing files (unterminated quotes glued to code, `*/` tails, eval-with-subscript, `=0/0` placeholders; taxonomy in the tool README). Trees stay usable around ERROR nodes, but generated code should never join that set.
- **Do not "avoid" `$P` trailing dots or `numericinput` labels** — those two false-positive families were fixed in the 2026-10-27 grammar build (25 delivered files rescued, 0 regressions); write them freely, see the tool README "Known false positives — RESOLVED".
- **Tree inspection** (structure questions, e.g. verifying a form parses as one `form_definition`): `parse-pml.ps1 <file> -Tree`. Also the double-check channel when a verdict looks too good: the CLI quiet mode can under-report (false OK) on some recovery trees — grep the `-Tree` output for `(ERROR`.
- **Parser sanity gate** after any tooling change: `tools/pml-parse/bench-pmllib.ps1` must stay ≈ 94.02% on the bundled PMLLIB.

### 3. Copies and References Framework (Value Types vs Reference Types)
- **Value Types (`REAL`, `STRING`, `BOOLEAN`)**: Assignment (`!a = !b`) copies data by value.
- **Reference Types (`ARRAY`, `FORM`, Gadgets, `DBREF`, UDOs)**: Assignment assigns a pointer/reference. Mutating `!a` mutates `!b`!
- **Deep Duplication**: Always use `!copy = !original.clone()` when a local, independent copy of an array or object is required.

### 4. DABACON Database Navigation & Transaction Control
DABACON is AVEVA's hierarchical, transactional engineering database:
- **Direct Reference (`DBREF`)**: Pointers to records (e.g. `!!CE` for current element). Built-in methods include `.name`, `.type`, `.owner`, `.mcount()`, `.attribute('NAME')`, `.badRef()`, and `.unset()`.
- **Transaction Rollback (`MARK`, `UNDO`, `REDO`)**: Save checkpoints using `MARK 'NAME'` and revert partial failures with `UNDO`.
- **PML 2 `COLLECTION` Engine**: High-performance query pipeline:
  ```pml
  !coll = object COLLECTION()
  !coll.type('NOZZ')
  !coll.scope(!parentRef)
  !expr = object EXPRESSION(|BORE ge 100|)
  !coll.filter(!expr)
  -- Returns ARRAY of DBREF
  !results = !coll.results()
  ```

### 5. Deterministic Control Flow (No While Loops)
AVEVA PML provides structured loops with explicit termination:
- **Counted Loop**: `DO !i FROM 1 TO 10 [BY 2] ... ENDDO`
- **Array Values**: `DO !item VALUES !array ... ENDDO`
- **Array Indices**: `DO !idx INDEX !array ... ENDDO`
- **Condition-Driven Loop**: Open `DO` loop terminated via `BREAK IF (!condition)`:
  ```pml
  DO
    !count = !count + 1
    BREAK IF (!condition OR !count GT 1000)
    -- loop body
  ENDDO
  ```
- **Rule of Thumb**: **There is NO `while` or `do while` statement in AVEVA PML!** Conditional loops must use `DO` with `BREAK IF`.

### 6. Modern Event Driven Graphics (EDG)
- Modern 3D canvas interaction (SCRM Chapter 3) is **asynchronous and non-blocking**, managed via `!!edgCntrl`.
- Tools register an `edgPacket` hosting an `edgPickPacket` with prompt sequences and filter rules (`edgPick`).
- Canvas hit payloads are delivered directly to `.action` callbacks, leaving all open forms fully responsive.
- Legacy `ID @` commands are superseded and should only be used in quick command-line macros.

### 7. Marine Drafting Single-Drawing Contract & MarAPI Dialogs
- Marine Drafting automation (TM-2401) requires `import 'marapi'` followed **immediately after** by `handle (1000, 0) endhandle` — the `import` stays OUTSIDE the block (see Core Framework 9).
- Strict Single Document Interface (SDI): Only one drawing sheet can be active at any time. Always test `if (!marDraft.DwgCurrent())` and close (`!marDraft.DwgClose()`) before creating or opening a new drawing.
- Interactive dialogs use `!marUi.AnswerReqPML('Title', 'Prompt')` with return codes checked against `!marUtil.YesPML()`, `!marUtil.NoPML()`, `!marUtil.CancelPML()`.

### 8. ANY Type — Mandatory Syntax Constraint
`ANY` in PML is a **signature-position type specifier only**:
- **Allowed**: formal parameter declarations (`define function !!f(!v is ANY)`, `define method .m(!v is ANY)`); function return type (`is ANY`) only with concrete evidence the signature supports it.
- **Forbidden**: normal variable declarations (`!value is ANY` is invalid), treating ANY as a universal type at arbitrary positions, and equating it with C# `object`, generic `T`, or dynamic typing. A variable's type is fixed at creation and never changes during its lifetime.
- **Review rule**: when auditing generated code, judge every `is ANY` by its **syntactic position** — parameter/return declarations are legal and must not be flagged; only a normal-variable declaration is a defect. Never flag ANY on a keyword hit alone.
- **Rule of Thumb**: to accept mixed input types, use an ANY formal parameter and branch on the actual type inside — never declare an ANY variable. Full rules and examples: [ch05](chapters/ch05-pml2-functions-methods.md) "ANY Type Usage Restrictions (MANDATORY)".

### 9. HANDLE is a POST-ATTACHED Error Trap — NOT a try/catch Block
`HANDLE ... ENDHANDLE` is **not** a block that encloses risky code. PML has no `try`/`catch`; do not read or write `handle` as if it were one.
- **Mandatory order**: the risky command comes FIRST, on its own line; the `handle` clause follows IMMEDIATELY after it, with NO intervening statements. Everything between `handle` and `endhandle` is the **recovery code executed only when the preceding command fails**.
- **Correct**:
  ```pml
  -- risky command FIRST, outside the trap
  !modelNo = !elem.:SPEC
  handle any
    -- recovery: runs only if the line above failed
    !modelNo = ''
  endhandle
  ```
- **Wrong (a frequent generation error)** — do NOT move the risky statement inside the trap:
  ```pml
  handle any
    -- WRONG: this is recovery code, not guarded code
    !modelNo = !elem.:SPEC
  endhandle
  ```
  Wrapping the assignment inside `handle any` means it only executes on error paths (or is dead code), and the original error is never trapped.
- **Rule of Thumb**: never describe or generate this as "wrap the command in handle" — the `handle` clause wraps nothing; it **trails** the command it guards, like a postfix error handler. Full syntax: [ch04](chapters/ch04-error-handling-debugging.md).

### 10. There Is No `null` Keyword and No `.null()` Method — Empty Returns Are Typed
PML has **no `null`/`nil`/`None` literal, and no `.null()` method on any type** (`STRING` included). `return null` is a hard compile error (`CP: Syntax error` at the `^^NULL` token); `!x.null()` compiles but fails at runtime with `Method <STRING>.NULL() not found`. The words "return null" appear in delivered PMLLIB code **only inside English `--` comments** (e.g. `MdsGetAlias.pmlfnc`, whose real statement is `return ''`) — never copy syntax from comment prose.
- **Correct "empty" return by declared type**: `is STRING` → `return ''` (or `return object STRING()` for unset); `is DBREF` → `return object DBREF()`; `is ARRAY` → `return object ARRAY()`; `is REAL` → `object REAL()` / a documented numeric sentinel.
- **Call-site test**: `!ret.unset()` (unassigned object/DBREF/ARRAY), `!s.eq('')` (blank STRING), `undefined(!x)` (never defined), `!ref.badRef()` (dead pointer) — never `!x.null()` and never `!ret eq null`.
- **Review rule**: any `null`/`NULL`/`nil`/`None` in executable tokens (outside comments) — literal, `.null()` call, or `eq null` comparison — is a defect; replace with the typed empty idiom. Full tables and citations: [ch05](chapters/ch05-pml2-functions-methods.md) "No `null` Keyword (MANDATORY)".

### 11. Bang-Prefix Arity — Built-in Globals Are ALWAYS Double-Banged (MANDATORY)
`!!CE`, `!!ALERT`, `!!edgCntrl`, `!!evar`, `!!evarSplit`, ... are **session globals with built-in values**; they must be written with **two bangs**. `!ce` (one bang) is a **completely different variable**: a plain local that is `unset` unless your code assigns it first. Reading `!ce.type`, `!ce.refno`, or `!ce.name` in a method that never assigned `!ce` silently reads an unset local — a frequent AI code-generation error. Name resolution is case-insensitive (delivered code mixes `!!CE`, `!!ce`, `!!Alert`, `!!alert` freely), so **only the bang count changes the meaning — never rely on case**.
- **Two legal idioms** (both used throughout delivered PMLLIB):
  1. Use the global directly: `if (!!ce.type.upcase().eq('SITE')) then ... !this.pa.val = !!ce.name`.
  2. Copy to a local FIRST, then use the local: `!ce = !!ce` on the first line of the method, then `!ce.type` / `!ce.badref().not()` — this `!ce = !!ce` snapshot idiom appears in hundreds of delivered files (e.g. `admin/objects/admstamp.pmlobj`, `aba/Objects/abadrawings.pmlobj`), and as formal parameters (`define method .addce(!ce is DBREF)`).
- **A bare single-bang `!ce` read is never legal** unless assigned earlier in the same scope (`!ce = !!ce`, another assignment, or a formal parameter). A scan of the bundled PMLLIB snapshot found **zero** delivered methods that read `!ce` before assigning it.
- **Never do this** (typical generation defect):
  ```pml
  define method .setCE()
    -- WRONG: !ce is an unset local, not the Current Element
    if (!ce.type.upcase().eq('ZONE') or !ce.type.upcase().eq('SITE')) then
      !this.selectedSiteZone = !ce.refno
      !this.paZone.val = !ce.name
    ...
  ```
- **Correct**:
  ```pml
  define method .setCE()
    if (!!ce.type.upcase().eq('ZONE') or !!ce.type.upcase().eq('SITE')) then
      !this.selectedSiteZone = !!ce.refno
      !this.paZone.val = !!ce.name
      !this.findData()
    else
      !!alert.error('Please select a SITE or ZONE')
      !this.netExport.clearGrid()
      !this.paZone.val = 'unset'
    endif
  endmethod
  ```
  (Equivalent delivered style: start the method with `!ce = !!ce` and keep the `!ce.` accesses.)
- **Review rule**: scan generated PML for single-bang uses of any built-in global name (`!ce`, `!alert`, `!edgCntrl`, ...) where the global is meant. If the name is not assigned or declared (`var`, `member`, formal parameter) earlier in the same scope, flag it: fix by double-banging, or by inserting `!ce = !!ce` at the top of the routine. Detail: [ch02](chapters/ch02-variables-data-types.md) "Built-in Globals vs Locals", [ch05](chapters/ch05-pml2-functions-methods.md) "Current Element (`!!CE`) Interfacing".

---

## Chapter Index

| # | Chapter File | Title & Focus | Key Concepts Covered |
|---|---|---|---|
| [ch01](chapters/ch01-pml-basics-environment.md) | PML Overview & Environment | PML 1 vs 2, `PMLLIB`, `pml rehash all`, macros, synonyms |
| [ch02](chapters/ch02-variables-data-types.md) | Variables, Types & Scope | Local (`!`) vs global (`!!`), Value vs Reference types, `.clone()`, `ARRAY` sorting |
| [ch03](chapters/ch03-flow-control-logic.md) | Control Flow & Logic | `DO ... VALUES`, `BREAK IF`, `SKIP IF`, `$S` synonyms, `OUTPUT` redirection |
| [ch04](chapters/ch04-error-handling-debugging.md) | Error Handling & Debugging | Post-attached `HANDLE ... ELSEHANDLE` (never wraps the guarded command), `MARK`/`UNDO` rollback, `ALPHA LOG`, `Q PML` |
| [ch05](chapters/ch05-pml2-functions-methods.md) | PML 2 Functions & Methods | `define function`, return types, ANY usage restrictions, chaining, `!!CE` context |
| [ch06](chapters/ch06-user-defined-objects.md) | User-Defined Objects (UDOs) | `define object`, `member .var`, constructors, methods, `!this` |
| [ch07](chapters/ch07-builtin-system-objects.md) | Core Built-in System Objects | `FILE` I/O, `FORMAT` units, `POSITION`, `DIRECTION`, `ORIENTATION` |
| [ch08](chapters/ch08-forms-gui-customisation.md) | Forms Architecture & Lifecycle | `setup form`, `initcall`, `okcall`, `pml reload form`, member state |
| [ch09](chapters/ch09-gadgets-layout-system.md) | GUI Gadgets & Layout System | Full gadget suite (`SELECTOR`, `CONTAINER`, `SLIDER`, `RTOGGLE`, `TEXTPANE`), relative positioning |
| [ch10](chapters/ch10-menus-toolbars-integration.md) | Menus, Toolbars & Framework | `define menu`, context popups, `!fmsys` (clipboard, refresh, cursor), `.pmladd` |
| [ch11](chapters/ch11-view-gadgets-3d.md) | 3D View Gadgets & Graphics | Embedded `VIEW`, `CLIPBOX`, drawlists, 3D nozzle tagging |
| [ch12](chapters/ch12-event-driven-graphics-edg.md) | Event Driven Graphics (EDG) | Non-blocking OO architecture (`!!edgCntrl`, `edgPacket`, `edgPickPacket`, `edgPickData`) |
| [ch13](chapters/ch13-collections-database-queries.md) | Collections & DABACON Queries | `object COLLECTION()`, `.scope()`, `.filter()`, hierarchy navigation |
| [ch14](chapters/ch14-marine-drafting-automation.md) | Marine Drafting Automation | `MarDrafting`, `MarUi` dialogs (`StrReqPML`, `AnswerReqPML`), `TraCoordShip`/`Pan`, `MarDex`, `DimLinearNew`, `PosnoNew` |
| [ch15](chapters/ch15-marapi-dotnet-interop.md) | MarAPI & .NET Interoperability | `import 'marapi'`, namespace binding, C# type marshaling |
| [ch16](chapters/ch16-pml-migration-best-practices.md) | PML Migration & Best Practices | Upgrading PML 1 to 2, variable expansion rules, `transc.exe` UTF-8 BOM |
| [ch17](chapters/ch17-system-objects-catalog.md) | SCRM System Objects Catalog | Comprehensive reference for all 80 native SCRM object & gadget types, reflection methods |
| [ch18](chapters/ch18-pdms-primitives-modeling.md) | 3D Modeling Primitives & P-Points | `BOX`, `CYLI`, `DISH`, P-point snapping (`CONN P1 TO P2 OF PREV`) |
| [ch19](chapters/ch19-production-exercises-recipes.md) | Production Exercises & Recipes | Verified code recipes from TM-2263 & TM-2401 training courses |
| [ch20](chapters/ch20-pml1-expressions-functions.md) | PML 1 Expressions & Functions | SCRM Appendix A reference: mathematical, text, logical functions, `$!var` late eval, `&+` concat |

---

## Topic Index

- **Alerts (`!!ALERT`)** → [ch04](chapters/ch04-error-handling-debugging.md), [ch07](chapters/ch07-builtin-system-objects.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Anchoring & Docking** → [ch09](chapters/ch09-gadgets-layout-system.md)
- **ANY (`is ANY` type-specifier restrictions)** → [ch02](chapters/ch02-variables-data-types.md), [ch05](chapters/ch05-pml2-functions-methods.md)
- **Arrays & Indexing** → [ch02](chapters/ch02-variables-data-types.md), [ch03](chapters/ch03-flow-control-logic.md)
- **Assembly Import (`marapi`)** → [ch14](chapters/ch14-marine-drafting-automation.md), [ch15](chapters/ch15-marapi-dotnet-interop.md)
- **Bang-Prefix Arity (`!ce` vs `!!ce`, single- vs double-bang globals)** → Core Framework 11, [ch02](chapters/ch02-variables-data-types.md), [ch05](chapters/ch05-pml2-functions-methods.md)
- **Clipbox Manipulation** → [ch11](chapters/ch11-view-gadgets-3d.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **Collections (`COLLECTION`)** → [ch13](chapters/ch13-collections-database-queries.md), [ch17](chapters/ch17-system-objects-catalog.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **Copies vs References (`.clone()`)** → [ch02](chapters/ch02-variables-data-types.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Coordinate Translation (`TraCoordShip`, `CoordToPos`)** → [ch14](chapters/ch14-marine-drafting-automation.md)
- **Data Extraction (`MarDex`)** → [ch14](chapters/ch14-marine-drafting-automation.md)
- **Expressions & Functions (SCRM Appendix A)** → [ch20](chapters/ch20-pml1-expressions-functions.md)
- **Current Element (`!!CE`)** → [ch02](chapters/ch02-variables-data-types.md), [ch05](chapters/ch05-pml2-functions-methods.md), [ch13](chapters/ch13-collections-database-queries.md)
- **DABACON Database Reference (`DBREF`)** → [ch02](chapters/ch02-variables-data-types.md), [ch07](chapters/ch07-builtin-system-objects.md), [ch13](chapters/ch13-collections-database-queries.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **DO Loops (`VALUES`, `INDEX`, `BREAK IF`)** → [ch03](chapters/ch03-flow-control-logic.md), [ch16](chapters/ch16-pml-migration-best-practices.md)
- **Drawing Functions (`MarDrafting`)** → [ch14](chapters/ch14-marine-drafting-automation.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **Error Handling (`HANDLE`, `MARK`, `UNDO`)** → Core Framework 9 (post-attached trap order), [ch04](chapters/ch04-error-handling-debugging.md), [ch16](chapters/ch16-pml-migration-best-practices.md)
- **Event Driven Graphics (`EDG`, `!!edgCntrl`)** → [ch12](chapters/ch12-event-driven-graphics-edg.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **File I/O (`FILE`)** → [ch07](chapters/ch07-builtin-system-objects.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Forms & Gadgets (`setup form`, `SELECTOR`)** → [ch08](chapters/ch08-forms-gui-customisation.md), [ch09](chapters/ch09-gadgets-layout-system.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **FMSYS (`!fmsys`)** → [ch10](chapters/ch10-menus-toolbars-integration.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Hot-Reloading (`pml reload form`)** → [ch08](chapters/ch08-forms-gui-customisation.md)
- **Marine Drafting Element Handles** → [ch14](chapters/ch14-marine-drafting-automation.md)
- **Menus & Add-ins (`.pmladd`)** → [ch10](chapters/ch10-menus-toolbars-integration.md)
- **Null / empty returns (`return null` is invalid; typed empty idioms)** → Core Framework 10, [ch05](chapters/ch05-pml2-functions-methods.md)
- **P-Points & 3D Primitives (`CONN`)** → [ch18](chapters/ch18-pdms-primitives-modeling.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **PMLLIB & Rehash (`pml rehash all`)** → [ch01](chapters/ch01-pml-basics-environment.md), [ch16](chapters/ch16-pml-migration-best-practices.md)
- **User-Defined Objects (`.pmlobj`)** → [ch06](chapters/ch06-user-defined-objects.md)
- **UTF-8 BOM Standards (`transc.exe`)** → [ch04](chapters/ch04-error-handling-debugging.md), [ch16](chapters/ch16-pml-migration-best-practices.md)
- **Viewports (`VIEW`)** → [ch11](chapters/ch11-view-gadgets-3d.md), [ch19](chapters/ch19-production-exercises-recipes.md)

---

## Supporting Files

- [glossary.md](glossary.md) — Alphabetical dictionary of all PML, DABACON, and Marine terms with chapter citations.
- [patterns.md](patterns.md) — 8 Production architectural patterns: MVC Form, Database Guards, Scoped Queries, EDG Pick Handlers, P-Point Assembly, Marine Drafting guards, Memory Isolation.
- [cheatsheet.md](cheatsheet.md) — Decision rules ("When X, do Y"), syntax flowcharts, trade-off matrices, thresholds, and diagnostic smells.
- [references/pmllib-idioms.md](references/pmllib-idioms.md) — Verified idioms mined from the delivered source: form skeleton, menus, selector+navigation, EDG packet API, COLLECTION pipeline, EVAR/evars.bat, marapi import guard, pmlnetcontrol, FILE I/O — every snippet cited to a real PMLLIB file.
- [references/pmllib-index.md](references/pmllib-index.md) — Machine-generated index of all 6075 bundled source files (module, type, lines, syntax flags, description). Grep this first, then open the source. Regenerate with [tools/regen-pmllib-index.ps1](tools/regen-pmllib-index.ps1).
- [PMLLIB/](PMLLIB/) — The bundled AVEVA-delivered PML source snapshot (see Core Framework 2b).
- [tools/pml-parse/](tools/pml-parse/) — Offline PML syntax checker (tree-sitter CLI + pml.dll + PowerShell wrappers): parse-pml.ps1 for single files/folders, bench-pmllib.ps1 as parser sanity gate. See Core Framework 2c.

---

## Scope & Limits

This skill covers AVEVA PML 1 and PML 2 language syntax, GUI form customisation, Event Driven Graphics, DABACON model queries, and Marine Drafting automation as documented in TM-2263, TM-2401, SOFTCG, and SCRM.
- **Scope**: Applicable to AVEVA Marine (12 series) and AVEVA PDMS (11.5+).
- **Out of Scope**: Third-party C# plugin compilation with external Visual Studio IDEs, low-level SQL database bypasses bypassing DABACON, or proprietary hardware licensing configurations.
