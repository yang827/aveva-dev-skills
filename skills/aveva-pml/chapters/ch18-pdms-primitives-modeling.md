# Chapter 18: AVEVA 3D Modeling Primitives & P-Points

## Core Idea
AVEVA 3D Equipment modeling is constructed using basic geometric solid primitives (Box, Cylinder, Dish, Cone, Pyramid, Torus, Snout). Primitives are spatially assembled and aligned using Primitive Reference Points (P-points) and the `CONN` (connect) command.

## Frameworks Introduced
- **Geometric Primitive Taxonomy**:
  - **`BOX`**: Rectangular cuboid defined by dimensions `XLEN`, `YLEN`, `ZLEN`.
  - **`CYLINDER` (`CYLI`)**: Cylindrical solid defined by diameter `DIAM` and height `HEIG`.
  - **`DISH`**: Dished spherical/torispherical end defined by `DIAM` and crown `HEIG` (or knuckle radius `RADI`).
  - **`CONE`**: Conical solid defined by `DTOP` (top diameter), `DBOT` (bottom diameter), and `HEIG`.
  - **`PYRAMID` (`PYRA`)**: Tapered block with rectangular base and top.
  - **`TORUS` (`TORU`)**: Ring donut defined by ring diameter, tube diameter, and angle.
- **P-Point Alignment & Connection Geometry**:
  - Every primitive possesses intrinsic reference points called **P-points** (`P0`, `P1`, `P2`, etc.) which carry both a 3D coordinate location and a normal direction vector.
  - **`CONN P<n> TO P<m> OF <element>`**: Translates and attaches P-point `n` of the current element to P-point `m` of the target element.
  - **`CONN P<n> TO P<m> OF PREV`**: Connects current primitive directly to the preceding primitive in the hierarchy.
- **Orientation & Spatial Rotation**:
  - Orienting primitive axes: `ORI P1 IS P2 OF PREV`, `ORI AND CONNECT P1 TO P2 OF PREV`.

## Key Concepts
- **`P0`**: Usually the geometric center of the primitive.
- **`BOX` P-points**:
  - `P1`: Face +X (+East by default)
  - `P2`: Face +Y (+North by default)
  - `P3`: Face +Z (+Up by default)
  - `P4`: Face -X (-West by default)
  - `P5`: Face -Y (-South by default)
  - `P6`: Face -Z (-Down by default)
- **`CYLINDER` P-points**:
  - `P1`: Center of bottom face
  - `P2`: Center of top face
  - `P3`: Point on curved surface
- **`DISH` P-points**:
  - `P1`: Center of base plane
  - `P2`: Apex of curved dish dome
- **`PREV` Keyword**: Refers to the immediately preceding sibling element in the current hierarchy.

## Mental Models
- **Think of P-points as 3D magnetic docking ports**: Instead of calculating complex trigonometry in world coordinates, you simply snap port `P1` of a cylinder to port `P3` of a box.
- **Direction vectors matter**: Connecting `P1` to `P2` places their positions coincident and aligns their normal direction vectors in opposing faces.

## Anti-patterns
- **Positioning Primitives Using Absolute Coordinates**: Manually computing `AT E 1423.5 N 2891.2` when stacking primitives makes equipment parametric scaling fragile; always use relative P-point connections (`CONN P1 TO P2 OF PREV`).
- **Connecting Incompatible Primitive Faces**: Snapping a cylinder curved side (`P3`) to a dish base without checking rotational orientation.
- **Forgetting Parent Equipment (`EQUI`)**: Primitives cannot exist in isolation under a `ZONE`; they must reside inside an `EQUI` (Equipment) or `SUBE` (Sub-equipment) element.

## Code Examples
```pml
-- ================================================================
-- Example: Assembling a Parametric Vertical Vessel with Primitives
-- Source: TM-2263 Exercise 1 & 2
-- ================================================================

-- Create Equipment Container
NEW EQUIPMENT /VESSEL-V101

-- 1. Create Main Vertical Cylindrical Shell
NEW CYLINDER /VESSEL-V101-SHELL
  DIAM 1500
  HEIG 4000
  ORIENTATION Z IS UP

-- 2. Add Top Dished Head
NEW DISH /VESSEL-V101-TOPDISH
  DIAM 1500
  HEIG 375
  -- Connect dish base (P1) to cylinder top face (P2)
  CONN P1 TO P2 OF /VESSEL-V101-SHELL

-- 3. Add Bottom Dished Head
NEW DISH /VESSEL-V101-BOTDISH
  DIAM 1500
  HEIG 375
  -- Connect dish base (P1) to cylinder bottom face (P1)
  CONN P1 TO P1 OF /VESSEL-V101-SHELL
  -- Invert dish orientation downwards
  ORI P2 IS -D OF /VESSEL-V101-SHELL

-- 4. Add Structural Support Skirt
NEW CYLINDER /VESSEL-V101-SKIRT
  DIAM 1500
  HEIG 1200
  CONN P2 TO P1 OF /VESSEL-V101-SHELL

-- 5. Add Base Ring (Box)
NEW BOX /VESSEL-V101-BASE
  XLEN 1800
  YLEN 1800
  ZLEN 100
  CONN P3 TO P1 OF /VESSEL-V101-SKIRT

-- Add to current 3D graphics view
ADD /VESSEL-V101 AUTO
$P Vessel /VESSEL-V101 successfully built and added to view.
```
- **What it demonstrates**: Creating primitives (`CYLINDER`, `DISH`, `BOX`), setting geometric dimensions (`DIAM`, `HEIG`, `XLEN`), relative P-point assembly (`CONN P1 TO P2 OF ...`), inverted orientation, and adding to the 3D drawlist.

## Reference Tables
| Primitive Keyword | Primary Attributes | Key P-Point Definitions |
|---|---|---|
| `BOX` | `XLEN`, `YLEN`, `ZLEN` | `P0` Center, `P1` +X, `P2` +Y, `P3` +Z, `P4` -X, `P5` -Y, `P6` -Z |
| `CYLINDER` (`CYLI`) | `DIAM`, `HEIG` | `P1` Bottom Center, `P2` Top Center, `P3` Side |
| `DISH` | `DIAM`, `HEIG`, `RADI` | `P1` Base Center, `P2` Crown Apex |
| `CONE` | `DTOP`, `DBOT`, `HEIG` | `P1` Bottom Center, `P2` Top Center |
| `PYRAMID` (`PYRA`) | `XBOT`, `YBOT`, `XTOP`, `YTOP`, `HEIG` | `P1` Bottom Center, `P2` Top Center |
| `SNOUT` | `DTOP`, `DBOT`, `HEIG`, `OFFS` | Eccentric cone with offset axis |

## Key Takeaways
1. AVEVA 3D equipment models are composed of standard solid primitives.
2. Align primitives using P-points (`CONN P<n> TO P<m> OF <elem>`) rather than manual global coordinates.
3. Every primitive must reside inside an `EQUIPMENT` or `SUBEQUIPMENT` parent.
4. Use `ADD <elem> AUTO` to center and frame the newly created assembly in the active viewport.

## Connects To
- **Ch 1**: PML Basics & Environment
- **Ch 7**: Core System Objects (`POSITION`, `DIRECTION`, `ORIENTATION`)
- **Ch 11**: 3D View Gadgets & Graphical Display
- **Ch 19**: Production Exercises & Recipes
