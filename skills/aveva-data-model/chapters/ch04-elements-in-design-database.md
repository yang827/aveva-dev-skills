# Chapter 4: Elements in the Design Database

## Core Idea
The Design Database (`DESI`) contains the entire 3D physical model of the plant, marine, or offshore facility, structured in an unambiguous administrative and spatial hierarchy containing equipment, piping, structural framing, HVAC, and electrical systems.

## Frameworks Introduced
- **Unified 3D Hierarchy Framework**:
  - When to use: Creating, positioning, and querying any physical asset in the model.
  - How: All physical models conform to the root-down schema:
    `WORL` -> `SITE` -> `ZONE` -> Discipline Assemblies (`EQUI`, `PIPE`, `STRU`, `HVAC`, `CABT`) -> Sub-assemblies (`SUBE`, `BRAN`, `FRMW`) -> Component Primitives (`NOZZ`, `BOX`, `CYLI`, `VALV`, `ELBO`, `SCTN`, `PANE`).
- **P-point Spatial Connectivity Model**:
  - When to use: Routing pipelines, HVAC ducts, connecting nozzles, and assembling structural members.
  - How: Components align and connect via P-points (`P0` through `Pn`). In pipelines, flow direction connects `PLEAVE` of component $k$ to `PARRIVE` of component $k+1$.
- **Primary vs. Secondary Element Distinction**:
  - When to use: Managing drawing limits, collision detection, and database clustering.
  - How: Primary elements (`EQUI`, `PIPE`, `STRU`) represent standalone engineering entities with unique tags. Secondary elements represent internal constituents that cannot exist without their primary owner.

## Key Concepts
- **`WORL` (World)**: Root element of the Design database.
- **`SITE`**: High-level geographic or project area (e.g., `/TOPSIDES`, `/HULL_SECTION_3`).
- **`ZONE`**: Functional or discipline sub-area within a site (e.g., `/PUMP_ROOM_PIPING`).
- **`EQUI` (Equipment)**: Mechanical equipment container (pumps, vessels, exchangers).
- **`NOZZ` (Nozzle)**: Equipment connection port with defined bore, rating, and P-point.
- **`PIPE` / `BRAN` (Pipe / Branch)**: Pipeline container and continuous flow route between two defined termini (Head and Tail).
- **`STRU` / `FRMW` / `SBFR`**: Structural hierarchy containers for steel frameworks and sub-frameworks.
- **`SCTN` (Section)**: Extruded structural steel profile referencing catalogue cross-sections.
- **`PANE` (Panel)**: Plate or planar structural boundary (floors, decks, bulkheads).

## Mental Models
- **Think of `PIPE` as a Container and `BRAN` as a Flow String**: A `PIPE` can own multiple `BRAN` elements (e.g., bypass loops, relief lines). A `BRAN` is an unbranched, continuous string from `HREF` (Head Reference) to `TREF` (Tail Reference).
- **Use "Head-to-Tail Continuity"**: Every branch has an explicit start (`HPOS`, `HDIR`, `HBOR`, `HCONN`) and end (`TPOS`, `TDIR`, `TBOR`, `TCONN`).

## Anti-patterns
- **Unconnected Branch Termini**: Leaving Branch Head or Tail undefined leads to unconstrained isometrics and clash reporting errors.
- **Mixing Disciplines under Inappropriate Parents**: Placing a structural `SCTN` directly inside an `EQUI` without a valid sub-element container violates schema rules.

## Code Examples
```pml
-- Creating an Equipment and Nozzle hierarchy
NEW SITE /SITE-PROCESS
NEW ZONE /ZONE-PUMPS
NEW EQUI /P-101A
  POS E 10000 N 20000 U 100
  ORI Y IS N AND Z IS U

NEW NOZZ /P-101A-SUCTION
  CATREF /FLAN-150-RF
  POS E 10500 N 20000 U 600
  DIR E
  HEIG 200
  TEMP 65

-- Routing a Pipe Branch
NEW PIPE /100-P-1001-A1
NEW BRAN /100-P-1001-A1/B1
  -- Connect Head to Nozzle
  HREF /P-101A-SUCTION
  -- Connect Tail to Destination
  TREF /P-102B-SUCTION
```
- **What it demonstrates**: Standard AVEVA command sequence for assembling equipment, nozzle, pipe, and branch hierarchies.

## Reference Tables
| Discipline | Primary Container | Sub-Assembly | Constituent Leaf Elements |
|:---|:---|:---|:---|
| **Equipment** | `EQUI` | `SUBE` | `NOZZ`, `BOX`, `CYLI`, `CONE`, `DISH`, `PYRA` |
| **Piping** | `PIPE` | `BRAN` | `GASK`, `FLAN`, `VALV`, `ELBO`, `TEE`, `REDU`, `TUBI` |
| **Structural** | `STRU` | `FRMW`, `SBFR` | `SCTN`, `GENSEC`, `PANE`, `PLOO`, `VERT` |
| **HVAC** | `HVAC` | `HVBR` | `HVALV`, `HDUCT`, `HBEND`, `HTEE`, `HRED` |
| **Electrical / Cable**| `CABT` (Tray) | `CTBR` | `BEND`, `TEE`, `STRA`, `REDU` |

## Worked Example
Validating a completed piping branch for isometric extraction:
1. Navigate to branch: `/100-P-1001-A1/B1`.
2. Check head status:
   ```pml
   Q HREF
   -- /P-101A-SUCTION
   Q HPOS
   -- E 10500mm N 20000mm U 600mm
   Q HBOR
   -- 150mm
   ```
3. Check component sequence continuity:
   - First member: `GASK` (`Q ARRI` mates with Nozzle).
   - Second member: `FLAN` (`Q ARRI` mates with Gasket).
   - Following members: `ELBO`, `TUBI`, `VALV`.
4. Check tail connection:
   ```pml
   Q TREF
   -- /P-102B-SUCTION
   Q TPOS
   -- E 12000mm N 20000mm U 600mm
   ```

## Key Takeaways
1. The Design Database (`DESI`) model is the core spatial repository for all 3D assets.
2. Physical elements strictly adhere to the `SITE` -> `ZONE` -> Primary -> Sub-assembly -> Leaf hierarchy.
3. Piping branches require explicit Head and Tail connectivity for flow continuity.
4. P-points provide the physical snapping coordinates, bores, and alignments across all disciplines.

## Connects To
- **Ch 2 (Catalogue Database)**: Every component references catalogue geometries and point sets.
- **Ch 11 (Spooler Database)**: Piping branches are subdivided into fabricated spools.
- **Ch 15 (Pseudo Attributes)**: Positional and spatial queries (`CE`, `CRFA`, `CUTL`) execute against design elements.
