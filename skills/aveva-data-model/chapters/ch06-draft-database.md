# Chapter 6: Draft Database

## Core Idea
The Draft Database (`DRAF`) defines the 2D engineering drawing hierarchy, projection views, annotation rules, and intelligent drafting representations generated from 3D design models.

## Frameworks Introduced
- **2D Drawing Hierarchy Framework**:
  - When to use: Generating production piping general arrangements (GAs), equipment layout drawings, and structural fabrication drawings.
  - How: Drawing data follows the strict tree:
    `DEPT` (Department) -> `REGI` (Registry) -> `DRWG` (Drawing) -> `SHEE` (Sheet) -> `VIEW` (View) -> 2D Annotation and Projection Elements.
- **Intelligent 3D-to-2D Projection & Rule Model**:
  - When to use: Annotating drawings automatically while maintaining dynamic links to 3D model modifications.
  - How: A `VIEW` references a 3D target coordinate box and projection direction (`DIR`). Annotation rules (`ACRULE`) and style definitions (`ACSTYLE`) automatically format dimensions, tags, leader lines, and hatching.

## Key Concepts
- **`DEPT` (Department)**: Top-level division within the Draft database (e.g., Piping, Structural, Electrical).
- **`REGI` (Registry)**: Administrative drawing group or discipline sub-category.
- **`DRWG` (Drawing)**: Engineering drawing master container holding one or more sheets.
- **`SHEE` (Sheet)**: Individual drawing sheet with specific page sizes (A0, A1, etc.) and title block templates.
- **`VIEW`**: Projection window on a sheet displaying a scaled, oriented 2D representation of 3D design elements.
- **`LIBY` (Library)**: Container for drawing symbol libraries, backing sheets, and label templates.
- **`ACRULE` (Annotation Change Rule)**: Automatic rule controlling how annotations adapt when 3D geometry changes.
- **`ACSTYLE` (Annotation Change Style)**: Visual styling parameters (font, arrowheads, colors, layer mapping).
- **`ADIMENSION` / `ADIRECTION`**: Intelligent dimensioning lines linked to 3D design P-points or vertices.

## Mental Models
- **Think of a `VIEW` as a Live Camera Looking at the 3D Model**: It does not copy 3D geometry into static vectors; it renders an intelligent projected view. When the 3D model moves, the draft view updates dynamically.

## Anti-patterns
- **Exploding Intelligent Annotations into Static 2D Lines**: Converts parametric linked labels into dumb text, breaking automatic updates when 3D equipment moves.
- **Drawing Outside Defined Sheet Margins**: Misaligning view scales and sheet boundaries results in clipped exports.

## Code Examples
```pml
-- Navigating Draft hierarchy
-- Navigate to DRWG
/PIPING-GA-01
-- Step down to SHEE
FIRST MEMBER
-- Step down to VIEW (e.g. Plan View)
FIRST MEMBER

-- Querying View projection parameters
-- Query view scale (e.g., 1:50)
Q VSCALE
-- Query viewing direction (e.g., DOWN)
Q DIR
-- Query owning drawing name
Q DRAWING
```
- **What it demonstrates**: Navigation and attribute querying across Draft hierarchy elements.

## Reference Tables
| Draft Element | Level | Primary Owner | Legal Members | Description |
|:---|:---|:---|:---|:---|
| `DEPT` | 1 | World | `REGI` | Discipline department |
| `REGI` | 2 | `DEPT` | `DRWG` | Registry / drawing package |
| `DRWG` | 3 | `REGI` | `SHEE` | Engineering drawing definition |
| `SHEE` | 4 | `DRWG` | `VIEW`, `OVER` | Physical drawing sheet and size |
| `VIEW` | 5 | `SHEE` | `ADIM`, `LABE`, `APPT`| 2D projection camera of 3D design |
| `ACRULE` | Library | `LIBY` | Rule items | Automatic annotation rule definition |
| `ACSTYLE` | Library | `LIBY` | Style items | Line styles, text fonts, terminator styles|

## Worked Example
Creating an automatic equipment tag in Draft View:
1. Navigate to target view: `/PUMP-AREA-PLAN-V1`.
2. Link intelligent label (`LABE`) to 3D equipment item:
   - Target reference: `/P-101A`.
   - Rule template: `AUTOTAG-EQUI`.
3. System extracts 3D attributes:
   - Evaluates `/P-101A` `NAME` -> `'P-101A'`.
   - Evaluates `/P-101A` `POS` -> Project 3D coordinate to 2D view sheet mm coordinates.
   - Places text box with pointer leader line to nozzle suction centerline.

## Key Takeaways
1. Draft Database (`DRAF`) structures 2D documentation in a `DEPT` -> `REGI` -> `DRWG` -> `SHEE` -> `VIEW` hierarchy.
2. Views are dynamic projections of 3D design space, not static snapshots.
3. Intelligent annotations retain associative links to 3D model elements.
4. Annotation change rules (`ACRULE`) govern automated drawing updates when 3D geometry shifts.

## Connects To
- **Ch 4 (Design Database)**: Supplies the 3D physical entities projected into Draft views.
- **Ch 15 (Pseudo Attributes)**: Queries projection coordinates and bounding boxes (`BBOX`, `CRFA`).
