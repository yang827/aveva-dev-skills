# AVEVA PML Design Patterns & Architectural Recipes

Production-tested design patterns for AVEVA Marine (Marine 12) and AVEVA PDMS macro and application development.

---

## Pattern 1: Encapsulated Form State (MVC Form Pattern)
**When to use**: Building any non-trivial user interface in `.pmlfrm` that manages database elements or selections.
**How**:
1. Keep the `setup form ... exit` block clean, declaring only visual gadget layout and event bindings (`callback '!this.method()'`).
2. Declare all state variables inside the form definition as member properties: `member .currentRef is DBREF`, `member .elementList is ARRAY`.
3. Initialize arrays and defaults inside the constructor method: `define method .formname()`.
4. Implement all database operations, validation, and UI updates in dedicated member methods.
**Trade-offs**: Prevents global variable collisions and enables clean hot-reloading (`pml reload form`).

---

## Pattern 2: Defensive DABACON Mutation Guard
**When to use**: Creating, renaming, repositioning, or deleting elements in the DABACON database hierarchy.
**How**:
1. Create a transaction checkpoint: `MARK 'BEFORE_MUTATION'`.
2. Verify hierarchy prerequisites before issuing commands (e.g. check `!!CE.type` or navigate to a known valid parent).
3. Attach a structured `HANDLE` block immediately after the mutation command — the mutation command stays BEFORE the trap; only recovery code goes inside `HANDLE ... ENDHANDLE` (never wrap the mutation inside it).
4. Catch known error codes specifically (`HANDLE (41, 8)` for wrong hierarchy level, `(41, 12)` for duplicate names).
5. Catch-all `ELSEHANDLE ANY` rolls back the transaction via `UNDO` and reports the error via `return error ... noalert`.
6. Confirm execution in `ELSEHANDLE NONE`.
**Trade-offs**: Prevents macro aborts and database inconsistencies at the cost of explicit error branching around commands.

---

## Pattern 3: Scoped Typed Database Query Pipeline
**When to use**: Searching for model components (valves, nozzles, equipment, hull panels) without impacting project-wide performance.
**How**:
1. Instantiate a modern `COLLECTION` object: `!coll = object COLLECTION()`.
2. Restrict search scope strictly to the active subsystem or assembly: `!coll.scope(!parentRef)`.
3. Set the target element type: `!coll.type('NOZZ')`.
4. Compile an `EXPRESSION` object for property filtering: `!expr = object EXPRESSION(|BORE ge 100|)` and bind via `!coll.filter(!expr)`.
5. Retrieve results as an `ARRAY of DBREF`: `!results = !coll.results()`.
**Trade-offs**: Faster and safer than scanning global collections or parsing text output from PML 1 `COLL` commands, returning typed pointers directly.

---

## Pattern 4: Modern Event Driven Graphics (EDG) Packet Pattern
**When to use**: Enabling non-blocking 3D graphical selection inside modern modeless tools (SCRM Chapter 3).
**How**:
1. Define an `edgPacket` instance inside the tool form's constructor:
   `!this.packet = object edgPacket()`
2. Build an `edgPick` with explicit filter rules (`TYPE EQ 'NOZZ'`).
3. Build an `edgPickPacket` orchestrating step prompts and bind to `!this.packet.pickPacket`.
4. Implement `.action` callback receiving `edgPickData` and `.cancelAction` restoring form state.
5. Push onto active stack via `!!edgCntrl.addPacket(!this.packet)`.
6. Remove from stack on completion or form dismissal via `!!edgCntrl.removePacket(!this.packet)`.
**Trade-offs**: Completely non-blocking; keeps all open forms interactive without freezing macro execution.

---

## Pattern 5: Marine Drafting Interactive Request & Button Check Pattern
**When to use**: Requesting user decisions, strings, numbers, or planar points in AVEVA Marine Drafting (TM-2401).
**How**:
1. Issue `import 'marapi'`, immediately followed by `handle (1000, 0) endhandle` (import stays outside the trap), and instantiate `!marUi = object MarUi()`, `!marUtil = object MarUtil()`.
2. For questions: Use `!res = !marUi.AnswerReqPML('Title', 'Prompt')`.
3. Always test against `!marUtil` button methods:
   `if (!res eq !marUtil.YesPML()) then ... elseif (!res eq !marUtil.NoPML()) then ... endif`
4. For inputs: Use `!marUi.StrReqPML('Prompt', !strVar [, 'default'])`, `!marUi.IntReq('Prompt', !intVar [, default])`, or `!marUi.RealReqPML('Prompt', !realVar [, default])`.
5. For selections: Use `!marUi.StringSelect('Title', 'Prompt', default, !items, !selected)`.
6. For points: Use `!marUi.PointPlanarReqPML('Indicate point', !planarPt)` with standard crosshair or rubberband cursors.
**Trade-offs**: Guarantees version-safe status code handling across AVEVA Marine releases.

---

## Pattern 6: Value vs Reference Memory Isolation Pattern
**When to use**: Passing arrays, complex objects, or form members into working functions or loops (SOFTCG Chapter 9).
**How**:
1. Recognize that primitives (`REAL`, `STRING`, `BOOLEAN`) copy by value, whereas `ARRAY` and UDOs assign by reference.
2. When creating a local working copy of an array or object:
   `!localWorkingArray = !originalArray.clone()`
3. Modify `!localWorkingArray` freely without corrupting the original caller instance.
**Trade-offs**: Prevents insidious memory aliasing bugs and unintended side effects across form methods.

---

## Pattern 7: Relative Primitive P-Point Assembly
**When to use**: Procedurally generating equipment models, structural nozzles, or parametric piping components (TM-2263 Appendix A).
**How**:
1. Create parent `EQUIPMENT` or `SUBEQUIPMENT`.
2. Build the primary base primitive (e.g., `CYLINDER` or `BOX`).
3. Position every subsequent primitive relative to existing components using P-points:
   `CONN P1 TO P3 OF PREV` or `CONN P1 TO P2 OF /TARGET-ELEM`.
4. Apply directional adjustments using relative orientations: `ORI P1 IS -U OF PREV`.
5. Add the complete equipment to the active view: `ADD $!equiName AUTO`.
**Trade-offs**: Eliminates manual trigonometric calculation of world coordinates; components stay docked when dimensions scale.

---

## Pattern 8: Marine Drafting Single-Drawing Lifecycle Guard
**When to use**: Opening, generating, or processing drawings in AVEVA Marine Drafting (TM-2401).
**How**:
1. Issue `import 'marapi'` followed immediately by `handle (1000, 0) endhandle` (the import stays outside the trap).
2. Instantiate `!marDraft = object MarDrafting()`.
3. Check drawing status: `if (!marDraft.DwgCurrent()) then`.
4. Prompt user to save or close the active sheet before opening a new document:
   `!marDraft.DwgSave()` followed by `!marDraft.DwgClose()`.
5. Open or create target drawing.
**Trade-offs**: Prevents fatal runtime exceptions caused by Marine Drafting's strict Single Document Interface (SDI) architecture.


---

## Pattern 9: Marine Drafting Coordinate Translation & DABACON Bridge
**When to use**: Translating 2D drawing picks into 3D global coordinates or linking drawing entities to structural DABACON records (TM-2401 Section 2.5 & 4.13).
**How**:
1. Prompt user for drawing sheet 2D point via `!marUi.PointPlanarReqPML('Pick point', !sheetPt)`.
2. Translate 2D sheet pick to 3D global ship coordinate on a structural panel:
   `!ok = !marUtil.TraCoordShip(!sheetPt, !panelName, !ship3dPt)`
3. Convert global longitudinal coordinate to ship frame notation:
   `!marUtil.CoordToPos(1, !ship3dPt.X(), !frNum, !frOff)`
4. Link drawing entity to underlying DABACON element:
   `!elemHandle = !marDraft.ComponentIdentify(!sheetPt)`
   `!dbrefNum = !marDraft.ElementDbrefGet(!elemHandle)`
   `!dbObj = object DBREF()`
   `!dbObj.Dbref(!dbrefNum)`
   `!posno = !dbObj.attribute('PosNo')`
**Trade-offs**: Eliminates manual projection math and connects 2D drawings directly to live database attributes.