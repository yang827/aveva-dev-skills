# Chapter 14: Other Databases

## Core Idea
The Other Databases section defines cross-discipline integration schemas, notably the Engineering Database (`ENGD`), which manages master Tag lists, Engineering Items (`ENGITE`), equipment schedules, and multi-discipline cross-referencing.

## Frameworks Introduced
- **Master Engineering Item (Tag) Lifecycle Framework**:
  - When to use: Coordinating assets (pumps, instruments, tagged valves, motors) that exist simultaneously on P&IDs, 3D models, electrical schematics, and procurement schedules.
  - How: The asset exists as a single central `ENGITE` (Engineering Item) under an `ENGGRP` (Engineering Group) in `ENGD`. Discipline models (e.g. `EQUI` in Design, `SCPUMP` in Schematic) attach to this item via reference attributes, ensuring tag uniqueness and synchronized attributes.

## Key Concepts
- **`ENGWLD` (Engineering World)**: Top-level root container for engineering item catalogs.
- **`ENGGRP` (Engineering Group Element)**: Discipline or system classification group (e.g. Mechanical Equipment, Line List, Motor Schedule).
- **`ENGITE` (Engineering Item Element)**: Master engineering tag record carrying cross-discipline attributes (Duty, Design Pressure, Operating Temperature, Vendor, Purchase Order).
- **Tag Association**: Linking mechanism mapping physical 3D elements and 2D schematic symbols to the single source of truth `ENGITE`.

## Mental Models
- **Think of `ENGITE` as the Digital Twin's Social Security Number**: A pump has a 3D model in Design, a 2D symbol on the P&ID, and a purchase order in SAP; `ENGITE` is the unifying master tag tying them together.

## Anti-patterns
- **Duplicating Tags Manually Across Databases**: Creating `/P-101A` independently in Design and Schematic without binding both to `ENGITE` invites attribute drift and procurement errors.

## Code Examples
```pml
-- Linking a 3D equipment item to master Engineering Item
-- Navigate to 3D EQUI
/P-101A
-- Bind to master Engineering Item
ENGREF /ENG-P-101A

-- Querying engineering specifications from master item
Q ENGREF.PURPOSE
Q ENGREF.DESIGNPRESS
Q ENGREF.DESIGNTEMP
```
- **What it demonstrates**: Associating a 3D physical asset with its master engineering item record.

## Reference Tables
| Element Mnemonic | Full Name | Primary Owner | Engineering Function |
|:---|:---|:---|:---|
| `ENGWLD` | Engineering World | Root | Root container for project engineering data |
| `ENGGRP` | Engineering Group | `ENGWLD` | Tag discipline group (e.g. Mechanical, Valves)|
| `ENGITE` | Engineering Item | `ENGGRP` | Master engineering tag record |

## Worked Example
Synchronizing design temperature and pressure across disciplines:
1. Process engineer defines pump in Engineering DB:
   - Item: `/ENG-P-101A` under `/ENGGRP-ROTATING`.
   - Sets: `DESIGNPRESS 16.0 bar`, `DESIGNTEMP 120 C`.
2. P&ID designer places symbol in Schematic DB:
   - Sets `ENGREF` to `/ENG-P-101A`.
3. 3D piping designer places `/P-101A` in Design DB:
   - Sets `ENGREF` to `/ENG-P-101A`.
4. Automated reporting extracts line list and equipment schedule directly from `ENGITE`, ensuring 100% data consistency.

## Key Takeaways
1. The Engineering Database manages centralized asset tags and cross-discipline specifications.
2. `ENGITE` acts as the single source of truth for equipment, line numbers, and instrument tags.
3. Design and Schematic elements point to `ENGITE` rather than duplicating data.
4. Eliminates synchronization errors between P&IDs, 3D models, and procurement schedules.

## Connects To
- **Ch 4 (Design Database)**: 3D physical components link to `ENGITE` via `ENGREF`.
- **Ch 10 (Schematic Database)**: Schematic diagrams link 2D symbols to `ENGITE`.
