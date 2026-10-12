# Chapter 2: Catalogue Database

## Core Idea
The Catalogue Database (`CATA`) defines the master dimensional, geometric, connection, and bolting templates for all standardized components used across Piping, Steelwork, HVAC, and Cable tray design.

## Frameworks Introduced
- **Catalogue Component Parametrization Framework**:
  - When to use: Defining standard parts (valves, flanges, elbows, tees, steel sections) reusable across designs.
  - How: Components are structured under `CATA` -> `SECT` -> `CATEGORY` -> `SKEY`/`COMP`. Geometry is defined via Geometry Sets (`GMSE`) referencing 3D primitives, while connection locations, bores, and alignments are governed by Point Sets (`PTSE`).
- **Connection Compatibility & Bolting Model**:
  - When to use: Validating flange-to-pipe mating, gasket selection, and calculating bolt lengths and diameters.
  - How: Connection types (`COCO`) evaluate compatibility tables (`CCTABLE`). Bolt selection tables (`BLTABLE`) evaluate bolt lists (`BLIST`), bolt points (`BLTP`), and dataset items (`DTSET`) to determine bolt quantities and lengths based on flange thicknesses and gasket ratings.

## Key Concepts
- **`CATALOGUE`**: The root administrative element of a Catalogue database.
- **`SECTION` (`SECT`)**: A top-level organizational folder within a catalogue, grouping components by discipline or vendor.
- **`CATEGORY`**: A collection of related component definitions sharing common parametric definitions.
- **`PTSE` (Point Set)**: Container for P-points (`PTPO`) that define the origin, connection bores, ratings, and directions for component ports.
- **`GMSE` (Geometry Set)**: Container for geometric primitives (`PVAL`, `SCYL`, `SDIS`) describing the 3D physical envelope.
- **`BLTABLE` (Bolt Table)**: Master lookup element defining bolting requirements for flanged connections.
- **`COCO` (Connection Compatibility)**: Element defining compatibility rules between connection types (e.g., Flanged `FBD`, Welded `BW`, Screwed `SC`).
- **`DTABLE` (Diameter Table)**: Standard nominal diameter mappings and conversions.
- **`BRTAB` (Branch Table)**: Selection table for branch reinforcement choices (e.g., Tee vs Weldolet vs Stub-in) based on header and branch diameters.

## Mental Models
- **Think of Catalogue Elements as "Blueprints" and Design Elements as "Instances"**: A Design component (`VALV`) holds position and specification, but delegates all geometry, port coordinates, and physical dimensions to its Catalogue reference (`SPREF` -> `CATREF`).
- **Use "Port Pinpointing via P-points"**: P0 is the component insertion origin; P1 is typically arrive, P2 is leave, P3 is branch.

## Anti-patterns
- **Hardcoding Dimensions in Design Elements**: Forcing dimensions directly onto design instances instead of leveraging parametric catalogue tables breaks spec-driven validation and isometrics.
- **Mismatched P-point Directions**: Inverting P-point directions in a `PTSE` causes components to insert backwards in pipelines.

## Code Examples
```pml
-- Inspecting a Catalogue component referenced by current design element
Q SPREF
-- Returns the specification reference
Q SPREF.CATREF
-- Returns the Catalogue component (e.g. /FLAN-100-WNRF)
Q SPREF.CATREF.PTSE
-- Returns Point Set defining connection ports
Q SPREF.CATREF.GMSE
-- Returns Geometry Set defining 3D shapes

-- Querying P-points on Catalogue component
VAR !p1 SPREF.CATREF.PTSE[1]
Q ATTR !p1 PSKEY PBOR PTYP
```
- **What it demonstrates**: Traversal from a physical design element instance to its underlying catalogue blueprint and port definitions.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Legal Members | Purpose |
|:---|:---|:---|:---|:---|
| `CATALOGUE` | Catalogue Root | World | `SECT` | Top-level catalogue root |
| `SECT` | Section | `CATALOGUE` | `CATEGORY`, `SECT` | Major discipline / vendor section |
| `CATEGORY` | Piping Category | `SECT` | `SKEY`, `PTSE`, `GMSE` | Component family container |
| `PTSE` | Point Set | `CATEGORY` | `PTPO` | Definition of connection P-points |
| `GMSE` | Geometry Set | `CATEGORY` | Primitives (`SCYL`, `SBOX`, etc.) | 3D boundary geometry representation |
| `BLTABLE` | Bolt Table | `SECT`, `CATALOGUE` | `BLIST` | Bolting lookup definitions |
| `BLTP` | Bolt Point | `BTSET` | None | Bolt length and quantity definition |
| `CCTABLE` | Compatibility Table | `CATALOGUE` | `COCO` | Connection compatibility lookup |
| `BRTAB` | Branch Table | `SECT` | `TABENT` | Header vs branch fitting matrix |

## Worked Example
Creating and linking a standard flanged connection:
1. Design branch arrives at equipment nozzle:
   - Query Nozzle connection: `Q P1 BORE` (100mm), `Q P1 CONN` (`FBD`).
2. Pipe branch inserts mating flange:
   - Evaluates branch specification (`PSPEC`).
   - Spec queries `CCTABLE` for connection `FBD`: identifies compatible gasket and mating flange.
   - Evaluates `BLTABLE` for `FBD` at 100mm:
     - Extracts bolt count: 8.
     - Extracts bolt diameter: 16mm.
     - Adds flange thickness A + flange thickness B + gasket thickness + nut allowance = total bolt length.

## Key Takeaways
1. Catalogue database (`CATA`) is the single source of truth for physical dimensions and connectivity.
2. Components decouple 3D geometry (`GMSE`) from connection port definitions (`PTSE`).
3. Connection compatibility (`COCO`, `CCTABLE`) ensures only physically sound connections can mate.
4. Bolting tables (`BLTABLE`, `BLTP`) dynamically calculate bolt requirements for flanged joints.

## Connects To
- **Ch 4 (Design Database)**: Design elements (`VALV`, `FLAN`, `TEE`) reference `CATA` items via `SPREF`.
- **Ch 11 (Spooler Database)**: Uses catalogue weights and weld types to calculate spool bills of materials.
