# Chapter 15: Pseudo Attributes

## Core Idea
Pseudo Attributes are computed, virtual, or contextual attributes evaluated on the fly by the AVEVA database engine; they do not occupy static database storage, but provide essential derived geometric, topological, and administrative information through standard query syntax.

## Frameworks Introduced
- **Dynamic Geometric & Spatial Derivation Framework**:
  - When to use: Querying world coordinates, projected bounding boxes, cut lengths, elevations, and transformed axes of elements without manual vector math.
  - How: The database engine calculates coordinates dynamically relative to the specified coordinate frame. Queries like `POS WRT /*` (Position With Respect to World) or `CRFA` (Centerline Relative to Father) resolve instantaneous spatial locations.
- **Topological & Connectivity Traversal Model**:
  - When to use: Navigating pipeline sequences, branch connections, and component flow ports.
  - How: Pseudo attributes like `ARRI` (Arrive P-point), `LEAV` (Leave P-point), `CREF` (Connection Reference), `CRFA`, and `CLOSEFLAG` inspect connection graphs dynamically.

## Key Concepts
- **Pseudo Attribute**: An attribute whose value is computed dynamically upon request rather than stored statically on disk.
- **`CRFA` (Coordinates Relative to Father)**: Position of an element expressed relative to its owning parent's origin and orientation.
- **`CRWO` (Coordinates Relative to World)**: Absolute global coordinates in the plant coordinate system.
- **`BBOX` (Bounding Box)**: Dynamic 3D cuboid enclosing all constituent geometry of an element.
- **`CUTL` (Cut Length)**: Computed fabrication length of straight pipe (`TUBI`) or structural steel section (`SCTN`) accounting for end preps and bevels.
- **`WVOL` (World Volume)**: Computed spatial displacement volume.
- **`ARRI` / `LEAV`**: Integer designations of the active arrive and leave P-points governing flow direction through a piping component.
- **`ALIST` (Attribute List)**: Dynamic list of all valid attributes supported by the current element type.
- **`CLOSEFLAG`**: Logical flag indicating whether a branch forms a closed fluid circuit.

## Mental Models
- **Think of Standard Attributes as "Fields in a Table" and Pseudo Attributes as "Stored Functions / Virtual Properties"**: Querying `Q POS` retrieves the stored local vector; querying `Q POS WRT /*` invokes dynamic matrix multiplication across parent frames.
- **Use "Query With Respect To (`WRT`)"**: Combine pseudo attributes with `WRT <ref>` to evaluate spatial metrics in any coordinate frame.

## Anti-patterns
- **Attempting to Write / Assign to Read-Only Pseudo Attributes**: Executing `CUTL 1200` fails because cut length is calculated from end-point coordinates, not statically assigned.
- **Overusing Heavy Volumetric Pseudo Queries in Massive Loops**: Querying `WVOL` or complex bounding boxes inside a loop of 50,000 components degrades macro performance; query simple bounding points where possible.

## Code Examples
```pml
-- Spatial and Coordinate Pseudo Attributes
Q POS WRT /*
-- World position (E, N, U)
Q POS WRT /P-101A
-- Position relative to specific equipment
Q CUTL
-- Computed cut length of pipe or steel section
Q BBOX
-- Bounding box dimensions

-- Connectivity and Flow Pseudo Attributes
Q ARRI
-- Returns arrive P-point number (e.g. 1)
Q LEAV
-- Returns leave P-point number (e.g. 2)
Q CREF
-- Element connected to active component port
Q CLOSEFLAG
-- Returns TRUE if branch loop is closed

-- Administrative and Schema Pseudo Attributes
Q ALIST
-- Returns array of all valid attributes on CE
Q SESSIONS
-- Lists session history
Q CLAIMSTATUS
-- Returns current multi-write claim state
```
- **What it demonstrates**: Essential pseudo attribute queries used in PML macros and engineering reports.

## Reference Tables
| Pseudo Attribute | Data Type | Applicable Elements | Calculation / Meaning |
|:---|:---|:---|:---|
| `CRFA` | Position | All secondary elements | Position relative to owning parent |
| `CUTL` | Real | `TUBI`, `SCTN` | Exact fabrication cut length |
| `BBOX` | Real array (6) | All 3D elements | Minimum/Maximum X, Y, Z spatial extents |
| `ARRI` | Integer | Piping / HVAC fittings | Arrive connection P-point number |
| `LEAV` | Integer | Piping / HVAC fittings | Leave connection P-point number |
| `CREF` | Element Ref | Nozzles, Components | Directly mated connection element |
| `CLOSEFLAG` | Logical | `BRAN` | True if branch terminates at head |
| `HDIR` / `TDIR`| Direction | `BRAN` | Head and Tail connection vectors |
| `WVOL` | Real | Primitives, Components | Geometric enclosed volume |
| `ALIST` | Array | All elements | Complete list of permissible attributes |

## Worked Example
Writing a PML macro to calculate total pipe spool cutting lengths:
1. Macro navigates to branch `/100-P-1001-A1/B1`.
2. Collects all straight pipe members:
   ```pml
   !tubes = EVALUATE (ALL TUBI FOR CE)
   !totalCutLength = 0
   DO !t VALUES !tubes
     !ce = !t
     -- Evaluates dynamic cut length pseudo attribute
     !len = !ce.CUTL
     !totalCutLength = !totalCutLength + !len
   ENDDO
   $P Total cut length required: $!totalCutLength mm
   ```
3. The engine computes exact cut lengths considering fitting engagement lengths at every elbow and flange without manual subtraction.

## Key Takeaways
1. Pseudo attributes are dynamically evaluated by the AVEVA core engine upon request.
2. They do not occupy static database disk space.
3. Provide high-level geometric conversions (`POS WRT /*`, `BBOX`, `CUTL`) and connectivity analysis (`ARRI`, `LEAV`, `CREF`).
4. Read-only: cannot be modified directly via assignment syntax.

## Connects To
- **Ch 4 (Design Database)**: Evaluated extensively against 3D physical elements.
- **Ch 16 (Introduction to Attributes)**: Complements standard stored attributes.
