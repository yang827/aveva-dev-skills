# Chapter 2: Variables, Data Types & Scope

## Core Idea
PML 2 is a strongly typed, object-based language where variables hold either primitive data values or object instances. Variable scope is strictly partitioned between local variables (prefixed with `!`) and global session variables (prefixed with `!!`). Understanding the fundamental distinction between **Value Types** and **Reference Types** (SOFTCG Chapter 9) is critical for preventing memory alias bugs and unintended state mutations.

## Frameworks Introduced

### 1. Two-Tier Variable Scope Framework
* **Local Scope (`!name`)**: Visible only within the executing macro, function, or method. Deallocated automatically upon exiting scope.
* **Global Scope (`!!name`)**: Persists across all macros, forms, and modules throughout the entire AVEVA session until explicitly unset or session exit.
* **Legacy Numbered Variables (`$0` – `$99`)**: Used in PML 1 macros where arguments passed to `$M /macro arg1 arg2` populate `$1`, `$2`, etc.
* **Built-in Globals vs Locals (Bang-Prefix Arity)**: Names such as `!!CE`, `!!ALERT`, `!!edgCntrl`, `!!evar` are session globals pre-populated by the runtime — they exist **only** in double-bang form. Writing one bang (`!ce`, `!alert`) creates or reads an unrelated **local** variable that is `unset` until your own code assigns it. So `!ce.type` in a method that never assigned `!ce` silently reads an unset local; the Current Element is `!!ce`. Two delivered idioms are legal: use `!!ce.xxx` directly, or snapshot first (`!ce = !!ce`, then `!ce.xxx` — the pervasive `!ce = !!ce` pattern in the delivered sources) or receive it as a formal parameter (`define method .addce(!ce is DBREF)`). Identifier case is irrelevant (`!!CE` = `!!ce` = `!!Ce`); **only the number of bangs changes the meaning** (SKILL.md Core Framework 11).

### 2. Copies and References Framework (SOFTCG Chapter 9)
PML 2 treats data in two distinct ways upon assignment (`!a = !b`) and parameter passing:
* **Value Types (Scalars & Primitives)**:
  * `REAL`, `STRING`, `BOOLEAN`.
  * Assignment (`!x = !y`) creates an independent **copy**. Modifying `!x` leaves `!y` unaffected.
* **Reference Types (Complex Objects, Forms & Gadgets)**:
  * `FORM`, Gadgets, `ARRAY`, `DBREF`, UDOs.
  * Assignment (`!ref = !myGadget` or `!arr2 = !arr1`) assigns a **pointer/reference**, not a copy! Both variables point to the exact same underlying memory block.
  * **Shallow Copy (`.copy()`)**: Duplicates the top-level container, but nested object references still point to original items.
  * **Deep Clone (`.clone()`)**: Recursively duplicates the object and all child references into an entirely distinct instance.
* **Function Argument Passing**:
  * Arrays and Objects passed into functions are passed **by reference**; changes made inside the function persist in the caller's instance unless `.copy()` or `.clone()` is performed.

### 3. Advanced Array & Data Manipulation (SOFTCG Chapter 6)
* **Dynamic Collections**: 1-based indexed arrays (`!arr[1]` is first element).
* **Multi-dimensional Arrays**: Arrays containing child arrays (`!grid = ARRAY()`, `!grid.append(ARRAY())`).
* **Built-in Array Methods**:
  * `.append(!val)`, `.insert(idx, !val)`, `.delete(idx)`, `.clear()`, `.size()`.
  * `.sort()`: Sorts elements in-place in ascending order.
  * `.sortUnique()`: Sorts and removes duplicate entries.
* **The AVEVA `VAR` Command for Arrays**:
  * Sorting: `VAR !sorted SORT !rawArray`
  * Subtotalling / Grouping: `VAR !sub TOTAL !dataArray BY !groupField`

---

## Key Concepts
* **`REAL`**: Floating point numeric type used for measurements, coordinates, angles, and loop bounds.
* **`STRING`**: Unicode text. Supports `.length()`, `.upCase()`, `.lowCase()`, `.substring(start, len)`, `.split(delim)`, and `.trim()`.
* **`BOOLEAN`**: Logical flag holding `TRUE` or `FALSE`.
* **`ARRAY`**: Dynamic, 1-based collection of heterogeneous objects. Initialized via `!a = ARRAY()`.
* **`DBREF`**: Database Reference object pointing directly to a DABACON hierarchy element. Initialized via `!ref = !name.dbref()` or extracted from `!!CE`.
* **Delimiters**: Single quotes `'text'` or pipes `|text with 'quotes' or $special|`.
* **`unset()`**: Method checking if a variable or member is unassigned (`if (!var.unset()) ...`).
* **`DELETE VAR`**: Frees variable memory (`delete var !varName`, `delete var !!globalName`).
* **`ANY` (signature-only specifier)**: Type specifier usable **only** in function/method formal-parameter declarations — and, where documented, in function return-type declarations — to accept differing argument types. It is **not** a variable type: `!var is ANY` as a normal variable declaration is invalid, and a variable's type is fixed at creation and cannot change during its lifetime. See Ch 5 "ANY Type Usage Restrictions (MANDATORY)".

---

## Code Examples

### Demonstrating Value Types vs Reference Semantics (SOFTCG Chapter 9)
```pml
-- ================================================================
-- Example: Value Types vs Reference Semantics & Cloning
-- ================================================================

-- 1. Value Type Behavior (Scalar Copy)
!origNum = 100.0
!copyNum = !origNum
!copyNum = 250.0
-- Outputs: Original 100.0 (unaffected), Copy 250.0
$P Original: $!origNum
$P Copy:     $!copyNum

-- 2. Reference Type Behavior (Shared Pointer)
!origArray = ARRAY()
!origArray.append('PUMP-01')

-- Creates an alias reference!
!aliasArray = !origArray
!aliasArray.append('PUMP-02')

-- Outputs: both sizes 2 (origArray was modified through the alias!)
$P Orig Array Size:  $!origArray.size()
$P Alias Array Size: $!aliasArray.size()

-- 3. Breaking Reference Link with .clone()
!isolatedArray = !origArray.clone()
!isolatedArray.append('PUMP-03')

-- Outputs: Orig 2 (safe), Isolated 3
$P Orig Array Size:     $!origArray.size()
$P Isolated Array Size: $!isolatedArray.size()

-- 4. Advanced Array Sorting and Grouping
!names = ARRAY()
!names.append('Vessel')
!names.append('Column')
!names.append('Vessel')
!names.append('Boiler')

!names.sortUnique()
-- !names now contains: 'Boiler', 'Column', 'Vessel'
```

### Demonstrating Bang-Prefix Arity: `!!ce` (global) vs `!ce` (unset local)
```pml
-- ================================================================
-- Example: The Current Element is the GLOBAL !!ce — one bang is a
-- different, unset local variable.
-- ================================================================

-- 1. Correct: read the built-in global directly
!typeName = !!ce.type
!siteRef  = !!ce.refno

-- 2. Correct delivered idiom: snapshot the global into a local FIRST
!ce = !!ce
if (!ce.badref().not()) then
  !elemName = !ce.name
endif

-- 3. WRONG (a generated-code defect, never legal delivered code):
--    !ce was never assigned in this scope, so it is unset here.
-- !bad = !ce.type       <-- reads an unset local, NOT the Current Element
```
- **What it demonstrates**: `!!ce` is the built-in global Current Element (`DBREF`); `!ce` is only valid after a local assignment such as `!ce = !!ce` or as a formal parameter (`define method .addce(!ce is DBREF)`). Case (`CE` vs `ce`) is irrelevant — only bang count matters.

---

## Anti-patterns
* **Reading a Built-in Global with One Bang**: `!ce.type` (or `!alert.error(...)`, `!edgCntrl.add(...)`) looks like the global Current Element / Alert / EDG controller but is a **distinct local variable** that is `unset` unless assigned. Fix by writing the global with two bangs (`!!ce.type`) or by assigning first (`!ce = !!ce`). Do not "fix" it by changing case — PML identifiers are case-insensitive; only the bang count matters.
* **Accidental Array Mutation via Aliasing**: Writing `!temp = !globalData` and modifying `!temp` mutates `!globalData`. Always use `!temp = !globalData.clone()` when a local working copy is needed.
* **Modifying Gadgets Through Stale References**: Assigning `!btn = !this.myButton` across different form events without verifying if the parent form is still loaded.
* **Zero-Based Array Indexing**: PML arrays are strictly **1-based** (`!arr[1]`). Accessing index 0 throws a runtime exception.
* **Incorrect Equality Comparison**: Using `==` or `=` for expression comparison. Always use `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`.
* **Declaring a "generic" variable `is ANY`**: `!value is ANY` as a normal variable declaration is invalid PML. ANY is a signature-position specifier (formal parameters, and return types where documented) — not a variable type, not C# `object`, not a generic `T`. Choose a concrete type, `ARRAY`, or an object design instead. (Ch 5: ANY Type Usage Restrictions.)

## Reference Tables
| Concept / Keyword | Syntax | Behavior / Return |
|---|---|---|
| Value Assignment | `!x = !y` (where `!y` is REAL/STRING) | Deep value copy |
| Reference Assignment | `!a = !b` (where `!b` is ARRAY/OBJECT) | Pointer alias assignment |
| Built-in Global (Current Element) | `!!ce` / `!!CE` | The runtime-maintained global `DBREF` — always two bangs |
| Local Shadow of a Global | `!ce = !!ce` then `!ce.name` | Legal only AFTER the assignment; bare `!ce.` reads an unset local |
| Shallow Copy | `!new = !orig.copy()` | Top-level copy |
| String Concatenation | `'AVEVA' & ' ' & 'Marine'` | Joined string |
| PML 1 No-Space Concat | `!str1 &+ !str2` (TM-2263 4.3.9) | Joins strings without space |
| Comparison Operators | `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`, `LIKE` | `BOOLEAN` result |
| Logical Operators | `AND`, `OR`, `NOT` | `BOOLEAN` evaluation |

## Key Takeaways
1. Primitives (`REAL`, `STRING`, `BOOLEAN`) copy by value; Objects, Forms, and Arrays assign by reference.
2. Use `.clone()` whenever you need to duplicate an array or object without mutating the original.
3. PML arrays are dynamic, 1-based, and support `.sort()` and `.sortUnique()`.
4. Functions pass object and array parameters by reference.
5. Built-in globals (`!!CE`, `!!ALERT`, `!!edgCntrl`, ...) exist only with two bangs; a one-bang name is a different, unset local — use `!!ce.xxx` or assign `!ce = !!ce` first.

## Connects To
* **Ch 1**: PML Basics & Environment
* **Ch 3**: Control Flow & Logic
* **Ch 6**: User-Defined Objects (UDOs)
* **Ch 7**: Core System Objects
* **Ch 13**: Collections & Database Queries
* **Ch 20**: SCRM Appendix A — PML 1 Expressions & Functions Reference
