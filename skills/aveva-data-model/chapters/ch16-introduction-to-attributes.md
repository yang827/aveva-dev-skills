# Chapter 16: Introduction to Attributes

## Core Idea
Attributes constitute the fundamental data storage mechanism in AVEVA databases, providing a strongly typed, standardized taxonomy of General, Special, and User-Defined properties that govern geometry, connectivity, materials, and administrative state.

## Frameworks Introduced
- **Attribute Classification & Typology Framework**:
  - When to use: Designing data structures, reading properties, and setting values via PML or macros.
  - How: Attributes are divided into three fundamental classes:
    1. **General Attributes**: Common across nearly all elements (e.g. `NAME`, `TYPE`, `OWNER`, `POS`, `ORI`, `LOCK`).
    2. **Special Attributes**: Exclusive to specific disciplines or element types (e.g. `BORE`, `TEMP`, `PRESS`, `HBOR`, `TBOR`, `STYP`).
    3. **User-Defined Attributes (UDAs)**: Project-specific extensions prefixed with a colon (`:STRESS_REV`, `:PO_NUM`).
- **Strongly Typed Data Encoding Model**:
  - When to use: Formatting inputs and validating query outputs in automation scripts.
  - How: Values strictly adhere to internal types: Name, Real, Integer, Logical, Text/String, Reference, Word, Position, Orientation, and Direction.

## Key Concepts
- **`NAME` Attribute**: Leading slash string (e.g. `/PIPE-101`) uniquely identifying an element across the database.
- **Reference Attribute (`REF`)**: System-managed pointer to another database element, formatted internally as `=db/elem` (e.g. `=1412/2045`).
- **Position Attribute (`POS`)**: 3D Cartesian coordinates expressed along Easting, Northing, and Elevation axes (`E 1000 N 2000 U 500`).
- **Orientation Attribute (`ORI`)**: Rotational attitude defined by two orthogonal axes (`Y IS N AND Z IS U`).
- **Direction Attribute (`DIR`)**: Single spatial vector (`N`, `S`, `E`, `W`, `U`, `D` or angle combinations like `E 45 N`).
- **Word Attribute**: System-enumerated keyword selected from a restricted vocabulary (e.g. connection types `FBD`, `BW`, `SC`).
- **Logical Attribute**: Boolean values (`TRUE` or `FALSE`).
- **Lock Attribute (`LOCK`)**: Administrative flag preventing accidental editing or deletion (`TRUE` / `FALSE`).

## Mental Models
- **Think of an Element as a Key-Value Dictionary Governed by a Schema**: The element type determines which keys are valid, and the attribute definitions enforce strict data typing on every value.
- **Use "Names for Humans, References for Code"**: Element names can change, but internal reference numbers (`=db/elem`) are permanent; use references in robust automation macros.

## Anti-patterns
- **Using Unquoted Strings for Names**: Omitting the leading slash `/` when assigning names causes the system to interpret the string as a command or variable.
- **Mixing Up Coordinate Frames in Orientation**: Specifying non-orthogonal orientation vectors (e.g. `Y IS N AND Z IS S`) causes mathematical contradiction and command failure.

## Code Examples
```pml
-- Setting diverse strongly typed attributes
-- Name attribute (starts with /)
NAME /PUMP-101A
-- Text attribute (single quotes)
DESC 'Main Sea Water Pump'
-- Real attribute
TEMP 65.5
-- Logical attribute
LOCK TRUE

-- Setting spatial coordinates and directions
-- Position attribute
POS E 15000 N 32000 U 1200
-- Orientation attribute
ORI Y IS N AND Z IS U
-- Direction attribute
DIR E 30 N

-- Querying and setting reference attributes
-- Reference attribute
CATREF /FLAN-150-RF
Q CATREF
-- Returns =2105/4502 (/FLAN-150-RF)
```
- **What it demonstrates**: Proper syntax for assigning and querying all fundamental attribute types in AVEVA.

## Reference Tables
| Attribute Data Type | Syntactic Format | Example Representation | Engineering Use Case |
|:---|:---|:---|:---|
| **Name** | Starts with `/` (max 51 chars) | `/100-P-1001-A1` | Unique element tag / identifier |
| **Reference** | System ID `=db/elem` or `/NAME` | `=2401/105` or `/MAT-A106` | Pointers to catalogue or specs |
| **Real** | Floating point decimal | `150.0`, `-25.4` | Dimensions, bore, temperature |
| **Integer** | Whole number | `1`, `4`, `16` | Bolt counts, P-point indices |
| **Logical** | `TRUE` or `FALSE` | `TRUE` | Status flags, locks, built flags |
| **Text** | Single quoted string | `'Stainless Steel 316L'` | Descriptions, notes, remarks |
| **Word** | Alphanumeric keyword | `FBD`, `BW`, `EQUI`, `INCL` | Connection types, categories |
| **Position** | 3D coordinate triplet | `E 1000 N 2000 U 500` | Physical 3D spatial location |
| **Orientation** | Two orthogonal axis vectors | `Y IS N AND Z IS U` | 3D rotational posture in space |
| **Direction** | Single vector | `N 45 E`, `D`, `U` | Flow direction, nozzle axis |

## Worked Example
Inspecting and validating a nozzle's attributes for spec compliance:
1. Navigate to nozzle: `/P-101A-N1`.
2. Inspect core attributes:
   ```pml
   Q TYPE
   -- NOZZ (Word)
   Q OWNER
   -- =2401/100 (/P-101A) (Reference)
   Q POS
   -- E 10500mm N 20000mm U 600mm (Position)
   Q ORI
   -- Y IS N AND Z IS U (Orientation)
   Q BORE
   -- 150mm (Real)
   Q TEMP
   -- 85.0 (Real)
   Q PRESS
   -- 16.0 (Real)
   Q LOCK
   -- TRUE (Logical)
   ```
3. Verify that temperature and pressure are within pump design thresholds.

## Key Takeaways
1. Attributes are strongly typed values bound to specific element schemas.
2. Divided into General (universal), Special (discipline-specific), and User-Defined (prefixed with `:`).
3. Spatial attributes (`POS`, `ORI`, `DIR`) use standardized engineering compass directions and elevations.
4. Internal references (`=db/elem`) guarantee persistent connectivity even if element names change.

## Connects To
- **Ch 4 (Design Database)**: Core attributes define 3D physical modeling.
- **Ch 5 (Dictionary Database)**: Dictionary defines custom User-Defined Attributes (`UDAs`).
- **Ch 15 (Pseudo Attributes)**: Complements stored attributes with derived runtime calculations.
