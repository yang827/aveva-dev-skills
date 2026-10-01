# Chapter 5: PML 2 Functions & Methods

## Core Idea
PML 2 functions (`.pmlfnc`) provide reusable, encapsulated logic with explicit argument signatures and return types. Functions support recursive execution, method chaining, and clean decoupling from the global command line.

## Frameworks Introduced
- **Function Definition Contract**:
  - Defined using `define function !!<name>(!<arg1> is <TYPE>, ...) is <RETURN_TYPE>` and closed with `endfunction`.
  - If no return value is produced, the `is <RETURN_TYPE>` clause is omitted.
  - The function file must reside in `PMLLIB` and be named strictly `<name_in_lowercase>.pmlfnc`.
- **Method Chaining (Concatenation) Pipeline**:
  - In PML 2, any method returning an object allows direct invocation of subsequent methods in a single expression:
    `!result = !str.trim().upcase().substring(1, 5)`
    `!posStr = !!CE.position.string()`
- **Current Element (`!!CE`) Interfacing**:
  - `!!CE` is the global built-in `DBREF` pointing to the currently active element in the 3D DABACON hierarchy.
  - Navigating with AVEVA commands (e.g., `/ZONE-1` or `NEXT`) automatically updates `!!CE`.

## Key Concepts
- **`define function` / `endfunction`**: Keywords declaring a standalone PML 2 callable subroutine.
- **Return Types**: Can be any primitive (`REAL`, `STRING`, `BOOLEAN`), compound structure (`ARRAY`), database handle (`DBREF`), or user-defined object.
- **`return` Statement**: Exits the function and supplies the return value: `return !calculatedVal`.
- **Argument Parameterization**: Parameters are declared with explicit types:
  `define function !!calcVolume(!x is REAL, !y is REAL, !z is REAL) is REAL`
- **Method vs Function**:
  - Functions (`!!func()`) are standalone procedures stored in `.pmlfnc`.
  - Methods (`!obj.method()`) belong to a specific object type and are defined in `.pmlobj` or `.pmlfrm`.

## Mental Models
- **Think of `.pmlfnc` files as modular libraries**: Each function gets its own file. AVEVA loads it on first call and caches the compiled bytecode in memory.
- **Use `!!CE` defensively**: Never assume `!!CE` points to a specific element type; always inspect `!!CE.type` or test with `!ce.badRef()`.

## Anti-patterns
- **Putting Multiple Functions in a Single `.pmlfnc`**: Unlike C or Python, AVEVA PML 2 mandates **one function per `.pmlfnc` file**, with the filename exactly matching the function name.
- **Forgetting to Return a Value**: If a function is declared with `is <TYPE>`, reaching `endfunction` without executing a typed `return` statement raises a runtime execution error.
- **Global Variable Dependencies**: Relying on undeclared global variables inside functions reduces reusability; pass all needed inputs through parameters.

## Code Examples
```pml
-- ================================================================
-- File: calculatepipevolume.pmlfnc
-- Location: %PMLLIB%\calculatepipevolume.pmlfnc
-- ================================================================
define function !!calculatePipeVolume(!bore is REAL, !length is REAL) is REAL
  -- Validate inputs
  if (!bore LE 0.0 or !length LE 0.0) then
    $P Error: Bore and length must be positive non-zero values.
    return 0.0
  endif

  !pi = 3.14159265358979
  !radius = !bore / 2.0
  !volume = !pi * POW(!radius, 2) * !length

  return !volume
endfunction

-- ================================================================
-- Calling the function from a macro or command line:
-- ================================================================
!dia = 150.0
!len = 2500.0
!totalVol = !!calculatePipeVolume(!dia, !len)
$P Total calculated volume: $!totalVol mm3
```
- **What it demonstrates**: Function declaration with typed arguments, return type declaration (`is REAL`), input validation, mathematical calculation, return statement, and external caller invocation.

## Reference Tables
| Signature Element | Syntax Pattern | Notes |
|---|---|---|
| Function Header | `define function !!name(!arg is TYPE) is RET_TYPE` | Must start with `!!` |
| Void Function | `define function !!name(!arg is TYPE)` | No `is RET_TYPE` clause |
| Return Statement | `return !returnValue` | Mandatory if return type declared |
| Early Void Return | `return` | Allowed in void functions |
| Stored Filename | `name.pmlfnc` | Always strictly lowercase |

## Key Takeaways
1. Standalone PML 2 functions are defined in `<name>.pmlfnc` files inside a `PMLLIB` directory.
2. Function names must be global (`!!name`) and match the lowercase file basename.
3. Method chaining allows concise object navigation: `!ce.position.string()`.
4. Always validate `!!CE.type` when functions operate on the current 3D element.

## Connects To
- **Ch 1**: PML Basics & PMLLIB Resolution
- **Ch 2**: Variables, Data Types & Scope
- **Ch 6**: User-Defined Objects (UDOs)
- **Ch 7**: Core System Objects
