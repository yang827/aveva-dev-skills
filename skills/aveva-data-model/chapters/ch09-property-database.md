# Chapter 9: Property Database

## Core Idea
The Property Database (`PROP`) stores physical, electrical, and mechanical material properties, cable sizing engineering tables, and external calculation parameters required for engineering analysis and component specification.

## Frameworks Introduced
- **Parametric Cable Engineering Framework**:
  - When to use: Sizing power, control, and instrumentation cables, calculating tray fill percentages, and evaluating voltage drops.
  - How: Cable models in `PROP` define conductor cross-sections, insulation ratings, outer diameters, linear weights, and bending radii under `CABDATA` and `CARD` elements.
- **Material & Thermal Properties Model**:
  - When to use: Performing piping stress analysis, structural load calculations, and thermal expansion modeling.
  - How: Material records (`CMPDATA`, `CMPTYPE`) link alloy specifications (e.g. ASTM A106 Gr B, 316L Stainless) to temperature-dependent Young's modulus, thermal expansion coefficients, and yield strengths.

## Key Concepts
- **`CASWORLD` / `CMPWORLD`**: Top-level root containers for cable and component property catalogs.
- **`CABDATA` (Cable Data Element)**: Master electrical and physical specification for a cable type (diameter, weight, cores, voltage class).
- **`CARD` (Card Data Element)**: Lookup table card storing numerical arrays for engineering calculations (e.g. ampacity derating curves).
- **`CMPDATA` (Component Data Element)**: Physical property dataset for structural profiles or piping components.
- **Linear Density (Weight)**: Key attribute used across disciplines to calculate cable tray weights and pipe rack structural loads.
- **Minimum Bend Radius**: Critical attribute preventing physical cable routing with unachievable bend radii.

## Mental Models
- **Think of `PROP` as the Engineering Material & Physics Handbooks in Digital Form**: Physical design elements declare "what" they are; `PROP` provides the "physics" (weight, strength, conductivity) for calculations.

## Anti-patterns
- **Using Hardcoded Approximations for Cable Diameters**: Ignoring `CABDATA` outer diameter attributes causes cable tray capacity underestimates and field rework.

## Code Examples
```pml
-- Querying cable properties referenced by a design cable
Q CATREF OF /CAB-P101-POWER
Q DIAM OF CATREF OF /CAB-P101-POWER
Q CWEIGHT OF CATREF OF /CAB-P101-POWER
-- Linear weight (kg/m)
Q BRADIUS OF CATREF OF /CAB-P101-POWER
-- Min bend radius
```
- **What it demonstrates**: Querying physical cable dimensions and calculation properties stored in the Property database.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Engineering Application |
|:---|:---|:---|:---|
| `CASWORLD` | Cable World | Root | Container for cable engineering data |
| `CABDATA` | Cable Specification | `CASTYPE` | Electrical rating, outer diameter, weight |
| `CARD` | Card Data | `CASWORLD` | Tabular derating, resistance arrays |
| `CMPWORLD` | Component World | Root | Material property root container |
| `CMPDATA` | Material Property Data| `CMPTYPE` | Yield stress, thermal expansion, density |

## Worked Example
Evaluating cable tray loading for a new 400V pump feed:
1. Electrical engineer routes cable `/CBL-401A` along cable tray `/TRAY-ROUTE-10`.
2. Sizing tool reads `CABDATA` reference:
   - Outer diameter `OUTD`: 32.5mm.
   - Weight per meter `CWEIGHT`: 2.45 kg/m.
3. Cable tray calculation tool iterates through all cables in tray:
   - Sums cross-sectional areas: verifies tray fill $< 40\%$.
   - Sums total linear weight: passes structural load to structural engineer for `SCTN` sizing.

## Key Takeaways
1. The Property Database (`PROP`) centralizes physics, materials, and electrical specifications.
2. `CABDATA` supplies physical diameters, weights, and bend radii for electrical design.
3. `CMPDATA` provides mechanical properties for structural and stress calculations.
4. Prevents duplicate data entry across multi-discipline engineering calculations.

## Connects To
- **Ch 4 (Design Database)**: Design cables and structural steel query properties from `PROP`.
- **Ch 10 (Schematic Database)**: Schematic wiring and instrumentation link to property definitions.
