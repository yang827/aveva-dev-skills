# Chapter 10: Schematic Database

## Core Idea
The Schematic Database (`SCHE`) stores intelligent 2D Process & Instrumentation Diagrams (P&IDs), HVAC schematics, electrical single-line diagrams, and topological connectivity networks, enabling seamless 2D-to-3D cross-checking and engineering data validation.

## Frameworks Introduced
- **Topological Process Connectivity Framework**:
  - When to use: Developing P&ID diagrams, tracking fluid flow routes, and validating process instrumentation control loops.
  - How: Process streams are modeled as schematic pipelines (`SCPIPE`) owning schematic branches (`SCBRANCH`). Inline equipment and instruments are represented by intelligent schematic elements (`SCVALV`, `SCPUMP`, `SCACTUATOR`, `SCELCONNECTION`).
- **2D-to-3D Engineering Cross-Referencing Model**:
  - When to use: Verifying that 3D piping and equipment match approved P&ID specifications (Diagrams to 3D Compare).
  - How: Elements share common engineering item tags (`ENGITE`). The comparison engine cross-checks line numbers, valve types, nominal bores, and design specifications across the `SCHE` and `DESI` databases.

## Key Concepts
- **`SCDIAGRAM`**: The master schematic drawing sheet container (equivalent to a P&ID sheet).
- **`SCPIPE` / `SCBRANCH`**: Schematic pipeline and flow branch records capturing fluid stream topology without 3D spatial coordinates.
- **`SCVALV` (Schematic Valve)**: 2D representation of an inline valve carrying tag, type, and status.
- **`SCPUMP` / `SCEQUI`**: Schematic equipment representations with connected nozzle ports.
- **`SCCABLE` / `SCCORE`**: Schematic electrical and instrumentation cable topology and core connections.
- **`SCELCONNECTION`**: Electrical connection terminal or schematic pin.
- **Topological Node**: Point of connection between stream branches, valves, or nozzles.

## Mental Models
- **Think of `SCHE` as the Logical Blueprint and `DESI` as the Physical Reality**: `SCHE` defines *what* is connected to *what* (functional logic); `DESI` defines *where* it is placed in 3D space (physical coordinates).

## Anti-patterns
- **Disconnecting 2D Schematics from 3D Piping**: Changing line numbers or valve tags in 3D models without updating the P&ID leads to commissioning discrepancies.
- **Overwriting Topological Connections with Dummy Graphic Lines**: Drawing unlinked 2D lines breaks automated line list generation.

## Code Examples
```pml
-- Querying a schematic pipeline
/SC-100-P-1001-A1
Q TYPE
-- Returns SCPIPE
Q MEMBERS
-- Returns SCBRANCH elements

-- Checking inline schematic components
-- Navigates to SCBRANCH
FIRST MEMBER
Q MEMBERS
-- Lists SCVALV, SCIINSTR, SCNOZZ elements
```
- **What it demonstrates**: Navigation and inspection of schematic pipeline topology in the Schematic database.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Function |
|:---|:---|:---|:---|
| `SCDIAGRAM` | Schematic Diagram | World | P&ID drawing sheet container |
| `SCPIPE` | Schematic Pipe | `SCDIAGRAM` | Process stream pipeline container |
| `SCBRANCH` | Schematic Branch | `SCPIPE` | Continuous logical flow stream |
| `SCVALV` | Schematic Valve | `SCBRANCH` | Inline valve symbol and metadata |
| `SCPUMP` | Schematic Pump | `SCDIAGRAM` | Equipment symbol with schematic nozzles |
| `SCACTUATOR` | Schematic Actuator | `SCVALV` | Valve actuator symbol / control link |
| `SCCABLE` | Schematic Cable | `SCDIAGRAM` | Cable connection line |

## Worked Example
Running a 2D-to-3D schematic consistency check:
1. P&ID engineer completes `/SC-100-P-1001-A1`:
   - Specifies: 100mm, Spec `A1`, Valve sequence: `GATE`, `CHECK`, `GLOBE`.
2. 3D piping designer routes `/100-P-1001-A1`:
   - Places: 100mm, Spec `A1`, Valve sequence: `GATE`, `GLOBE` (omitted check valve).
3. System runs Schematic-to-3D Comparison:
   - Compares members of `SCBRANCH` with members of 3D `BRAN`.
   - Flags discrepancy: `CHECK VALVE MISSING IN 3D DESIGN`.
   - Designer corrects 3D model prior to isometric generation.

## Key Takeaways
1. The Schematic Database (`SCHE`) models 2D logical connectivity and process intent.
2. Decoupled from 3D coordinates, focusing on stream topology and component sequences.
3. Provides the baseline for automated P&ID-to-3D model comparison and line list extraction.
4. Essential for engineering consistency between process and piping disciplines.

## Connects To
- **Ch 4 (Design Database)**: 3D piping branches link to schematic branches via engineering tags.
- **Ch 14 (Other Databases)**: Shares engineering item definitions (`ENGITE`).
