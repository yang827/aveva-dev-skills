# Chapter 8: Manu Database

## Core Idea
The Manufacturing Database (`MANU`) defines fabrication entities, workshop execution data, plate cutting paths, curved plate bending jigs, pin beds, and manufacturing package breakdowns primarily used in shipyard and offshore fabrication environments.

## Frameworks Introduced
- **Hull Fabrication & Cutting Framework**:
  - When to use: Generating NC cutting files, plate marking, bevel profiles, and profile cutting lines from 3D marine hull designs.
  - How: Structure details are grouped into Manufacturing Packages (`MANPKG`), where individual plate cutting paths (`MBURN`), markings (`MAPLNS`), and profile preparations (`MBPRO`) are calculated and validated.
- **Pin Jig Bending & Assembly Bed Model**:
  - When to use: Assembling double-curved shell plates and curved stiffeners on adjustable pin beds.
  - How: Curvature data is transformed into physical pin matrices (`CPIN`, `CPINJG`, `CPINRW`), where height coordinates and angle offsets dictate the setup of physical hydraulic workshop pins.

## Key Concepts
- **`MANPKG` (Manufacturing Package)**: Work package container grouping plates and stiffeners destined for the same cutting bed or assembly stage.
- **`CPIN` (Pin Element)**: Individual adjustable pin definition specifying height, position, and contact angle for supporting curved plates.
- **`CPINJG` (Pin Jig Element)**: Master bed or jig assembly comprising rows of pins.
- **`CPINRW` (Pin Row Element)**: Single linear row of adjustable pins within a jig.
- **`MBURN` (Burn Element)**: Cutting path definition including flame-cutting speeds, lead-ins, and bevel edge preparations.
- **`MAPLNS` (Marking Lines Element)**: Inverse marking and reference lines projected onto plates for welding attachment locations.
- **`MBPRO` (Profile Manufacturing Element)**: Bending, cutting, and end-cut machining data for curved stiffeners.

## Mental Models
- **Think of `MANU` as the Digital Workshop Floor**: Where 3D design models are transformed into physical cutting instructions, robotic welding lines, and pin bed heights.

## Anti-patterns
- **Altering Design Geometry without Updating Manufacturing Packages**: Modifying hull shell plates without re-extracting `MANPKG` produces scrap steel cut to outdated dimensions.

## Code Examples
```pml
-- Querying manufacturing package data
Q TYPE FOR ALL MANPKG
/PKG-BLOCK-101-SHELL
Q MEMBERS
-- Lists burning paths, marking lines, and pin jigs

-- Inspecting pin heights on curved shell plate jig
/JIG-SHELL-PORT-01
-- Row 1
FIRST MEMBER
-- Pin 1
FIRST MEMBER
Q HEIGHT ANGLE
```
- **What it demonstrates**: Querying manufacturing packages and pin jig setup attributes for workshop execution.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Role in Fabrication |
|:---|:---|:---|:---|
| `MANPKG` | Manufacturing Package | World / Sub-area | Master fabrication work package |
| `MBURN` | Burn Path | `MANPKG` | Plate cutting contour, bevel angles |
| `MAPLNS` | Marking Lines | `MANPKG` | Weld positioning marks and frame lines |
| `CPINJG` | Pin Jig | `MANPKG` | Curved shell plate assembly bed |
| `CPINRW` | Pin Row | `CPINJG` | Row of adjustable pins |
| `CPIN` | Pin Element | `CPINRW` | Height coordinate for individual jig pin |
| `MBPRO` | Profile Processing | `MANPKG` | Stiffener bending template and end notches |

## Worked Example
Setting up an adjustable pin bed for curved hull shell plate `/PL-101-PORT`:
1. Design model calculates shell plate 3D curvature.
2. Manufacturing application generates `CPINJG`:
   - Grid spacing: 1000mm in X, 1000mm in Y.
3. System iterates across pin rows (`CPINRW`) and generates `CPIN` elements:
   - Evaluates required height `Z` for each pin to support plate without sagging.
   - Outputs table of pin numbers, calculated heights, and head inclination angles.
4. Workshop technicians adjust hydraulic pin bed according to `Q HEIGHT` attributes.

## Key Takeaways
1. The Manu Database (`MANU`) bridges 3D design models with physical shipyard/shop fabrication.
2. `MANPKG` encapsulates all burning, marking, and profile processing instructions.
3. Pin jig elements (`CPINJG`, `CPIN`) mathematically describe curved plate assembly tooling.
4. Essential for automated NC plate cutting, bending templates, and robotic welding.

## Connects To
- **Ch 4 (Design Database)**: Consumes plate, stiffener, and shell geometry from the Design model.
- **Ch 11 (Spooler Database)**: Parallels spooling workflows for structural and marine components.
