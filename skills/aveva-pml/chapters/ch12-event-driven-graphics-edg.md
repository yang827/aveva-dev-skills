# Chapter 12: Event Driven Graphics (EDG)

## Core Idea
Event Driven Graphics (EDG) is AVEVA's modern, non-blocking, object-oriented framework (SCRM Chapter 3) for graphical interaction within 3D design viewports. Unlike legacy commands (`ID @`, `IDP @`, `VAR !p PICK`) that suspend macro execution until a pick completes, EDG puts the graphic canvas into an event-driven state while keeping all forms, menus, and modeless tools active and responsive.

## Historical Evolution: Superseded Commands vs Modern EDG
| Feature | Legacy Picking (PML 1 / Macro Suspend) | Modern Event Driven Graphics (EDG) |
|---|---|---|
| **Syntax** | `ID @`, `ID NOZZ @`, `ID PNT @`, `VAR !p PICK` | `!!edgCntrl`, `edgPacket`, `edgPickPacket`, `edgPick` |
| **Execution Model** | **Blocking / Synchronous**: Freezes macro and UI until mouse click or Escape | **Asynchronous / Non-blocking**: Canvas behaves like a gadget; callbacks fire on mouse events |
| **GUI Responsiveness** | All other forms are unresponsive until pick finishes | Users can click other forms, switch tabs, or adjust inputs before picking |
| **Event Stacking** | Not supported; nesting macros causes state loss | Supported: `!!edgCntrl` maintains an event stack allowing suspension and resumption |
| **Multi-step Sequences** | Complex nested macros with manual state tracking | `edgPickPacket` cleanly defines multi-step pick sequences with per-step prompts |
| **Status in AVEVA** | **Superseded** (SCRM Section 3.6): Maintained only for backwards compatibility | **Standard AppWare Pattern**: The official architecture for Outfitting & Marine 3D tools |

## The EDG Object Architecture (SCRM Chapter 3)

The EDG framework consists of a hierarchy of collaborating classes:

```
  ┌──────────────────────────────────────────────────────────────┐
  │                 !!edgCntrl (Global Controller)               │
  │   - Manages active event stack                               │
  │   - Dispatches events to current top-of-stack packet         │
  └──────────────────────────────┬───────────────────────────────┘
                                 │ controls
                                 ▼
  ┌──────────────────────────────────────────────────────────────┐
  │                     edgPacket (Application Packet)           │
  │   - Encapsulates tool identity and owning form               │
  │   - Defines action callbacks: .action(), .cancelAction()     │
  └──────────────────────────────┬───────────────────────────────┘
                                 │ contains
                                 ▼
  ┌──────────────────────────────────────────────────────────────┐
  │               edgPickPacket (Pick Sequence Definition)       │
  │   - Orchestrates multi-step pick workflows                   │
  │   - Holds prompt text for status bar / cursor tooltip        │
  └──────────────┬───────────────────────────────┬───────────────┘
                 │ contains 1..*                 │ contains 1..*
                 ▼                               ▼
  ┌──────────────────────────────┐ ┌─────────────────────────────┐
  │            edgPick           │ │          edgPickType        │
  │ - Cursor style               │ │ - Element reference (DBREF) │
  │ - Filter rules (EQUI, NOZZ)  │ │ - Decomposed Point/Line/Arc │
  │ - Highlight color & style    │ │ - Surface normal & snap pos │
  └──────────────────────────────┘ └─────────────────────────────┘
```

### 1. `!!edgCntrl` (Global Event Control System)
The singleton controller for graphical interaction in AVEVA Design (`SCRM Section 3.9`).
* **`!!edgCntrl.addPacket(!packet)`**: Pushes a new `edgPacket` onto the active stack and activates its canvas handlers.
* **`!!edgCntrl.removePacket(!packet)`**: Removes the packet from the stack, restoring the previous packet or returning canvas to idle.
* **`!!edgCntrl.changePrompts()`**: Updates cursor tooltips and status bar prompts when advancing pick steps.
* **`!!edgCntrl.viewStack()`**: Diagnostic method inspecting all currently stacked packets.

### 2. `edgPacket` (Event Packet)
Represents a complete tool or utility registered into the event system (`SCRM Section 3.10`).
* **Attributes**: `.name` (STRING), `.description` (STRING), `.form` (FORM reference).
* **Callbacks**:
  * `.action()`: Invoked when a pick sequence step successfully receives graphical data.
  * `.cancelAction()`: Invoked when the user cancels or presses Escape.
  * `.initAction()`: Invoked when the packet becomes the top active event.

### 3. `edgPickPacket` (Pick Sequence Packet)
Defines the sequence, steps, and prompt directives required by an application (`SCRM Section 3.11`).
* **`.addPick(!pick, !pickType)`**: Appends a pick definition and its interpretation type to the sequence.
* **`.setPrompt(!stepIndex, !promptString)`**: Assigns descriptive user guidance text for each step.
* **`.step()`**: Advances to the next pick step in multi-point operations (e.g., Pick Start Point -> Pick End Point).
* **`.reset()`**: Resets the sequence to step 1.

### 4. `edgPickType` (Pick Interpretation)
Specifies how a physical screen hit is interpreted (`SCRM Section 3.12`):
* **Element mode**: Returns the DABACON `DBREF` pointer to the picked item.
* **Geometric decomposition**: Decomposes the hit surface into a mathematical entity:
  * `POSITION`: Snapped 3D point or P-point coordinate.
  * `LINE`: Centerline or edge primitive.
  * `PLANE`: Surface plane with normal vector.

### 5. `edgPick` (Graphic Pick & Filter Rules)
Defines canvas behavior, cursor rendering, and hit filtering (`SCRM Section 3.13`):
* **Filtering**: Restricts selection using DABACON expressions (e.g., `TYPE EQ 'NOZZ'`, `PURP EQ 'PUMP'`).
* **Cursor styles**: Crosshair, target box, aperture, rubberband line.
* **Highlighting**: Visual feedback when hovering over candidate items before mouse click.

### 6. `edgPickData` & `edgPositionData` (Payload Objects)
Data objects populated by the engine and delivered to the `.action()` callback (`SCRM Section 3.14 - 3.15`):
* `!pickData.item()`: Returns the picked `DBREF`.
* `!pickData.position()`: Returns the picked `POSITION`.
* `!pickData.normal()`: Returns the surface `DIRECTION` normal at pick point.

---

## Code Examples

### Modern Pattern: Production Tool Using `edgPacket` and `edgPickPacket`
```pml
-- ================================================================
-- Example: Modern Non-Blocking EDG Nozzle Inspection Utility
-- Source: SCRM Section 3.10 - 3.11
-- ================================================================
setup form !!nozzleEdgTool dialog
  title 'Modern EDG Nozzle Inspector'
  
  paragraph .lbl text 'Click Pick to engage 3D view interaction:' at x 1 y 1
  button .btnPick 'Engage EDG Pick' at xmin ymax+0.5 callback '!this.startEdg()'
  
  text .txtTag  'Nozzle Name:' at xmin ymax+0.5 is STRING width 25
  text .txtPos  'Position:'    at xmin ymax+0.5 is STRING width 35
  
  button .btnCancel 'Cancel Pick' at xmin ymax+1 callback '!this.stopEdg()'
  button .dismiss   'Dismiss'     at xmax+1 ymin cancel autoquit
exit

define method .nozzleEdgTool()
  -- Constructor: Define EDG Packet structure
  !this.packet = object edgPacket()
  !this.packet.name = 'NozzleInspector'
  !this.packet.form = !this
  
  -- Create pick definition with filter
  !pick = object edgPick()
  !pick.filter = 'TYPE EQ \'NOZZ\''
  
  -- Pick interpretation: return database element and position
  !pickType = object edgPickType('ELEMENT')
  
  -- Build pick sequence
  !pickPacket = object edgPickPacket()
  !pickPacket.addPick(!pick, !pickType)
  !pickPacket.setPrompt(1, 'Pick a connection NOZZLE in 3D view')
  
  !this.packet.pickPacket = !pickPacket
endmethod

define method .startEdg()
  -- Set action callback to form method
  !this.packet.action = '!this.onPickSuccess('
  !this.packet.cancelAction = '!this.onPickCancel()'
  
  -- Push packet onto active EDG controller stack
  !!edgCntrl.addPacket(!this.packet)
  $P EDG Pick engaged. 3D view is interactive.
endmethod

define method .onPickSuccess(!pickData is ANY)
  -- Callback invoked by EDG engine on successful canvas pick
  !dbItem = !pickData.item()
  !pos    = !pickData.position()
  
  if (!dbItem.badRef()) then
    $P Invalid element picked.
    return
  endif
  
  !this.txtTag.val = !dbItem.name
  !this.txtPos.val = !pos.string()
  
  -- Highlight picked nozzle in 3D
  UNENHANCE ALL
  ENHANCE $!dbItem.name COLOUR CYAN
  
  -- Remove packet from stack when workflow completes
  !!edgCntrl.removePacket(!this.packet)
  $P Pick completed successfully.
endmethod

define method .onPickCancel()
  -- Handle Escape key or user abort
  $P EDG pick aborted by user.
  !!edgCntrl.removePacket(!this.packet)
endmethod

define method .stopEdg()
  !this.onPickCancel()
endmethod
```

### Legacy Pattern (For Reference / Quick Command Line Scripts Only)
```pml
-- Legacy PML 1 approach: Blocks macro execution completely
ID NOZZ @
HANDLE ANY
  $P Pick aborted or timed out.
  return
ENDHANDLE
!nozzRef = !!CE
```

---

## Anti-patterns in Graphical Interaction
* **Using `ID @` in Modern Modeless Forms**: Using `ID @` freezes the entire user interface. If the user clicks any button on another form, the macro hangs or terminates abruptly. Modern tools should always use `!!edgCntrl.addPacket()`.
* **Forgetting to Remove Packet on Form Close**: If a form closes without calling `!!edgCntrl.removePacket()`, the canvas remains trapped in the dead tool's pick mode. Always clean up in the form's cancel/close callback.
* **Unbounded Pick Filters**: Leaving filters blank causes accidental clicks on bounding boxes, structural grids, or room volumes. Always specify explicit type restrictions (e.g. `TYPE EQ 'EQUI'`).

## Key Takeaways
1. Modern AVEVA EDG is an **asynchronous, object-oriented framework** managed via `!!edgCntrl`.
2. `edgPacket` encapsulates tool state, `edgPickPacket` orchestrates steps, and `edgPick` controls filters and cursor styles.
3. Legacy `ID @` commands are **superseded**; use them only for quick command-line macros, never for complex interactive applications.
4. Always implement `.cancelAction()` to restore canvas state when users press Escape.

## Connects To
* **Ch 4**: Error Handling & Debugging
* **Ch 8**: Forms Architecture & Lifecycle
* **Ch 11**: 3D View Gadgets & Graphical Display
* **Ch 17**: SCRM System Objects Reference Catalog
