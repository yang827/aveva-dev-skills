# Chapter 17: Mapping of Data Extraction Keywords to Attributes

## Core Idea
Chapter 17 maps legacy Hull Data Extraction keywords to modern AVEVA database element and attribute queries, providing a bridge for upgrading legacy macro reports and extraction scripts into modern reporting tools.

## Frameworks Introduced
- **Legacy Extraction Keyword Migration Framework**:
  - When to use: Upgrading legacy AVEVA Marine / Tribon data extraction macros, customized hull bill of material reports, and cutting list exports.
  - How: Map legacy abbreviated keywords (used in old batch extraction syntax) to the corresponding native element types and attributes in the modern AVEVA Data Model and Reporting tool.

## Key Concepts
- **Data Extraction Keywords**: Historical abbreviated query keywords previously used in legacy Hull/Marine batch reporting scripts.
- **Modern Reporting Tool**: Current unified reporting framework that queries database elements directly via PML expressions and standardized attribute syntax.
- **Cross-Reference Mapping**: Table defining exact equivalence between old extraction keywords and modern attribute names.

## Mental Models
- **Think of Keyword Mapping as a Translation Dictionary**: Converting legacy batch commands into modern object-oriented attribute queries.

## Anti-patterns
- **Relying on Deprecated Batch Extraction Utilities in New Projects**: Continuing to use obsolete keyword scripts prevents utilization of modern multi-threading and GUI reporting features.

## Code Examples
```pml
-- Legacy reporting approach (historical keyword syntax)
-- EXTRACT KEYWORD: HULL_THICKNESS, BLOCK_NO, STEEL_GRADE

-- Modern AVEVA Reporting PML expression equivalent
Q THICK OF CE
Q :BLOCK_NUMBER OF OWNER OF CE
Q MATREF.NAME OF CE
```
- **What it demonstrates**: Transitioning from legacy hull extraction keywords to modern direct element attribute queries.

## Reference Tables
| Legacy Keyword Area | Typical Legacy Concept | Modern Database Element | Modern Attribute / Expression |
|:---|:---|:---|:---|
| Hull Plate Thickness | Plate metal thickness | `PANE` / Plate element | `THICK` |
| Block Allocation | Assembly block identifier | Structural Parent / UDA | `:BLOCK_NUMBER` or `OWNER.NAME`|
| Material Grade | Steel grade specification | Material Reference | `MATREF.NAME` |
| Cut Profile Length | Stiffener cutting length | `SCTN` / Profile element | `CUTL` (Pseudo attribute) |
| Panel Area | Surface plate area | `PANE` | `AREA` |
| Bevel Angle | Edge preparation angle | `MBURN` | `BEVEL` |

## Worked Example
Modernizing a hull block steel weight and plate thickness report:
1. Legacy script used keywords: `BLK_NAME`, `PLT_ID`, `PLT_THK`, `PLT_WGT`.
2. Converted to modern AVEVA Reporting tool query:
   - Target collection: `ALL PANE FOR /BLOCK-101`.
   - Column 1: `OWNER.NAME` (Block Name).
   - Column 2: `NAME` (Plate ID).
   - Column 3: `THICK` (Plate Thickness in mm).
   - Column 4: `WVOL * 7850` or `WEIGHT` (Calculated Steel Weight in kg).
3. Report executes natively in modern E3D/Marine sessions with instant output formatting.

## Key Takeaways
1. Provides a direct migration mapping from legacy hull extraction keywords to modern attributes.
2. Facilitates upgrading legacy macros and customer batch reporting tools.
3. Modern reporting queries element attributes (`THICK`, `CUTL`, `MATREF`) directly without intermediate export files.

## Connects To
- **Ch 4 (Design Database)**: Queries structural and hull panel elements.
- **Ch 8 (Manu Database)**: Integrates with modern manufacturing package outputs.
- **Ch 16 (Introduction to Attributes)**: Uses standard attribute syntax for reports.
