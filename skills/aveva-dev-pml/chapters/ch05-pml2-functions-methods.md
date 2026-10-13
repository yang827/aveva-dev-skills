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
  - **Always double-bang the Current Element.** `!ce` (one bang) is a separate local variable, `unset` unless assigned in the current scope. Either use `!!ce.xxx` directly, or snapshot first — `!ce = !!ce` — and only then use `!ce.xxx` (delivered idiom, e.g. `aba/Objects/abadrawings.pmlobj`: `!ce = !!ce` then `!ce.type`). A method reading `!ce.type` with no prior `!ce` assignment is a defect (SKILL.md Core Framework 11). Name case is irrelevant (`!!CE` = `!!ce`); only bang count matters.

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

## No `null` Keyword — "Empty" Returns by Type (MANDATORY)

**PML has no `null`, `nil`, or `None` literal — and no `.null()` method on any type.** `return` must be followed by an expression, and `null` is not one: writing `return null` aborts compilation with `CP: Syntax error` pointing at the offending token (`return ^^NULL`). Calling `!x.null()` compiles but fails at runtime with `Method <STRING>.NULL() not found` (or the caller's actual type) — no PML type, `STRING` included, defines a `null()` method. Do not import `null`/`None`/`.null()` habits from Java, C#, JavaScript, or Python.

**The phrase "return null" exists only in English `--` comments of the delivered PMLLIB source — never in executable code.** Grepping for it yields comment lines such as `-- When called with null string, then return null string` in `mds/draft/functions/MdsGetAlias.pmlfnc`, whose actual statement is `return ''`. Never infer syntax from comment prose.

### Returning "nothing" / an empty value, by declared return type
| Declared type | Idiom | Meaning | Delivered-source example |
|---|---|---|---|
| `is STRING` | `return ''` | Empty-string sentinel value | `mds/draft/functions/MdsGetAlias.pmlfnc` |
| `is STRING` | `return object STRING()` | Unset STRING; caller tests `!ret.unset()` | `design/forms/componentorioff.pmlfrm` |
| `is DBREF` | `return object DBREF()` | Null DBREF (nullref); caller tests `.unset()` / `badRef()` | `design/objects/aslinstance.pmlobj`, `common/functions/dtbmemberoftype.pmlfnc` |
| `is ARRAY` | `return object ARRAY()` | Unset/empty array | `admin/functions/adminfiltersort.pmlfnc` |
| `is REAL` | `object REAL()` for an unset REAL; otherwise a documented numeric sentinel | Unset REAL | `design/objects/componentpspool.pmlobj` (assignment form) |

- Returning a value from inside a `handle ... endhandle` recovery block is **legal** and used by delivered code — e.g. `return object DBREF()` inside `handle any` in `aslinstance.pmlobj` — but the value must follow the per-type table above.

### Testing for "empty" / "no value" at the call site (the anti-`.null()` table)
`.null()` does not exist — `if (!model.null())` raises `Method <STRING>.NULL() not found` at runtime. Use the idiom matching what "empty" means:

| Condition to test | Valid idiom | Delivered-source example |
|---|---|---|
| Object / `DBREF` / `ARRAY` / gadget is unassigned | `if (!x.unset()) then` | 340+ sites, e.g. `design/functions/cblautoname.pmlfnc`, `common/functions/projectinfoattr.pmlfnc` |
| Variable was never defined in this scope | `if (undefined(!x)) then` | `common/functions/modulemenus.pmlfnc` |
| STRING holds the empty string | `if (!s.eq('')) then` | `mds/draft/functions/MdsGetAlias.pmlfnc` (`!type.trim().eq('')`) |
| Unset **or** blank string | `if (!x.unset() or !x.string() eq '') then` | ch19 recipe (`!posno.unset() or !posno.string() eq ''`) |
| `DBREF` points at a dead/nonexistent element | `if (!ref.badRef()) then` | Ch 13, Ch 17 |

- **Receiver caution**: delivered `.unset()` calls sit on objects, `DBREF`s, `ARRAY`s, and results such as `object STRING()` — for a plain already-assigned `STRING` variable prefer `.eq('')` or `undefined(!x)` so the check itself cannot raise a method-not-found error.
- Never compare with a null literal: `!x eq null` is the same compile error family — use the table above.

### `null` Misuse Review Rule (code audit)
Scan generated PML for `null`, `NULL`, `nil`, `None` in **executable tokens** (outside `--` and `$*` comments) in ALL forms — bare literal (`return null`), method call (`!x.null()`), and comparison (`!x eq null`): every occurrence is a defect. Replace the value with the empty idiom of the declared return type (table above) and the test with the call-site idiom (`.unset()` / `.eq('')` / `undefined()` / `.badRef()`).

## Mental Models
- **Think of `.pmlfnc` files as modular libraries**: Each function gets its own file. AVEVA loads it on first call and caches the compiled bytecode in memory.
- **Use `!!CE` defensively**: Never assume `!!CE` points to a specific element type; always inspect `!!CE.type` or test with `!!CE.badRef()` (or, after `!ce = !!ce`, with `!ce.badRef()` — the local only exists once assigned).

## Anti-patterns
- **Declaring a normal variable `is ANY`**: `!value is ANY` outside a parameter list is invalid; ANY exists only in formal-parameter (and documented return-type) declaration positions. For mixed-type storage use concrete types, `ARRAY`, or object design.
- **Generalising ANY from parameters to variables**: Because an ANY formal parameter accepts different argument types at call sites, do not infer ordinary PML variables can hold or switch between arbitrary types — PML has no equivalent of C# `object` or generic `T`.
- **Putting Multiple Functions in a Single `.pmlfnc`**: Unlike C or Python, AVEVA PML 2 mandates **one function per `.pmlfnc` file**, with the filename exactly matching the function name.
- **Forgetting to Return a Value**: If a function is declared with `is <TYPE>`, reaching `endfunction` without executing a typed `return` statement raises a runtime execution error.
- **Global Variable Dependencies**: Relying on undeclared global variables inside functions reduces reusability; pass all needed inputs through parameters.
- **One-Bang Built-in Globals**: Writing `!ce.type`, `!alert.error(...)`, or `!edgCntrl.add(...)` in a scope that never assigned the local. Built-in globals (`!!CE`, `!!ALERT`, `!!edgCntrl`, ...) exist ONLY in double-bang form; a single-bang name is an unrelated unset local. Use `!!ce.xxx` directly or assign `!ce = !!ce` first (SKILL.md Core Framework 11).

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

### Form Method: Validating `!!CE` Before Use (double-bang required)
```pml
-- CE button callback: accept only SITE or ZONE as the source element
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
- **What it demonstrates**: Reading the Current Element strictly as the global `!!ce` (also correct: open the method with `!ce = !!ce`, then use `!ce.xxx`); `.type.upcase().eq(...)` guard (delivered style, e.g. `aba/Forms/abaviewlist.pmlfrm`); `!!alert.error` also double-banged. Writing `!ce.type` in a method that never assigned `!ce` reads an unset local and is a defect (SKILL.md Core Framework 11).

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
3. Method chaining allows concise object navigation: `!!ce.position.string()`.
4. Always validate `!!CE.type` when functions operate on the current 3D element.

## Connects To
- **Ch 1**: PML Basics & PMLLIB Resolution
- **Ch 2**: Variables, Data Types & Scope
- **Ch 6**: User-Defined Objects (UDOs)
- **Ch 7**: Core System Objects
