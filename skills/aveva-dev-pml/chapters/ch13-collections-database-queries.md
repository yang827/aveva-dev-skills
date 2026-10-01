# Chapter 13: Collections & DABACON Database Queries

## Core Idea
DABACON is AVEVA's hierarchical, transactional engineering database. PML provides two distinct mechanisms to query and traverse the hierarchy: the PML 1 `VAR ... COLLECT` syntax (returning strings) and the modern PML 2 `COLLECTION` object (returning typed `DBREF` arrays).

## Frameworks Introduced
- **Dual Query Paradigm (PML 1 vs PML 2)**:
  - **PML 1 Query (`VAR !arr COLL ...`)**: Quick command-line queries returning an `ARRAY of STRING`. Useful for string evaluations (`VAR !v EVAL (XLEN * YLEN) FOR ALL FROM !boxes`).
  - **PML 2 Query (`object COLLECTION()`)**: Strongly typed object pipeline returning an `ARRAY of DBREF`. Enables direct member and method dereferencing.
- **PML 2 `COLLECTION` Pipeline**:
  1. Instantiate: `!coll = object COLLECTION()`
  2. Set Target Type: `!coll.type('EQUI')`
  3. Set Scope: `!coll.scope(!parentRef)` (accepts `DBREF` or `!!CE`)
  4. Set Filter Expression: `!expr = object EXPRESSION(|PURP eq 'PUMP'|)` followed by `!coll.filter(!expr)`
  5. Execute & Collect: `!results = !coll.results()` -> returns `ARRAY of DBREF`
- **Hierarchical Tree Traversal Framework**:
  - Ascending hierarchy: `!parentRef = !elemRef.owner`
  - Descending hierarchy: Querying children via `scope` or counting via `!elemRef.mcount()`.
  - Reference Validation: Checking validity with `!elemRef.badRef()` and assignment with `!elemRef.unset()`.

## Key Concepts
- **`DBREF`**: Direct pointer to a DABACON database record. Holds identity, hierarchy links, and dynamic attributes.
- **`COLLECTION` Object**: PML 2 search engine executing high-speed filtered queries across the database tree.
- **`EXPRESSION` Object**: Encapsulated logical condition evaluated against database element attributes (e.g., `|BORE GE 100 AND TYPE EQ 'NOZZ'|`).
- **`.scope(!ref)`**: Method restricting the search subtree to descendants of the specified reference.
- **`.mcount()` / `.mcount('TYPE')`**: Native `DBREF` method returning the count of immediate child elements.
- **`.attribute('NAME')`**: Dynamically queries any named attribute on a `DBREF` (e.g., `!ref.attribute('POS')`, `!ref.attribute('OD')`).

## Mental Models
- **Strings vs DBREFs**: PML 1 `COLL` returns names as plain text strings (`ARRAY of STRING`); PML 2 `COLLECTION` returns living database pointers (`ARRAY of DBREF`).
- **Scope defines the search root**: If scope is set to `!!CE`, the collection only searches the subtree below the current element, ignoring the rest of the database.

## Anti-patterns
- **Assuming DBREF has a `.members()` method**: `DBREF` does **not** have a `.members()` method in AVEVA PML! To retrieve members, use a `COLLECTION` object scoped to the element, or use `VAR !mems COLL ALL FOR $!elem`.
- **Querying Entire Database Without Scope**: Running an un-scoped `ALL NOZZ` query across a 500,000-element project freezes the application; always set a localized `.scope(!zoneRef)`.
- **Modifying DABACON without a Valid Transaction**: Attempting to delete or create elements while in read-only mode or outside proper hierarchy levels raises fatal database errors.

## Code Examples
```pml
-- ================================================================
-- Example 1: PML 1 Query Syntax (Returns ARRAY of STRING)
-- ================================================================
-- Collect all zones under current site
var !zones coll all zone for ce
q var !zones

-- Evaluate names and volume of all boxes under current equipment
var !boxes coll all box for ce
var !vols eval (xlen * ylen * zlen) for all from !boxes
q var !vols

-- ================================================================
-- Example 2: PML 2 COLLECTION Object Pipeline (Returns ARRAY of DBREF)
-- ================================================================
-- Collect all Pumps in current Site
!pumpCollector = object COLLECTION()
!pumpCollector.type('EQUI')
!pumpCollector.scope(!!CE)

-- Define filter expression
!pumpFilter = object EXPRESSION(|PURP eq 'PUMP'|)
!pumpCollector.filter(!pumpFilter)

-- Execute query
!pumps = !pumpCollector.results()
$P Total pumps found: $!pumps.size()

-- Iterate over DBREF results
do !pumpRef values !pumps
  $P ----------------------------------------
  $P Equipment Name: $!pumpRef.name
  $P Owner Zone:     $!pumpRef.owner.name
  $P Total Nozzles:  $!pumpRef.mcount('NOZZ')
  
  -- Query specific child nozzles for this equipment
  !nozzCollector = object COLLECTION()
  !nozzCollector.type('NOZZ')
  !nozzCollector.scope(!pumpRef)
  !nozzles = !nozzCollector.results()
  
  do !n values !nozzles
    !bore = !n.attribute('BORE')
    !pos  = !n.position
    $P   Nozzle: $!n.name | Bore: $!bore mm | Pos: $!pos.string()
  enddo
enddo
```
- **What it demonstrates**: PML 1 `COLL` and `EVAL` usage, PML 2 `COLLECTION` configuration (`.type()`, `.scope()`, `.filter()`, `.results()`), hierarchical traversal via `.owner`, child counting via `.mcount()`, and nested querying.

## Reference Tables
| Query Method | Return Type | Filter Mechanism | Best Use Case |
|---|---|---|---|
| `VAR !a COLL ALL ... FOR ...` | `ARRAY of STRING` | `WITH (condition)` | Fast script one-liners, command-line inspection |
| `VAR !a EVAL (expr) FOR ...` | `ARRAY of STRING/REAL` | Mathematical / string formula | Mass arithmetic on element dimensions |
| `object COLLECTION()` | `ARRAY of DBREF` | `object EXPRESSION(...)` | Robust application code, object method chaining |
| `!ref.mcount()` | `REAL` | Optional element type string | Fast count of immediate children |
| `!ref.attribute('NAME')` | `ANY` | Attribute name string | Dynamic access to schema attributes |

## Key Takeaways
1. PML 1 `COLL` returns `STRING` arrays; PML 2 `COLLECTION()` returns `DBREF` arrays.
2. The `DBREF` object in AVEVA PML does **not** have a `.members()` method; use `COLLECTION` scoped to the element.
3. Always supply an `EXPRESSION` object when filtering PML 2 collections: `!coll.filter(!expr)`.
4. Check `!ref.badRef()` before reading attributes on any returned reference.

## Connects To
- **Ch 2**: Variables, Data Types & Scope (`DBREF`, `ARRAY`)
- **Ch 3**: Control Flow & Logic (`DO !item VALUES !array`)
- **Ch 7**: Core System Objects (`DBREF`, `EXPRESSION`)
- **Ch 14**: Marine Drafting Automation
