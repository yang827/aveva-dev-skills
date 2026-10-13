# AVEVA PML Quick Reference & Decision Cheatsheet

Fast-lookup decision rules, syntax flowcharts, trade-off matrices, and diagnostics for AVEVA Plant & Marine PML development.

---

## 1. Decision Rules (When X, Do Y, Because Z)

- **When you need a loop with a conditional exit**:
  - **Do**: `DO ... BREAK IF (!condition) ... ENDDO`.
  - **Don't**: Use `while` or `do while`.
  - **Because**: AVEVA PML has no `while` or `do while` syntax; `DO` with `BREAK IF` is the only valid construct.
- **When checking if an element exists before dereferencing**:
  - **Do**: Test `if (not !ref.badRef()) then`.
  - **Don't**: Rely on checking string name or `!ref.unset()`.
  - **Because**: A `DBREF` may be set to a deleted reference number; `.badRef()` verifies the element actually exists in DABACON.
- **When duplicating an array or UDO object to modify locally**:
  - **Do**: `!workingCopy = !original.clone()`.
  - **Don't**: Assign directly via `!workingCopy = !original`.
  - **Because**: In PML 2, arrays and objects are reference types; direct assignment creates a memory alias, corrupting the original.
- **When prompting users for interaction in Marine Drafting (TM-2401)**:
  - **Do**: Use `!res = !marUi.AnswerReqPML('Title', 'Prompt')` and compare against `!marUtil.YesPML()`.
  - **Don't**: Compare against numeric `1` or string `'YES'`, or invent non-existent APIs.
  - **Because**: Return codes are internal system button identifiers defined exclusively on `MarUtil`.
- **When implementing 3D graphical picking in modern tools (SCRM Chapter 3)**:
  - **Do**: Use `!!edgCntrl.addPacket(!packet)` with `edgPacket` and `edgPickPacket`.
  - **Don't**: Use blocking legacy commands like `ID NOZZ @` inside modeless forms.
  - **Because**: Legacy `ID @` suspends execution and freezes all other open forms; modern EDG is non-blocking and event-driven.
- **When modifying a form during development**:
  - **Do**: Issue `pml reload form !!formname` in the Command Window.
  - **Don't**: Close and restart AVEVA.
  - **Because**: `pml reload form` instantly recompiles the `.pmlfrm` from disk without losing your active 3D model context.
- **When writing automated batch scripts**:
  - **Do**: Append `noalert` to `return error <num> '<msg>' noalert`.
  - **Don't**: Allow standard modal error popups to display.
  - **Because**: Modal alerts halt unattended execution until a user clicks OK.
- **When translating coordinates in Marine Drafting (TM-2401)**:
  - **Do**: Use `!marUtil.TraCoordShip(!pt, !panel, !outShipPt)` (Sheet to Ship), `!marDraft.PointTranform(!shipPt, !sheetPt)` (Ship to Sheet), and `!marUtil.CoordToPos(axis, coord, !fr, !off)` for frame positions.
  - **Don't**: Use pseudo-methods like `WorldToSheet()` or `SheetToWorld()`.
  - **Because**: Marine Drafting relies specifically on `MarUtil` and `MarDrafting` coordinate methods tied to structural panel planes.
- **When rounding numbers in expressions or queries (SCRM Appendix A)**:
  - **Do**: Use `NINT(!num)`.
  - **Don't**: Use `INT(!num)` when mathematical rounding is required.
  - **Because**: `INT()` truncates decimals towards zero (`INT(3.9) = 3.0`), while `NINT()` rounds to the nearest integer (`NINT(3.9) = 4.0`).
- **When splitting or parsing string tokens (SCRM Appendix A)**:
  - **Do**: Use `BEFORE(!str, !token)`, `AFTER(!str, !token)`, or `PART(!str, !index, !delim)`.
  - **Don't**: Attempt string subtraction (`!str - !sub`).
  - **Because**: String subtraction is an invalid operation in PML; `BEFORE` and `AFTER` provide clean prefix/suffix splitting.
- **When one function must handle multiple input types**:
  - **Do**: Declare the formal parameter with `is ANY` in `define function` / `define method` (and use `is ANY` as a return type only with documented evidence).
  - **Don't**: Declare a normal variable `!value is ANY`, or treat ANY like C# `object`, a generic type parameter `T`, or dynamic typing.
  - **Because**: In PML, ANY is a signature-position type specifier only; ordinary variables keep the type fixed at creation and PML has no generic or dynamic variable type.
- **When a function must return "nothing" / an empty value**:
  - **Do**: Return the typed empty idiom — `return ''` or `return object STRING()` (`is STRING`), `return object DBREF()` (`is DBREF`), `return object ARRAY()` (`is ARRAY`).
  - **Don't**: Write `return null`, `return nil`, or `return None` — PML has no null literal and the compiler fails with `CP: Syntax error` at `return ^^NULL`. The phrase "return null" in delivered PMLLIB exists only in English `--` comments, never in code.
  - **Because**: `return` requires an expression; "emptiness" in PML is per-type (empty value vs `unset()` object), tested at the call site per the test-idiom table in Ch 5.
- **When testing a value for "empty" / "no value"**:
  - **Do**: `if (!x.unset())` (unassigned object/DBREF/ARRAY), `if (!s.eq(''))` (blank STRING), `if (undefined(!x))` (never defined), `if (!ref.badRef())` (dead DBREF).
  - **Don't**: `!x.null()` — no PML type defines a `null()` method; it compiles but fails at runtime with `Method <STRING>.NULL() not found`.
  - **Because**: `.null()` and `null` are Java/C#/JS habits with no PML equivalent; emptiness is always per-type, never a universal null reference.
- **When referencing the Current Element (or any built-in global)**:
  - **Do**: Write it double-banged — `!!ce.type`, `!!ce.name`, `!!alert.error(...)`, `!!edgCntrl.add(...)` — or snapshot first: `!ce = !!ce`, then use `!ce.xxx`.
  - **Don't**: Write `!ce.type` / `!ce.refno` / `!alert.error(...)` in a scope that never assigned the local; and don't "fix" it by changing case.
  - **Because**: Built-in globals (`!!CE`, `!!ALERT`, `!!edgCntrl`, ...) exist ONLY in `!!` form; a single-bang `!ce` is an unrelated local that stays `unset` until assigned. PML names are case-insensitive, so only the bang count changes the meaning (SKILL.md Core Framework 11).
- **When opening or creating Marine Drafting drawings**:
  - **Do**: Check `if (!marDraft.DwgCurrent()) then !marDraft.DwgClose() endif`.
  - **Don't**: Call `DwgOpen` or `DwgNew` directly.
  - **Because**: Marine Drafting is strictly Single Document Interface; opening over an active drawing raises a fatal exception.

---

## 2. Syntax Selection Flowchart

```
Need to automate an AVEVA task?
 │
 ├── Linear command sequence without logic or UI?
 │    └── Write a Macro (.mac) with $m /path/macro.mac [args]
 │
 ├── Reusable computational logic or database query?
 │    └── Write a Function (.pmlfnc) in PMLLIB
 │         └── define function !!funcName(!arg is TYPE) is RET_TYPE
 │
 ├── Encapsulated data model with methods & state?
 │    └── Write a User-Defined Object (.pmlobj) in PMLLIB
 │         └── define object typeName + define method .typeName()
 │
 ├── Interactive user interface with graphical controls?
 │    └── Write a Form (.pmlfrm) in PMLLIB
 │         └── setup form !!formName dialog resizable + member variables
 │
 └── Interactive 3D Graphical Canvas Picking?
      └── Register an EDG Packet (.action callback)
           └── !!edgCntrl.addPacket(!myEdgPacket)
```

---

## 3. Trade-off Matrices

### Query Strategy Comparison
| Dimension | PML 1 `VAR ... COLL` | PML 2 `object COLLECTION()` | Direct Hierarchy Traversal (`.owner`, `mcount`) |
|---|---|---|---|
| **Return Type** | `ARRAY of STRING` | `ARRAY of DBREF` | Single `DBREF` |
| **Speed (Small Query)** | Very Fast (<5ms) | Fast (~10ms) | Instant (<1ms) |
| **Speed (Large Subtree)**| Moderate | Highly Optimized | Slow if traversing thousands recursively |
| **Memory Consumption** | Low (Strings) | Moderate (Object handles) | Minimal |
| **Flexibility** | String queries only | Complex `EXPRESSION` filters | Direct parent/child links only |

### Variable Scope & Memory Semantics
| Scope / Type | Prefix / Keyword | Assignment Semantics | Mutation Impact |
|---|---|---|---|
| **Scalar Primitive** | `REAL`, `STRING`, `BOOLEAN` | **Value Copy**: `!a = !b` clones value | Modifying `!a` leaves `!b` unchanged |
| **Complex Object** | `ARRAY`, `DBREF`, `FORM`, UDO | **Reference Alias**: `!a = !b` copies pointer | Modifying `!a` alters `!b` directly! |
| **Deep Duplicate** | `!a = !b.clone()` | **Deep Copy**: Clones all memory | Independent instance created |
| **Local Variable** | `!var` | Exists for method duration | Cleaned up on exit |
| **Session Global** | `!!var` | Persists across session | Potential cross-form side effects |
| **Built-in Global** | `!!CE`, `!!ALERT`, `!!edgCntrl` | Runtime-maintained; exists only as `!!name` | One-bang `!ce`/`!alert` is a different, unset local |

---

## 4. Thresholds & Defaults
- **Form Gadget Spacing**: Standard relative horizontal spacing: `xmax + 1`. Standard vertical line spacing: `ymax + 0.5`.
- **List Gadget Dimensions**: Standard dropdown/list width: 25–40 characters; height: 5–8 lines for compact dialogs, 10–15 lines for primary browsers.
- **Safety Loop Ceiling**: Always cap open `DO` loops at 10,000 iterations to prevent infinite freezing: `BREAK IF (!counter GT 10000)`.
- **Character Encoding**: Ensure all `.pmlfnc`, `.pmlobj`, and `.pmlfrm` files containing non-ASCII characters have a UTF-8 BOM.

---

## 5. Tells & Smells (Diagnostics)
| Symptom / Error Message | Root Cause | Immediate Fix |
|---|---|---|
| `(41, 8) ERROR` | Attempting to create an element at an illegal hierarchy level | Navigate to valid parent (e.g., `ZONE` before creating `EQUI`) |
| `(41, 12) ERROR` | Duplicate element name in database | Query existing names or append unique index suffix |
| `(1000, 0) ERROR` | Re-importing a .NET assembly already resident in memory | Place `handle (1000, 0) ... endhandle` immediately **after** the `import` (import stays outside the trap — see SKILL.md Core Framework 9) |
| `Unknown function or object` | File missing from index or bad naming | Check lowercase filename; run `pml rehash all` |
| UI form changes not showing | Outdated bytecode cached in memory | Run `pml reload form !!formname` |
| Element attributes return empty | Dereferencing an invalid or deleted pointer | Check `if (not !ref.badRef())` before attribute queries |
| Marine Drafting drawing error | Calling drawing methods without active drawing | Verify `if (!marDraft.DwgCurrent())` |
| Corrupted Array / Data Mutation | Reference aliasing bug (`!x = !y` on arrays) | Replace with `!x = !y.clone()` |
| Interactive pick freezes all forms | Using superseded `ID @` inside modeless form | Migrate to modern `!!edgCntrl.addPacket()` architecture |
| `is ANY` written on a normal variable (e.g. `!value is ANY` in a function body) | ANY mistaken for a generic/dynamic variable type (C# `object`, `T`) | Judge by syntactic position: parameter/return declarations are legal — only normal-variable declarations are defects; refactor to concrete types, `ARRAY`, or an ANY formal parameter |
| `CP: Syntax error` pointing at `return ^^NULL` | `return null` — PML has no `null`/`nil`/`None` literal (habits from Java/C#/JS/Python) | Return the typed empty idiom: `''` or `object STRING()` (STRING), `object DBREF()` (DBREF), `object ARRAY()` (ARRAY); test emptiness with `.unset()` / `undefined()` |
| `Method <STRING>.NULL() not found` (runtime) | `!x.null()` — no PML type defines a `null()` method (the call compiles; it fails on method lookup at runtime) | Replace with the per-type test: `!x.unset()` (unassigned object), `!s.eq('')` (blank STRING), `undefined(!x)` (never defined), `!ref.badRef()` (dead DBREF) |
| `!ce.type` / `!ce.name` silently empty, or "Method not found" / unset-value errors on a CE-based check (e.g. a `setCE()` guard that always fails) | Single-bang `!ce` — reads an unset **local**, not the Current Element `!!CE` | Use `!!ce.xxx` (or `!!CE.xxx`; case is irrelevant) or assign `!ce = !!ce` at the top of the routine before using `!ce.`. Same applies to `!alert`, `!edgCntrl`, `!evar` — built-ins are `!!` only |
