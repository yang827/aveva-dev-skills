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

## ANY Type Usage Restrictions (MANDATORY)

**ANY is a signature-position type specifier for functions and methods — NOT a general-purpose variable type.** When generating or modifying PML code, do not generalise "usable on formal parameters" into "any variable may be declared to hold any type".

### Allowed
1. **Formal parameters**: `ANY` may be used in a function or method parameter declaration so the routine accepts arguments of different types:
   ```pml
   define function !!ProcessValue(!value is ANY)
       $P $!value
   endfunction

   !text = 'PIPE-001'
   !number = 100

   !!ProcessValue(!text)
   !!ProcessValue(!number)
   ```
   Here `!value` is the formal parameter; `!text` and `!number` are the actual variables passed at the call site. `ANY` appears **only** in the formal-parameter type declaration position.
2. **Return types**: `ANY` may be used as a function return type **only where there is concrete evidence** that the signature supports it.

### Forbidden
3. **Never declare a normal variable as ANY.** Writing `!value is ANY` as a standalone variable declaration to create a "variable that can hold anything" is invalid. (What is forbidden here is the normal-variable-declaration position only; the same form in a formal-parameter declaration remains legal.)
4. **Never treat `ANY` as a universal type** usable at arbitrary syntactic positions such as variable declarations, assignments, or object creation.
5. **Never equate PML `ANY` with C# `object`, a generic type parameter `T`, or dynamic typing** from other languages.
6. **Never infer from ANY formal parameters that ordinary PML variables may change type during their lifetime.** A variable's type is determined when the variable is created.

### Handling "multiple input types" requirements
- Prefer evaluating an `ANY` formal parameter for the function.
- Inside the function, design the processing logic around the actual input type and the interfaces the target object actually supports.
- Never assume objects of different types necessarily expose the same attributes or methods.
- If the requirement is "one normal variable switching type during its lifetime", do **not** solve it by declaring an ANY variable. Choose a concrete type, an appropriate data container (e.g. `ARRAY`), an object design, or another scheme supported by PML.

### Generation & verification discipline
When generating PML code, keep three concepts strictly distinct:
- **Formal parameter type** — the type declared when defining a function or method.
- **Actual argument** — the value or variable supplied at the call site.
- **Variable type** — the type fixed when a normal variable is created.

Whenever an ANY-related requirement appears, first determine the syntactic position of the usage. If the legality of a syntax form cannot be confirmed, consult the official PML documentation for the specific AVEVA PDMS / E3D version or verify against real code — **never infer PML syntax from the habits of other programming languages**.

### ANY Misuse Review Rule (code audit)
Scan generated PML code for `is ANY` and judge each occurrence by its **syntactic position, not by keyword presence**:
- Occurrence in a formal-parameter declaration or a supported function return-type declaration → **legal; do NOT flag it**.
- Occurrence in a normal variable declaration → **flag as a defect to correct**: convert it into a legal formal-parameter declaration, a supported return-type declaration, or a concrete variable/object design matching the actual requirement.
A mere token hit on `ANY` is never sufficient grounds to report an error.

## Mental Models
- **Think of `.pmlfnc` files as modular libraries**: Each function gets its own file. AVEVA loads it on first call and caches the compiled bytecode in memory.
- **Use `!!CE` defensively**: Never assume `!!CE` points to a specific element type; always inspect `!!CE.type` or test with `!ce.badRef()`.

## Anti-patterns
- **Declaring a normal variable `is ANY`**: `!value is ANY` outside a parameter list is invalid; ANY exists only in formal-parameter (and documented return-type) declaration positions. For mixed-type storage use concrete types, `ARRAY`, or object design.
- **Generalising ANY from parameters to variables**: Because an ANY formal parameter accepts different argument types at call sites, do not infer ordinary PML variables can hold or switch between arbitrary types — PML has no equivalent of C# `object` or generic `T`.
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
