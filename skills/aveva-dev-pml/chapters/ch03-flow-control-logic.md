# Chapter 3: Control Flow & Logic

## Core Idea
Control flow in PML 2 is structured around deterministic `DO` loops and `IF ... ELSEIF ... ELSE ... ENDIF` conditionals. PML 2 strictly avoids unstructured jumps (`$GOTO`), relying on explicit loop termination commands (`BREAK`, `BREAK IF`) and cycle skips (`SKIP`, `SKIP IF`). In contrast, legacy PML 1 macros relied on label jumps, synonyms (`$S`), and terminal stream redirection (`OUTPUT`).

## Frameworks Introduced

### 1. Structured Iteration Framework
* **Counted Loop**: `DO !counter FROM <start> TO <end> [BY <step>] ... ENDDO`
* **Values Loop**: `DO !element VALUES !array ... ENDDO` (iterates over elements directly)
* **Index Loop**: `DO !idx INDEX !array ... ENDDO` (iterates from 1 to `!array.size()`)
* **Condition-Driven Loop**: Open `DO ... ENDDO` terminated via `BREAK IF (!condition)`

### 2. Loop Interruption & Bypass Rules
* `BREAK` immediately terminates the enclosing `DO` loop.
* `BREAK IF (!condition)` evaluates a boolean expression and terminates if true.
* `SKIP` aborts the current iteration and advances to the next step.
* `SKIP IF (!condition)` conditionally advances to the next step.

### 3. Conditional Branching Framework
* `IF (!condition) THEN ... ELSEIF (!condition) THEN ... ELSE ... ENDIF`
* Must always terminate with `ENDIF`. Every `IF` and `ELSEIF` **must** include `THEN`.

### 4. Synonyms & Macro Redirection (TM-2263 Chapter 3)
* **Synonyms (`$S`)**: Command aliases that substitute tokens before macro parsing.
  * Definition: `$S <new_command> <target_command>` (e.g. `$S PUMP NEW EQUI /PUMP-101`)
  * Recursive Synonyms: A synonym can refer to another synonym, expanded recursively up to the system nesting depth.
  * Deleting Synonyms: `KILL SYNONYM <name>` removes the alias.
* **Terminal Stream Redirection (`OUTPUT`)**:
  * Redirecting output to file: `OUTPUT /C:\temp\report.txt OVERWRITE` or `OUTPUT /path APPEND`
  * Resetting back to screen: `OUTPUT SCREEN`

### 5. Legacy PML 1 Branching & Labels (TM-2263 Chapter 5)
* In PML 1 macros (`.mac`), jumps are implemented via labels:
  * `$LABEL /MY_TARGET`
  * `$GOTO /MY_TARGET`
  * Conditional Jump: `$IF (condition) $GOTO /MY_TARGET`
* **PML 2 Restriction**: `$GOTO` and `$LABEL` are **illegal** inside PML 2 functions (`.pmlfnc`) and object methods (`.pmlobj`); structured `IF` and `DO` blocks must be used.

---

## Key Concepts
* **`DO ... ENDDO`**: The universal loop block in PML.
* **`BREAK IF (!condition)`**: The canonical AVEVA PML mechanism for conditional and while-style loop termination.
* **`SKIP IF (!condition)`**: Equivalent to `continue` in other languages; jumps immediately to the next iteration.
* **`VALUES` vs `INDEX`**: `VALUES` binds the current array element directly to the loop variable; `INDEX` binds the integer sequence index (1, 2, 3...).
* **Operator Precedence**: Arithmetic (`*`, `/`, `+`, `-`) executes before relational comparisons (`EQ`, `NE`, `LT`, etc.), which execute before logical operators (`NOT`, then `AND`, then `OR`).

---

## Code Examples

### Structured Loops and Conditionals in PML 2
```pml
-- ================================================================
-- Example: Structured Loops and Conditionals in PML 2
-- ================================================================

-- 1. Stepped Counted Loop
DO !i FROM 1 TO 20 BY 2
  $P Processing odd step $!i
ENDDO

-- 2. Open Loop with Guarded Break (PML equivalent to while loop)
!n = 1
DO
  !square = POW(!n, 2)
  BREAK IF (!square GT 100)
  $P Current square: $!n squared = $!square
  !n = !n + 1
ENDDO

-- 3. Array Traversal via VALUES and SKIP IF
!pipeNames = ARRAY()
!pipeNames.append('PIPE-01')
!pipeNames.append('SKIP-ME')
!pipeNames.append('PIPE-02')

DO !p VALUES !pipeNames
  -- Skip unwanted elements
  SKIP IF (!p.substring(1, 4) EQ 'SKIP')
  $P Active pipe in process: $!p
ENDDO

-- 4. Multi-branch IF Construct
!pressure = 14.5
if (!pressure GT 20.0) then
  $P High pressure alert!
elseif (!pressure GT 10.0 and !pressure LE 20.0) then
  $P Normal operating pressure.
else
  $P Low pressure condition.
endif

-- 5. Terminal Stream Output Redirection
OUTPUT /C:\temp\audit_log.txt OVERWRITE
$P --- BEGIN PML AUDIT LOG ---
$P Timestamp: $!now
OUTPUT SCREEN
$P Output restored to standard terminal.
```

---

## Anti-patterns
* **Attempting to use `while (...)` or `do while (...)`**: Neither construct exists in PML 2. Using `do while` causes a syntax error; use `DO ... BREAK IF (...) ... ENDDO`.
* **Using modern shorthand (`!i++`, `!i += 1`)**: PML 2 only supports explicit assignment (`!i = !i + 1`).
* **Omitting `THEN`**: Every `IF` and `ELSEIF` clause **must** be followed by `THEN`.
* **Using `$GOTO` in PML 2**: Calling `$GOTO` inside a `.pmlfnc` or `.pmlobj` file throws compilation errors.

## Reference Tables
| Loop / Jump Construct | Syntax | Purpose |
|---|---|---|
| Counted Range | `DO !i FROM 1 TO 10 [BY 2]` | Fixed numerical range iteration |
| Array Values | `DO !item VALUES !array` | Iterates directly over array elements |
| Array Indices | `DO !idx INDEX !array` | Iterates over indices (1..size) |
| Conditional Break | `BREAK IF (!cond)` | Bounded dynamic execution |
| Skip Iteration | `SKIP IF (!cond)` | Advance directly to next cycle |
| Synonym Definition | `$S<alias>=<command>` | Command shortcut definition (TM-2263 3.5) |
| Parameterised Synonym | `$S<alias>=<cmd> $S1 $S2` | Parameterised macro shortcut |
| Delete Single Synonym | `$S<alias>=` | Removes specific synonym alias |
| Kill All Synonyms | `$SK` | Removes all synonyms from session |
| Disable/Enable Synonyms | `$S-` / `$S+` | Temporarily suspends or restores synonyms |
| Output Redirection | `OUTPUT <path> [OVERWRITE/APPEND]` | Directs output stream to disk |
| Output Reset | `OUTPUT SCREEN` | Restores output to console |

## Key Takeaways
1. PML 2 relies on structured `DO ... ENDDO` loops; there is no `while` loop keyword.
2. Terminate while-style loops using `BREAK IF (!condition)`.
3. Synonyms (`$S`) provide token aliasing, while `OUTPUT` redirects reporting streams.
4. Legacy `$GOTO` and `$LABEL` jumps are forbidden in PML 2 functions and methods.

## Connects To
* **Ch 2**: Variables, Data Types & Scope
* **Ch 4**: Error Handling & Debugging
* **Ch 5**: PML 2 Functions & Methods
* **Ch 16**: Upgrading from PML 1 to PML 2
* **Ch 20**: SCRM Appendix A — PML 1 Expressions & Functions Reference
