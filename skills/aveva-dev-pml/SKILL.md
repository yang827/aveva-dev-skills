---
name: aveva-dev-pml
description: "Knowledge base for AVEVA PML secondary development (part of the aveva-dev-skills suite). Covers PML 1 and PML 2 macros, functions, forms, gadgets, Event Driven Graphics, Marine Drafting automation, and DABACON database queries."
metadata:
  suite: aveva-dev-skills
  version: "0.1.0"
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
  !results = !coll.results() -- Returns ARRAY of DBREF
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
- Marine Drafting automation (TM-2401) requires `import 'marapi'` wrapped in `handle (1000, 0) endhandle`.
- Strict Single Document Interface (SDI): Only one drawing sheet can be active at any time. Always test `if (!marDraft.DwgCurrent())` and close (`!marDraft.DwgClose()`) before creating or opening a new drawing.
- Interactive dialogs use `!marUi.AnswerReqPML('Title', 'Prompt')` with return codes checked against `!marUtil.YesPML()`, `!marUtil.NoPML()`, `!marUtil.CancelPML()`.

---

## Chapter Index

| # | Chapter File | Title & Focus | Key Concepts Covered |
|---|---|---|---|
| [ch01](chapters/ch01-pml-basics-environment.md) | PML Overview & Environment | PML 1 vs 2, `PMLLIB`, `pml rehash all`, macros, synonyms |
| [ch02](chapters/ch02-variables-data-types.md) | Variables, Types & Scope | Local (`!`) vs global (`!!`), Value vs Reference types, `.clone()`, `ARRAY` sorting |
| [ch03](chapters/ch03-flow-control-logic.md) | Control Flow & Logic | `DO ... VALUES`, `BREAK IF`, `SKIP IF`, `$S` synonyms, `OUTPUT` redirection |
| [ch04](chapters/ch04-error-handling-debugging.md) | Error Handling & Debugging | `HANDLE ... ELSEHANDLE`, `MARK`/`UNDO` rollback, `ALPHA LOG`, `Q PML` |
| [ch05](chapters/ch05-pml2-functions-methods.md) | PML 2 Functions & Methods | `define function`, return types, chaining, `!!CE` context |
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
- **Arrays & Indexing** → [ch02](chapters/ch02-variables-data-types.md), [ch03](chapters/ch03-flow-control-logic.md)
- **Assembly Import (`marapi`)** → [ch14](chapters/ch14-marine-drafting-automation.md), [ch15](chapters/ch15-marapi-dotnet-interop.md)
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
- **Error Handling (`HANDLE`, `MARK`, `UNDO`)** → [ch04](chapters/ch04-error-handling-debugging.md), [ch16](chapters/ch16-pml-migration-best-practices.md)
- **Event Driven Graphics (`EDG`, `!!edgCntrl`)** → [ch12](chapters/ch12-event-driven-graphics-edg.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **File I/O (`FILE`)** → [ch07](chapters/ch07-builtin-system-objects.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Forms & Gadgets (`setup form`, `SELECTOR`)** → [ch08](chapters/ch08-forms-gui-customisation.md), [ch09](chapters/ch09-gadgets-layout-system.md), [ch19](chapters/ch19-production-exercises-recipes.md)
- **FMSYS (`!fmsys`)** → [ch10](chapters/ch10-menus-toolbars-integration.md), [ch17](chapters/ch17-system-objects-catalog.md)
- **Hot-Reloading (`pml reload form`)** → [ch08](chapters/ch08-forms-gui-customisation.md)
- **Marine Drafting Element Handles** → [ch14](chapters/ch14-marine-drafting-automation.md)
- **Menus & Add-ins (`.pmladd`)** → [ch10](chapters/ch10-menus-toolbars-integration.md)
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

---

## Scope & Limits

This skill covers AVEVA PML 1 and PML 2 language syntax, GUI form customisation, Event Driven Graphics, DABACON model queries, and Marine Drafting automation as documented in TM-2263, TM-2401, SOFTCG, and SCRM.
- **Scope**: Applicable to AVEVA Marine (12 series) and AVEVA PDMS (11.5+).
- **Out of Scope**: Third-party C# plugin compilation with external Visual Studio IDEs, low-level SQL database bypasses bypassing DABACON, or proprietary hardware licensing configurations.
