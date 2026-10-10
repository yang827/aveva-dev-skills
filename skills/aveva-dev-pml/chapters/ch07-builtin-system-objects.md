# Chapter 7: Core Built-in System Objects

## Core Idea
AVEVA PML provides foundational system objects in its runtime library covering file system I/O (`FILE`), numerical and unit formatting (`FORMAT`), 3D spatial geometry (`POSITION`, `DIRECTION`, `ORIENTATION`), and database navigation (`DBREF`).

## Frameworks Introduced
- **File System I/O Lifecycle (`FILE`)**:
  - Encapsulates OS file operations.
  - Lifecycle: Instantiate with path -> Open with mode (`READ`, `WRITE`, `APPEND`, `OVERWRITE`) -> Stream records (`readRecord()`, `writeRecord()`) -> Explicitly close (`closeFile()`).
- **3D Spatial Geometry Vector System**:
  - **`POSITION`**: Represents a 3D coordinate point in world or local element space. Supports coordinate queries (`.east`, `.north`, `.up`), relative transformations (`.wrt(!ref)`), and vector distances (`.distance(!pos2)`).
  - **`DIRECTION`**: Represents a 3D directional vector (e.g., `N 45 E`, `U`). Calculates spatial angles between vectors via `.angle(!dir2)`.
  - **`ORIENTATION`**: Represents a 3D rotation matrix specifying orientation axes (e.g., `Y is N and Z is U`).
- **Unit and Precision Formatting Framework (`FORMAT`)**:
  - Decouples raw internal numeric storage (standard SI / millimeters) from user-facing localized display strings (imperial feet/inches, decimal fractions).

## Key Concepts
- **`FILE`**: Object managing file access. Methods: `.exists()`, `.openFile(mode)`, `.readRecord()`, `.writeRecord(str)`, `.closeFile()`.
- **`POSITION`**: 3D spatial coordinate. Initialized via `object POSITION('E 1000 N 2500 U 500')` or from element attributes `!!CE.position`.
- **`DIRECTION`**: 3D orientation vector. Initialized via `object DIRECTION('E')` or query `!!CE.direction`.
- **`ORIENTATION`**: 3D coordinate frame orientation. Initialized via `object ORIENTATION('Y IS N AND Z IS U')`.
- **`FORMAT`**: Numerical formatter. Methods: `.precision(int)`, `.units(str)`, `.format(real)`.
- **`DBREF`**: Native pointer to a database entity. Built-in methods: `.badRef()`, `.type`, `.name`, `.owner`, `.mcount()`, `.attribute(name)`, `.pposition(num)`, `.pdirection(num)`.

## Mental Models
- **Always pair `openFile()` with `closeFile()`**: Unclosed file handles lock files on the Windows filesystem, preventing other processes or subsequent macro runs from accessing them.
- **Use `.wrt()` for relative coordinate transforms**: When reading a position, `!pos.wrt(!vesselRef)` transforms coordinates from world space into the local reference frame of the vessel.

## Anti-patterns
- **Forgetting to check EOF on File Reads**: Reading past the end of a file raises an error; always check loop conditions, or issue the read and let a `HANDLE` clause trail it (the read stays outside the trap — see SKILL.md Core Framework 9).
- **Hardcoding Coordinate String Formats**: Constructing position strings manually with raw string concatenation instead of using `POSITION` objects causes parsing errors when regional decimal settings differ.
- **Assuming `.badRef()` is False**: Never dereference attributes on a `DBREF` without checking `!ref.badRef()` first.

## Code Examples
```pml
-- ================================================================
-- Example 1: Robust File I/O for Exporting Equipment Names
-- ================================================================
!exportPath = 'C:\temp\equipment_report.txt'
!fileObj = object FILE(!exportPath)

-- Open file in OVERWRITE mode
!fileObj.openFile('OVERWRITE')
HANDLE ANY
  $P Error: Unable to open file $!exportPath for writing.
  return
ENDHANDLE

!fileObj.writeRecord('====================================')
!fileObj.writeRecord('AVEVA PML AUTOMATIC EXTRACTION REPORT')
!fileObj.writeRecord('====================================')

-- Collect all Equipment in Current Site
!site = !!CE
!fileObj.writeRecord('Parent Site: ' & !site.name)

-- Iterate through child zones and write records
!fileObj.writeRecord('Status: Complete')
!fileObj.closeFile()
$P Report written successfully to $!exportPath.

-- ================================================================
-- Example 2: 3D Spatial Geometry Calculations
-- ================================================================
!pos1 = object POSITION('E 1000 N 2000 U 0')
!pos2 = object POSITION('E 4000 N 6000 U 0')

!dist = !pos1.distance(!pos2)
$P 3D Distance between points: $!dist mm

!dir1 = object DIRECTION('N')
!dir2 = object DIRECTION('E')
!ang = !dir1.angle(!dir2)
$P Angle between North and East: $!ang degrees
```
- **What it demonstrates**: File creation, error-guarded opening, formatted string writing, file closure, `POSITION` distance calculations, and `DIRECTION` angle evaluation.

## Reference Tables
| Object | Primary Initialization | Key Methods |
|---|---|---|
| `FILE` | `object FILE(filepath)` | `.openFile()`, `.readRecord()`, `.writeRecord()`, `.closeFile()` |
| `FORMAT` | `object FORMAT()` | `.precision()`, `.units()`, `.format()` |
| `POSITION` | `object POSITION('E 0 N 0 U 0')` | `.east`, `.north`, `.up`, `.distance()`, `.wrt()`, `.string()` |
| `DIRECTION` | `object DIRECTION('N')` | `.angle()`, `.string()`, `.vector()` |
| `ORIENTATION` | `object ORIENTATION('Y IS N')` | `.matrix()`, `.string()`, `.wrt()` |
| `DBREF` | `!name.dbref()` / `!!CE` | `.badRef()`, `.type`, `.name`, `.owner`, `.mcount()`, `.attribute()` |

## Key Takeaways
1. The `FILE` object is the standard PML 2 mechanism for disk I/O; always close files in all code paths.
2. Use `POSITION` and `DIRECTION` objects for 3D calculations; avoid string-based math on coordinates.
3. Use `FORMAT` objects when converting real numbers into user-facing localized engineering units.
4. Check `!dbref.badRef()` before querying properties on database handles.

## Connects To
- **Ch 2**: Variables, Data Types & Scope
- **Ch 6**: User-Defined Objects
- **Ch 13**: Collections & Database Queries
- **Ch 17**: SCRM System Objects Catalog
