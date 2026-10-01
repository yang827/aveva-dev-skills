# Chapter 1: PML Overview & Runtime Environment

## Core Idea
AVEVA Programmable Macro Language (PML) is an interpreted scripting language operating within AVEVA Plant (PDMS, E3D) and AVEVA Marine (Marine 12 Series). It bridges user commands, graphical user interface (GUI) definitions, and DABACON engineering databases.

## Frameworks Introduced
- **PML Architecture Split (PML 1 vs PML 2)**:
  - PML 1: Macro-based command substitution (`.mac`), positional parameters (`$1`–`$9`), `$GOTO` / `$LABEL` jumps, untyped string variables.
  - PML 2: Strongly-typed, object-oriented language introduced in PDMS 11.5 / Marine 12 (`.pmlfnc`, `.pmlobj`, `.pmlfrm`), supporting methods, user-defined objects, structured control flow, and dynamic runtime loading.
- **PMLLIB Search & Resolution Framework**:
  - Runtime loads functions, objects, and forms on-demand by scanning directories listed in the `PMLLIB` operating system environment variable.
  - The index is populated into memory using the command `pml rehash all`.
  - File naming rule: Lowercase filename matching the definition: `<name>.pmlfnc`, `<name>.pmlobj`, `<name>.pmlfrm`.
- **Command Stream Interaction Framework**:
  - The command processor receives commands as strings. PML variables must be expanded with `$` in PML 1 contexts or passed as typed expressions in PML 2.

## Key Concepts
- **`PMLLIB`**: OS environment variable defining a semicolon-separated (Windows) or space-separated search path for PML 2 source files.
- **`pml rehash all`**: Essential command processor directive that forces PML to rescan all directories in `PMLLIB` and rebuild its internal method/form index cache.
- **Macro (`.mac`)**: A sequence of AVEVA commands executed via `$m /path/to/macro.mac [args]`.
  - Supports up to 9 parameters (`$1` to `$9`). Default parameters set via `$d1=val`.
  - String parameters with spaces must be enclosed in `$<` and `$>`.
- **Synonyms (`$S`) (TM-2263 Chapter 3.5 - 3.7)**:
  - Command aliases created via `$S<Alias>=<Command>` (e.g., `$SNewBox=NEW BOX XLEN 100 YLEN 200 ZLEN 300`).
  - Parameterised synonyms use `$S1`, `$S2`, etc. (e.g., `$SMakeBox=NEW BOX XLEN $S1 YLEN $S2`).
  - Multi-command recursion separated by `$/` (newline).
  - Deleting a synonym: `$S<Alias>=`. Kill all: `$SK`.
  - Disable / enable synonyms: `$S-` (disable) and `$S+` (re-enable).
- **`$P` Directive**: Command processor output directive printing text directly to the console or Request window (`$P Message text`).
- **Comment Syntax**: `--` denotes a PML 2 line comment; `$*` denotes a PML 1 comment line.

## Mental Models
- **Think of PMLLIB as the PATH of AVEVA PML**: Any file placed in a PMLLIB directory is immediately discoverable once indexed via `pml rehash all`.
- **Use Macros for linear automation, PML 2 for applications**: Macros are linear command streams; PML 2 provides encapsulation, objects, and GUI event handling.

## Anti-patterns
- **Forgetting `pml rehash all`**: Editing or adding a `.pmlfrm` or `.pmlfnc` file on disk without issuing `pml rehash all` will cause AVEVA to execute obsolete cached definitions or report missing definitions.
- **Filename Case Mismatch**: Naming a form `!!MyForm` in code but saving it as `MyForm.pmlfrm` instead of `myform.pmlfrm` (PML loader requires lowercase filenames).
- **Using `$GOTO` in PML 2**: Using `$GOTO` and `$LABEL` inside a PML 2 function or method corrupts the call stack; use `DO`, `BREAK`, and `IF` instead.

## Code Examples
```pml
-- ================================================================
-- Example: Parameterised Macro with Defaults (c:\pml\sample.mac)
-- Run via: $m c:\pml\sample.mac 150 300
-- ================================================================
$d1=100
$d2=200

$P Creating Equipment with Length $1 and Width $2
NEW EQUI /SAMPLE-EQUI-$1
NEW BOX
  XLEN $1
  YLEN $2
  ZLEN 100
$P Equipment successfully created at $!ce
```
- **What it demonstrates**: Macro parameter defaulting (`$d1=`), command processor text output (`$P`), variable expansion (`$1`), and current element reference (`$!ce`).

## Reference Tables
| Concept | PML 1 | PML 2 |
|---|---|---|
| File Extensions | `.mac` | `.pmlfnc`, `.pmlobj`, `.pmlfrm` |
| Variable Syntax | `$!var`, `$1`–`$9` | `!var` (local), `!!var` (global) |
| Comments | `$* comment` | `-- comment` |
| Function Definition | Not supported (call macro) | `define function <name>(...)` |
| Form Definition | Not supported | `setup form !!<name> ...` |
| Indexing Required | None (direct path) | `pml rehash all` via `PMLLIB` |

## Key Takeaways
1. Always configure `PMLLIB` to include your working PML directory before launching AVEVA Marine/Plant.
2. Execute `pml rehash all` whenever files in `PMLLIB` are added, renamed, or modified.
3. Keep all `.pmlfnc`, `.pmlobj`, and `.pmlfrm` filenames strictly lowercase.
4. Separate pure macro scripts (`.mac`) from reusable functions (`.pmlfnc`) and GUI definitions (`.pmlfrm`).

## Connects To
- **Ch 2**: Variables, Data Types & Scope
- **Ch 5**: PML 2 Functions & Methods
- **Ch 8**: Forms & GUI Customisation
- **Ch 16**: Upgrading from PML 1 to PML 2
