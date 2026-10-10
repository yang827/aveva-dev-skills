# Chapter 16: Upgrading from PML 1 to PML 2 & Best Practices

## Core Idea
Upgrading legacy PML 1 macros (`.mac`) to modern PML 2 (`.pmlfnc`, `.pmlobj`, `.pmlfrm`) replaces unstructured scripts with strongly-typed, object-oriented code. Understanding the shift in variable expansion rules, variable scoping, loop constructs, and character encoding (`transc.exe`) is vital for maintainable AVEVA engineering applications.

## Frameworks Introduced
- **PML 1 to PML 2 Migration Matrix**:
  - **Variable Expansion**:
    - PML 1: Requires dollar sign expansion everywhere (`$!var`).
    - PML 2: Native expression evaluation (`!var`), reserving `$` strictly for string command line injection.
  - **Scope Isolation**:
    - PML 1: All variables are effectively global across nested macro invocations unless explicitly overwritten.
    - PML 2: Strict lexical encapsulation. Local variables (`!var`) exist only within their declaring block; globals (`!!var`) must be explicitly declared.
  - **Control Flow Modernization**:
    - PML 1: Relied on unstructured `$GOTO /LABEL` jumps.
    - PML 2: Structured `DO ... VALUES`, `DO ... INDEX`, and `BREAK IF (!cond)`.
- **Character Encoding & UTF-8 BOM Standard (`transc.exe`)**:
  - AVEVA Marine and Plant 12 Series require macro files with special or international characters to be encoded as **UTF-8 with Byte Order Mark (BOM)**.
  - AVEVA provides the `transc.exe` command-line utility to batch transcode legacy ANSI/ASCII files into compliant UTF-8 BOM.
- **Performance Optimization Framework**:
  - Avoid executing heavy database navigation inside tight UI event loops.
  - Use scoped collections (`!coll.scope(!!CE)`) rather than unfiltered global scans.
  - Clear large arrays (`!arr.clear()`) when no longer needed to release memory.

## Key Concepts
- **`transc.exe`**: AVEVA command-line utility transcoding PML source files to UTF-8 with BOM.
- **Dollar Prefix Confusion (`$` vs direct variable)**:
  - In PML 2: `!a = !b + 10` (Direct evaluation, typed).
  - In command strings: `NEW BOX XLEN $!length` (Dollar sign expands variable value into command string).
- **`pml rehash all` Routine**: Mandatory developer habit after modifying any file in `PMLLIB`.
- **Encapsulation**: Moving logic from ad-hoc `.mac` scripts into testable `.pmlfnc` subroutines and `.pmlobj` classes.

## Mental Models
- **Never use `$` inside a PML 2 mathematical expression**: Writing `!x = $!y + 1` converts `!y` to a string before parsing, creating unnecessary overhead and subtle type errors; write `!x = !y + 1`.
- **Think of PML 1 as a terminal recording, PML 2 as a software architecture**: PML 1 replays keystrokes; PML 2 creates durable, scalable applications.

## Anti-patterns
- **Leaving Spaghetti `$GOTO` in Migrated Code**: Retaining `$GOTO` and `$LABEL` inside PML 2 functions causes unpredictable stack corruption; refactor to `DO` loops and `IF` blocks.
- **Saving UTF-8 Files Without BOM**: Saving PML files in UTF-8 without BOM causes AVEVA's PML loader on Windows to misread non-ASCII characters or fail parsing.
- **Accidental Global Variable Leaks**: Forgetting to prepend `!` to a local variable turns it into an invalid command or pollutes scope; always prefix local variables with `!`.

## Code Examples
```pml
-- ================================================================
-- Comparison: Legacy PML 1 Macro vs Modern PML 2 Function
-- ================================================================

-- ----------------------------------------------------------------
-- BEFORE: Legacy PML 1 (c:\pml\legacy_pipe.mac)
-- ----------------------------------------------------------------
-- $d1=100
-- $!dia = $1
-- $IF ($!dia GT 500) $GOTO /BIGPIPE
-- $P Small pipe branch
-- NEW PIPE /PIPE-SMALL-$!dia
-- $GOTO /END
-- $LABEL /BIGPIPE
-- $P Large pipe branch
-- NEW PIPE /PIPE-LARGE-$!dia
-- $LABEL /END

-- ----------------------------------------------------------------
-- AFTER: Modern PML 2 (createpipebranch.pmlfnc)
-- ----------------------------------------------------------------
define function !!createPipeBranch(!dia is REAL) is STRING
  -- Validate input
  if (!dia LE 0.0) then
    return error 1 'Pipe diameter must be greater than zero.'
  endif

  !pipeName = ''
  if (!dia GT 500.0) then
    $P Large pipe branch detected.
    !pipeName = '/PIPE-LARGE-' & !dia.string()
  else
    $P Standard pipe branch detected.
    !pipeName = '/PIPE-SMALL-' & !dia.string()
  endif

  -- Create database element safely
  NEW PIPE $!pipeName
  HANDLE (41, 12)
    $P Error: Pipe name $!pipeName already exists.
    return ''
  ENDHANDLE

  return !pipeName
endfunction
```
- **What it demonstrates**: Side-by-side refactoring of legacy `$GOTO`, `$LABEL`, and `$d1=` into a structured, type-checked PML 2 function with `HANDLE` exception trapping and return values.

## Reference Tables
| Feature | Legacy PML 1 | Modern PML 2 |
|---|---|---|
| File extension | `.mac` | `.pmlfnc`, `.pmlobj`, `.pmlfrm` |
| Calling mechanism | `$m /path/macro.mac 100` | `!res = !!myFunction(100)` |
| Jumps / Control | `$GOTO /LABEL` | `DO ... ENDDO`, `BREAK IF` |
| Variable dereference | Always `$!var` | `!var` in code, `$!var` in commands |
| Error trapping | Basic `HANDLE` | Structured `HANDLE ... ELSEHANDLE` |
| Object-orientation | None | Full UDO support (`.pmlobj`) |
| Character Encoding | ANSI / ASCII | UTF-8 with BOM (`transc.exe`) |

## Key Takeaways
1. Eliminate all `$GOTO` and `$LABEL` constructs when upgrading to PML 2; replace with `DO` and `BREAK IF`.
2. Do not use `$` when assigning or evaluating variables in PML 2 expressions (`!a = !b + 1`).
3. Ensure all files with extended characters are saved with a UTF-8 BOM or converted via `transc.exe`.
4. Guard every database mutation with a localized `HANDLE ... ELSEHANDLE` block placed immediately **after** the mutation command — the mutation stays outside the trap; recovery code goes inside it (see SKILL.md Core Framework 9).

## Connects To
- **Ch 1**: PML Basics & Environment
- **Ch 3**: Control Flow & Logic
- **Ch 4**: Error Handling & Debugging
- **Ch 5**: PML 2 Functions & Methods
