# Chapter 1: Introduction

## Core Idea
The AVEVA Data Model Reference Manual defines the strict hierarchical database schema, element types, and attribute systems that govern all physical and administrative entities across AVEVA Plant, Marine, and Everything3D (E3D) engineering environments.

## Frameworks Introduced
- **Hierarchical Database Architecture Framework**:
  - When to use: Navigating, querying, or modifying any element in AVEVA project databases (Design, Catalogue, Draft, System, etc.).
  - How: Every element in an AVEVA database resides in an invariant parent-child ownership tree. An element is defined by its four-letter mnemonic type, its position in the hierarchy (`OWNER` and legal `MEMBERS`), and its set of native and pseudo attributes.
- **PML and Macro Automation Model**:
  - When to use: Developing batch macros, automation scripts, and custom user interface forms (PML 1 / PML 2).
  - How: Access elements via the Current Element (`CE`) cursor or explicit references (`/NAME` or `=refno`), inspect metadata with `Q <attribute>`, and manipulate properties using standard assignment syntax (`<attribute> <value>`).

## Key Concepts
- **Element**: The fundamental data record or node within an AVEVA database, representing physical objects, administrative entities, or geometric primitives.
- **Primary Element**: An administrative or high-level element (such as `ZONE`, `PIPE`, `EQUI`, `BLTABLE`) that can be created directly beneath world or administrative parents.
- **Secondary Element**: A constituent component or sub-element (such as `BOX`, `CYLI`, `VALV`, `FLAN`, `NOZZ`) owned by a primary element.
- **Legal Owner**: The set of element types permissible as the parent of the current element type.
- **Legal Member**: The set of element types permissible as direct children of the current element type.
- **Current Element (`CE`)**: The active contextual element in the current session against which unqualified queries and commands execute.
- **MDB (Multiple Database)**: The configured collection of read and read-write databases constituting the user's active project workspace.

## Mental Models
- **Think of the AVEVA Database as a Strongly-Typed Directed Tree**: No orphan elements can exist; every element except the root `WORLD` must have exactly one legal owner, and element behavior is strictly dictated by its type schema.
- **Use "Navigation by Lineage"**: Move up using `OWNER`, down using child indices (`1`, `2`, `LAST`), and sideways using `NEXT` or `PREV`.

## Anti-patterns
- **Bypassing Hierarchy Validation**: Attempting to create secondary elements under invalid owners leads to runtime command failures (`Element cannot be created here`).
- **Assuming Global Attribute Uniformity**: Treating attributes as universally applicable across element types; attributes are strictly scoped to specific element schemas.

## Code Examples
```pml
-- Inspecting the Current Element and its lineage
Q TYPE
Q NAME
Q OWNER
Q MEMBERS

-- Navigating the database tree
-- Navigate by global name
/P101A
-- Step up to owning ZONE or SITE
OWNER
-- Step down to first child
FIRST MEMBER
-- Step to next sibling
NEXT
```
- **What it demonstrates**: Core database hierarchy navigation and schema inspection commands in AVEVA command line.

## Reference Tables
| Database Code | Database Type | Primary Role & Contents |
|:---|:---|:---|
| `CATA` | Catalogue DB | Piping components, steel profiles, nozzle types, bolt tables, connection rules |
| `DESI` | Design DB | 3D physical models: Piping, Equipment, Steelwork, Civils, HVAC, Electrical |
| `DRAF` | Draft DB | 2D drawings, views, annotations, dimensions, drafting representation rules |
| `DICT` | Dictionary DB | User Defined Attributes (UDAs), element definitions, custom database views |
| `SYST` | System DB | Users, teams, access control rights (ACR), project administration |
| `PROP` | Property DB | Engineering material properties, cable sizing tables, stress calculation data |
| `SCHE` | Schematic DB | 2D P&ID diagrams, schematic equipment, connectivity networks |
| `SPOO` | Spooler DB | Pipe spooling breakdowns, shop vs field weld definitions |

## Worked Example
A piping automation engineer needs to inspect an incoming nozzle to verify its parent equipment and database provenance:
1. Query active element: `Q CE` -> returns `=2412/1054` (`/P101A-N1`).
2. Verify type: `Q TYPE` -> returns `NOZZ`.
3. Verify owner: `Q OWNER` -> returns `/P101A` (Type `EQUI`).
4. Step up to owner and query site:
   ```pml
   CE = /P101A
   Q TYPE
   -- EQUI
   -- Navigates to ZONE
   OWNER
   Q NAME
   -- /AREA01-ZONE
   -- Navigates to SITE
   OWNER
   Q NAME
   -- /PLANT-SITE
   ```

## Key Takeaways
1. Every physical and administrative object in AVEVA is an `Element` residing in a designated database.
2. The data model enforces strict ownership rules: an element cannot exist without a valid parent.
3. Element behavior and available attributes are determined by its element type mnemonic.
4. PML automation relies directly on this data model for object querying, traversal, and modification.

## Connects To
- **Ch 4 (Elements in the Design Database)**: Extends these foundational concepts into 3D physical plant modeling.
- **Ch 16 (Introduction to Attributes)**: Formalizes the data types and classification of attributes on elements.
