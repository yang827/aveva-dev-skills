# Design & Automation Patterns — AVEVA Data Model

## Pattern: Upward Lineage Traversal
**When to use**: Determining the owning equipment, zone, or site of any leaf element (e.g. from nozzle or valve).
**How**:
```pml
!current = CE
!owner = !current.OWNER
WHILE (!owner.TYPE NE 'SITE' AND !owner.TYPE NE 'WORL') DO
  !current = !owner
  !owner = !current.OWNER
ENDDO
!siteName = !owner.NAME
```
**Trade-offs**: Fast and robust; avoids hardcoding assumption of tree depth.

## Pattern: Downward Collection Traversal
**When to use**: Scanning all constituents of a specific type under a primary assembly (e.g. all nozzles under equipment, all valves in a pipe).
**How**:
```pml
!nozzleList = EVALUATE (ALL NOZZ FOR CE)
DO !n VALUES !nozzleList
  !nozz = !n
  !bore = !nozz.BORE
  !pos = !nozz.POS WRT /*
ENDDO
```
**Trade-offs**: `EVALUATE (ALL ... FOR ...)` uses internal C++ engine indexes; significantly faster than recursive PML loops.

## Pattern: Safe Dynamic Attribute Access
**When to use**: Querying attributes or UDAs that may not exist on all inspected element types.
**How**:
```pml
!validAttrs = CE.ALIST
IF (!validAttrs.CONTAINS(':STRESS_STATUS')) THEN
  !status = CE.:STRESS_STATUS
ELSE
  !status = 'N/A'
ENDIF
```
**Trade-offs**: Prevents fatal runtime macro crashes caused by querying invalid attributes on mismatched element types.

## Pattern: Branch Flow Continuity Validation
**When to use**: Validating that a piping branch is fully connected from Head to Tail prior to isometric extraction.
**How**:
1. Verify `CE.HREF.ISSET()` and `CE.TREF.ISSET()`.
2. Inspect first component: verify arrive P-point matches Head connection.
3. Traverse sequential components: verify `PLEAVE` of component $k$ connects to `PARRIVE` of $k+1$.
4. Verify last component leave P-point matches Tail connection.
**Trade-offs**: Catches flow disconnections early, preventing ISODRAFT batch failures.

## Pattern: World-Space Spatial Transformation
**When to use**: Comparing positions of elements residing in different parent coordinate systems.
**How**:
```pml
!pos1 = /EQUI-P101.POS WRT /*
!pos2 = /PIPE-100-B1.HPOS WRT /*
!distance = !pos1.DISTANCE(!pos2)
```
**Trade-offs**: Eliminates manual trigonometric transformation across nested parent rotation matrices.

## Pattern: Catalogue Spec-Driven Component Insertion
**When to use**: Programmatically inserting standard valves, elbows, or flanges into pipelines.
**How**:
1. Navigate to target insertion position in `BRAN`.
2. Issue `NEW <TYPE>` (e.g. `NEW VALV`).
3. Set `STYP <Skey>` or choose spec selector: `CHOOSE SPREF`.
4. Align orientation with flow: `CONNECT`.
**Trade-offs**: Guarantees spec compliance and proper bolt/gasket selection over manual geometry assignment.

## Pattern: Engineering Item Cross-Discipline Tag Binding
**When to use**: Binding 3D physical models to 2D P&ID diagrams and procurement registers.
**How**:
1. Query master tag from `/ENGD`: `/ENG-P-101A`.
2. In Design session: navigate to `/P-101A`, execute `ENGREF /ENG-P-101A`.
3. In Schematic session: navigate to `SCPUMP`, execute `ENGREF /ENG-P-101A`.
**Trade-offs**: Guarantees single source of truth for process duty, design pressure, and temperature.
