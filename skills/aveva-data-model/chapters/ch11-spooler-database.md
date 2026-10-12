# Chapter 11: Spooler Database

## Core Idea
The Spooler Database (`SPOO`) manages the breakdown of 3D piping branches into prefabricated pipe spools, shop and field welds, joint groupings, and fabrication isometric drawings.

## Frameworks Introduced
- **Spool Fabrication Breakdown Framework**:
  - When to use: Preparing piping designs for workshop fabrication, galvanizing bath limits, shipping container constraints, and erection planning.
  - How: 3D `BRAN` elements are partitioned into individual `SPOOL` containers. Components within a spool are joined by shop welds (`IWELD`), while connections between spools or to equipment nozzles are designated as field welds (`FIELD`) or flanged joints.
- **Weld Classification & Joint Grouping Model**:
  - When to use: Tracking weld inspection categories, non-destructive testing (NDT) percentages, and welding procedures.
  - How: Welds (`IWELD`, `AWELD`) are classified by weld type, material compatibility, and joint groups (`JNTGRP`), determining whether fabrication occurs in the controlled shop environment or on site.

## Key Concepts
- **`ISODEPT` / `ISOREGI`**: Administrative hierarchy containers within the spooling environment.
- **`SPOOL`**: A single prefabricated pipe sub-assembly consisting of pipes and fittings welded together in the workshop.
- **`FIELD`**: Field joint designation indicating a connection assembled during on-site plant erection.
- **`IWELD` (Implicit Weld)**: Shop weld connecting pipe fittings and pipe pieces within a spool.
- **`AWELD` (Attached Weld)**: Specifically assigned weld entity carrying unique weld identification numbers.
- **`AITEMS` (Additional Items)**: Loose items shipped with a spool (bolts, gaskets, blind flanges).
- **`JNTGRP` (Joint Group)**: Classification of welded joints for WPS (Welding Procedure Specification) mapping.

## Mental Models
- **Think of Spooling as "Reverse Origami" for Construction**: Dividing a complex continuous 3D pipeline into transportable, galvanizable, and shippable modular Lego blocks.

## Anti-patterns
- **Exceeding Workshop or Transport Envelopes**: Defining a spool whose bounding box exceeds road transport dimensions (e.g. $> 12\text{m} \times 2.5\text{m}$) forces cut-and-re-weld in the field.
- **Leaving Welds Unclassified**: Failing to distinguish between shop and field welds causes fabrication shops to weld sections meant to be erected in place.

## Code Examples
```pml
-- Querying spools on a piping branch
/100-P-1001-A1/B1
Q SPOOLS
-- Lists all generated spool numbers (e.g. SP-01, SP-02)

-- Inspecting a spool element
/SP-01
Q MEMBERS
-- Lists constituent fittings, pipe lengths, and welds
Q WEIGHT
-- Total spool fabrication weight
Q LENGTH BREADTH HEIGHT
-- Spool shipping bounding box
```
- **What it demonstrates**: Querying spool breakdown, constituent fittings, and physical envelope parameters.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Purpose |
|:---|:---|:---|:---|
| `SPOOL` | Spool Container | Spool World | Individual prefabricated pipe spool |
| `FIELD` | Field Joint | `SPOOL` / `BRAN` | Erection weld/joint completed on site |
| `IWELD` | Implicit Shop Weld | `SPOOL` | Workshop welded joint |
| `AWELD` | Attached Weld | `SPOOL` | Explicit tagged weld record |
| `AITEMS` | Additional Items | `SPOOL` | Loose shipped components (bolts, gaskets) |
| `JNTGRP` | Joint Group | Administrative | Welding inspection / NDT grouping |

## Worked Example
Generating and validating a pipe spool:
1. Designer selects branch `/100-P-1001-A1/B1`.
2. Spooling algorithm analyzes branch components:
   - Identifies nozzle connection: creates `FIELD` joint at mating flange.
   - Traces pipe, elbow, valve, flange: total length 4500mm (under transport limit).
   - Identifies break point at second flange: creates `FIELD` joint.
3. System creates `/100-P-1001-A1/B1-SP01`:
   - Contains: 1 Flange, 2 Pipe pieces, 1 Elbow, 3 `IWELD` shop welds.
   - Calculates bounding envelope: $4.5\text{m} \times 1.2\text{m} \times 0.8\text{m}$.
   - Calculates weight: 145 kg.
4. Generates spool fabrication drawing and weld inspection sheet.

## Key Takeaways
1. The Spooler Database (`SPOO`) partitions 3D piping into workshop-fabricable units.
2. Rigorously distinguishes between shop welds (`IWELD`) and field erection joints (`FIELD`).
3. Tracks spool bounding boxes and weights against transport and coating facility constraints.
4. Directly feeds fabrication isometric production and weld tracking databases.

## Connects To
- **Ch 4 (Design Database)**: Consumes piping branches (`BRAN`) and fittings.
- **Ch 2 (Catalogue Database)**: Extracts fitting weights and bolt table definitions.
