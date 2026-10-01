# Chapter 14: AVEVA Marine Drafting PML Automation

## Core Idea
AVEVA Marine Drafting automation (TM-2401) interfaces PML with the Marine Drawing Database (`SB_PDB`), the Product Information Model (PIM), and the MarAPI runtime assembly (`NETmarAPI.chm`). It provides an interactive User Interface API (`Aveva.Marine.Ui`), coordinate translation across multiple reference frames (`!marUtil.TraCoordShip`, `!marUtil.TraCoordPan`, `!marDraft.PointTranform`), drawing lifecycle management, hierarchical element handles, and automated drafting component generation (dimensions, hatching, symbols, notes).

---

## Frameworks Introduced

### 1. MarAPI Assembly & Namespace Binding
MarAPI exposes .NET assemblies to the PML runtime environment via `import 'MarAPI'`.
```pml
import 'marapi'
handle (1000, 0)
  -- MarAPI already registered in current session
endhandle

using namespace 'Aveva.Marine.Utility'
using namespace 'Aveva.Marine.Ui'
using namespace 'Aveva.Marine.Geometry'
using namespace 'Aveva.Marine.Drafting'
using namespace 'Aveva.Marine.DataExtraction'
```

### 2. Interactive Dialogs & System Button Codes (TM-2401 Chapter 2)
MarAPI provides standard prompt and confirmation dialogs through `MarUi()`.
* **Confirmation & Informational Dialogs**:
  * `!marUi.MessageConfirm('Operation completed.')` — Modal prompt requiring user OK.
  * `!marUi.MessageNoConfirm('Processing item...')` — Non-blocking notification.
  * `!marUi.MessageQuestion('Proceed with overwrite?')` — Prompts Yes/No question.
* **Return Code Comparisons via `!marUtil`**:
  Never hardcode integer literals (e.g. `1` or `2`). Always use runtime methods:
  ```pml
  !marUtil = object MarUtil()
  if (!res eq !marUtil.OkPML()) then
    -- User pressed OK
  elseif (!res eq !marUtil.CancelPML()) then
    -- User pressed Cancel
  elseif (!res eq !marUtil.YesPML()) then
    -- User pressed Yes
  elseif (!res eq !marUtil.NoPML()) then
    -- User pressed No
  endif
  ```

### 3. User Input & Geometry Requests (TM-2401 Section 2.3 - 2.5)
* **Text / String Request (`StrReqPML`)**:
  ```pml
  !textVal = ''
  !res = !marUi.StrReqPML('Enter Frame Tag:', !textVal, 'FR50')
  ```
* **Integer Request (`IntReq`)**:
  ```pml
  !intVal = 0
  !res = !marUi.IntReq('Lines per page:', !intVal, 25)
  ```
* **Floating Point Request (`RealReqPML`)**:
  ```pml
  !xCoord = REAL()
  !res = !marUi.RealReqPML('Panel X coordinate:', !xCoord, 1250.0)
  ```
* **Standard Selection Dialogs (`StringSelect`, `ColorSelect`, `SymbolSelect`)**:
  ```pml
  !selectedIdx = REAL()
  !marUi.StringSelect('Hull Blocks', 'Select block to inspect:', '', !blockNamesArray, !selectedIdx)
  ```
* **Point Planar Request & Cursor Modes (`PointPlanarReqPML`)**:
  Prompts the user to click a 2D position on the drawing sheet:
  ```pml
  !pt = object MarPointPlanar()
  !res = !marUi.PointPlanarReqPML('Indicate insertion point', !pt)
  ```
  * **Cursor Configuration (`MarCursorType` & `MarStatPointPlanarReq`)**:
    Supported cursor modes: `CrossHair` (default), `RubberBand`, `RubberRectangle`, `RubberCircle`, `DragCursor`.
    ```pml
    !cursor = object MarCursorType()
    !curPoint = object MarPointPlanar(0, 0)
    !cursor.SetRubberBand(!curPoint)
    
    !status = object MarStatPointPlanarReq()
    !status.Cursor(!cursor)
    !res = !marUi.PointPlanarReqPML('Indicate opposite point:', !pt, !status)
    ```
* **3D Global Point Request (`PointReqPML`)**:
  Prompts user for a 3D coordinate point in model space:
  ```pml
  !pt3d = object MarPoint()
  !res = !marUi.PointReqPML('Indicate 3D point:', !pt3d)
  ```

### 4. Coordinate Translation System (TM-2401 Section 2.5)
Marine Drafting handles three fundamental coordinate spaces:
1. **Drawing Coordinate System `(U, V)`**: 2D millimeter sheet space with origin `(0, 0)`.
2. **Global Coordinate System `(X, Y, Z)`**: 3D ship reference system.
3. **Panel Coordinate System `(U, V, W)`**: Local 3D/2D structural panel reference system.

* **Translation from Drawing Sheet to Global Ship Coordinates (`TraCoordShip`)**:
  ```pml
  !sheetPt = object MarPointPlanar()
  !shipPt  = object MarPoint()
  !res = !marUi.PointPlanarReqPML('Indicate point on panel', !sheetPt)
  if (!res eq !marUtil.OkPML()) then
    !panelName = 'F206-DK2'
    !ok = !marUtil.TraCoordShip(!sheetPt, !panelName, !shipPt)
    if (!ok) then
      !marUi.MessageConfirm('Global XYZ: ' & !shipPt.X().string() & ', ' & !shipPt.Y().string() & ', ' & !shipPt.Z().string())
    endif
  endif
  ```
  *Note*: If `!panelName` is empty `''`, the system calculates coordinates using the projection plane of the view closest to the picked point.
* **Translation to Panel Local Coordinates (`TraCoordPan`)**:
  ```pml
  !ok = !marUtil.TraCoordPan(!sheetPt, !panelName, !panelPt)
  ```
* **Translation from Ship 3D to Drawing Sheet 2D (`PointTranform`)**:
  ```pml
  !sheetPtOut = object MarPointPlanar()
  !marDraft.PointTranform(!shipPt, !sheetPtOut)
  ```
* **Global Coordinate to Structural Frame / Offset (`CoordToPos`)**:
  Converts numeric millimeters into standard ship labeling: `FR<number>+<offset>`:
  ```pml
  !frNumber = 0
  !frOffset = 0
  -- Axis: 1=X (Frames), 2=Y (Longitudinals), 3=Z (Waterlines/Decks)
  !marUtil.CoordToPos(1, 124500, !frNumber, !frOffset)
  if (!frOffset gt 0) then
    !tag = 'FR' & !frNumber.string() & '+' & !frOffset.string()
  else
    !tag = 'FR' & !frNumber.string()
  endif
  ```

### 5. Product Information Model (PIM) Data Extraction (TM-2401 Chapter 3)
* **High-Speed Data Extraction Engine (`MarDex`)**:
  Extracts structural hull information via hierarchical query syntax:
  ```pml
  using namespace 'Aveva.Marine.DataExtraction'
  !marDex = object MarDex()
  !cmd = |HULL.PANEL('F206-DK2').PLATE(1).NAME(1)|
  !res = !marDex.ExtractPML(!cmd)
  if (!res eq 0) then
    do
      !res = !marDex.NextResultPML()
      if (!res eq -1) then
        break  -- End of result tree (EOF)
      elseif (!res eq 1) then
        !intVal = !marDex.GetIntPML()
      elseif (!res eq 2) then
        !realVal = !marDex.GetReal()
      elseif (!res eq 3) then
        !strVal = !marDex.GetString()
      elseif (!res eq 4) then
        !vec3d = !marDex.GetReavec3D()    -- [X, Y, Z]
      elseif (!res eq 5) then
        !box = !marDex.GetBox()            -- [Xmin, Ymin, Zmin, Xmax, Ymax, Zmax]
      elseif (!res eq 6) then
        !vec2d = !marDex.GetReavec2D()
      endif
    enddo
  endif
  ```
* **Marine Database Object Retrieval (`MarDataBase`)**:
  ```pml
  using namespace 'Aveva.Marine.Utility'
  !marDB = object MarDataBase()
  !criteria = object MarObjectCriteria()
  !criteria.SetNamePML('F206*')
  !panels = !marDB.ObjectListGetPML(!criteria, 'SB_PLDB')
  do !p values !panels
    !pName = !p.name()
  enddo
  ```

### 6. Drawing Lifecycle & Export (`MarDrafting`)
* **Strict SDI Rule**: Marine Drafting allows **only one active drawing at any time**.
  ```pml
  !marDraft = object MarDrafting()
  if (!marDraft.DwgCurrent()) then
    !marDraft.DwgSave()
    !marDraft.DwgClose()
  endif
  !marDraft.DwgActivate('DWG_FRAME_45', 'SB_PDB')
  ```
* **Drawing Creation & Opening**:
  * `!marDraft.DwgCreate('DWG_NAME', 'TEMPLATE_NAME', 'SB_PDB')` — Create new sheet from template.
  * `!marDraft.DwgOpen('DWG_NAME', 'SB_PDB')` — Open existing sheet.
  * `!marDraft.DwgDelete('DWG_NAME', 'SB_PDB')` — Remove drawing from database.
* **Supported Export Formats (`DwgExport`)**: DXF, DWG, PDF, CGM, PostScript (PS), Plotter (PLT).

### 7. Element Handles (`MarElementHandle`) & Model Interaction (TM-2401 Section 4.2 - 4.4)
Every drawing entity (view, subview, component, contour, text, symbol, dimension, note) is represented by an opaque `MarElementHandle`.
* **Model Identification & Highlighting**:
  ```pml
  !pt = object MarPointPlanar()
  !res = !marUi.PointPlanarReqPML('Pick model part:', !pt)
  !hComp = !marDraft.ModelIdentify(!pt, !mod, !subview, !comp)
  !marDraft.ElementHighlight(!hComp)
  -- After processing:
  !marDraft.ElementUnhighlight(!hComp)
  ```
* **DABACON Reference Bridge (`ElementDbrefGet` & `ElementDESIDbrefGet`)**:
  Converts a 2D drafting element handle directly into a DABACON `DBREF`:
  ```pml
  !viewHandle = !marDraft.ComponentIdentify(!pt)
  !dbrefNum = !marDraft.ElementDbrefGet(!viewHandle)      -- Drafting database reference
  !desiNum  = !marDraft.ElementDESIDbrefGet(!viewHandle)  -- Design database reference
  
  !obj = object DBREF()
  !obj.Dbref(!dbrefNum)
  !posno = !obj.attribute('PosNo')
  !marUi.MessageConfirm('Position Number: ' & !posno.string())
  ```

### 8. Drafting Components & Annotations (TM-2401 Section 4.8)
* **Text Creation (`TextNew` / `TextCreate`)**:
  ```pml
  !pt = object MarPointPlanar(100, 100)
  !hText = !marDraft.TextNew('WELD SEAM INSPECTION', !pt)
  ```
* **Structural Notes & Position Numbers (`NoteNew`, `PosnoNew`)**:
  ```pml
  !pStart = object MarPointPlanar(50, 50)
  !leader = object MarPolygonPlanar(!pStart)
  !pEnd   = object MarPointPlanar(70, 80)
  !leader.AddPoint(!pEnd)
  
  -- Create Note with leader line:
  !hNote = !marDraft.NoteNew('CHECK WEB CUTOUT', !leader)
  
  -- Create Position Number balloon:
  !hPos = !marDraft.PosnoNew('56', !leader)
  
  -- Identify and relocate existing balloon reference point:
  !hPickedPosno = !marDraft.PosnoIdentify(!pStart)
  !newPos = object MarPointPlanar(75, 85)
  !marDraft.ReferenceMove(!hPickedPosno, !newPos)
  ```
* **2D Linear Dimensions (`DimLinearNew`)**:
  ```pml
  !p1 = object MarPointPlanar(10, 10)
  !measurePts = object MarPolygonPlanar(!p1)
  !p2 = object MarPointPlanar(100, 10)
  !measurePts.AddPoint(!p2)
  
  !dir = object MarVectorPlanar(1, 0)         -- Horizontal dimension line
  !linePos = object MarPointPlanar(55, 5)     -- Dimension text line location
  -- Type: 1 = Normal, 2 = Chain, 3 = Staircase
  !hDim = !marDraft.DimLinearNew(!measurePts, 1, !dir, !linePos)
  ```
* **Hatching (`HatchNew`)**:
  Applies hatching patterns to closed planar contours (`MarContourPlanar`).
* **Subpicture Hierarchy (`SubviewNew`, `ComponentNew`, `SubpictureCurrentGetPML`)**:
  ```pml
  !subviewHandle = !marDraft.SubviewNew('Section_A_Details')
  !compHandle    = !marDraft.ComponentNew('Plate_Labels')
  !marDraft.SubpictureCurrentSet(!compHandle)
  
  -- Query active hierarchy levels (returns [viewHandle, subviewHandle, compHandle]):
  !currSubArray = !marDraft.SubpictureCurrentGetPML()
  ```
* **Defaults Configuration (`DefaultValueGet` / `DefaultValueSet`)**:
  ```pml
  !oldFont = !marDraft.DefaultValueGet('TEXT_FONT')
  !marDraft.DefaultValueSet('TEXT_FONT:Courier New')
  -- Create entities using Courier New...
  !marDraft.DefaultValueSet(!oldFont)
  ```

---

## Code Examples

### Production Marine Drafting Automation Routine
```pml
-- ================================================================
-- Example: Automated Drawing Verification, Model Query and Annotation
-- Source: TM-2401 Chapters 2, 3, 4
-- ================================================================
import 'marapi'
handle (1000, 0)
  -- MarAPI already loaded
endhandle

using namespace 'Aveva.Marine.Utility'
using namespace 'Aveva.Marine.Ui'
using namespace 'Aveva.Marine.Geometry'
using namespace 'Aveva.Marine.Drafting'

define function !!marineDraftingDemo() is ANY
  !marDraft = object MarDrafting()
  !marUi    = object MarUi()
  !marUtil  = object MarUtil()

  -- 1. Verify Active Drawing
  if (not !marDraft.DwgCurrent()) then
    !marUi.MessageConfirm('Error: No active drawing open in Marine Drafting.')
    return
  endif

  !dwgName = !marDraft.DwgNameGet()
  !marUi.MessageNoConfirm('Processing drawing: ' & !dwgName)

  -- 2. Ask User for Confirmation to Add Note
  !ans = !marUi.AnswerReqPML('Marine Drafting Tool', 'Add inspection note to drawing?')
  if (!ans ne !marUtil.YesPML()) then
    !marUi.MessageNoConfirm('Operation cancelled by user.')
    return
  endif

  -- 3. Prompt for Note Text with Default Value
  !noteText = ''
  !res = !marUi.StrReqPML('Enter Note Text:', !noteText, 'CHECK STIFFENER WELD')
  if (!res ne !marUtil.OkPML() or !noteText.trim() eq '') then
    return
  endif

  -- 4. Interactive Planar Point Pick (Crosshair cursor)
  !pickPt = object MarPointPlanar()
  !resPt = !marUi.PointPlanarReqPML('Indicate note placement point', !pickPt)
  if (!resPt ne !marUtil.OkPML()) then
    !marUi.MessageNoConfirm('Point indication aborted.')
    return
  endif

  -- 5. Set Active Layer & Add Text Element
  !marDraft.LayerActiveSet(15)  -- Layer 15: General Annotations
  
  -- Create Text with standard modal parameters (height: 3.5mm, slant: 0)
  !hText = !marDraft.TextCreate(!pickPt.X(), !pickPt.Y(), !noteText, 3.5, 0.0)
  
  -- 6. Save Drawing to Database
  !marDraft.DwgSave()
  !marUi.MessageNoConfirm('Note created and drawing saved.')
endfunction
```

---

## Anti-patterns in Marine Drafting
* **Inventing Non-Existent Translation APIs**: Do not use fabricated methods like `WorldToSheet()`. Always use `!marUtil.TraCoordShip()`, `!marUtil.TraCoordPan()`, and `!marDraft.PointTranform()`.
* **Hardcoding Return Comparison Values (`EQ 1` or `EQ 'OK'`)**: System buttons must always be checked against `!marUtil` methods (`!res eq !marUtil.OkPML()`, `!res eq !marUtil.YesPML()`).
* **Creating Elements Without Verifying `DwgCurrent()`**: Attempting to query or create drawing elements when no drawing is loaded crashes the MarAPI host process.
* **Opening Drawings Concurrently**: Marine Drafting is strictly Single Document Interface (SDI); always call `!marDraft.DwgClose()` before activating a different drawing.

## Key Takeaways
1. Always import `marapi` inside `handle (1000, 0)`.
2. Interactive dialogs (`AnswerReqPML`, `StrReqPML`, `PointPlanarReqPML`) return status codes compared against `!marUtil.YesPML()`, `OkPML()`, etc.
3. Coordinate translation uses `!marUtil.TraCoordShip` (Sheet to Ship), `!marUtil.TraCoordPan` (Sheet to Panel), and `!marDraft.PointTranform` (Ship to Sheet). Structural frames are converted via `!marUtil.CoordToPos`.
4. High-performance data extraction from the hull model is driven by `Aveva.Marine.DataExtraction.MarDex`.
5. Database references on drawing elements are retrieved via `!marDraft.ElementDbrefGet(!handle)`.

## Connects To
* **Ch 4**: Error Handling & Debugging
* **Ch 11**: 3D View Gadgets & Graphical Display
* **Ch 13**: Collections & DABACON Queries
* **Ch 15**: MarAPI & .NET Interoperability
