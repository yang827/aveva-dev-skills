# Chapter 19: Production Exercises & Code Recipes

## Core Idea
This chapter compiles authentic, verified code recipes directly from AVEVA Marine training courses TM-2263 (PML Basic) and TM-2401 (PML for Marine Drafting). These templates demonstrate production-proven patterns for parametric modeling, error trapping, GUI collection browsing, 3D viewport control, and Marine Drafting automation.

## Frameworks & Recipes Included

### Recipe 1: Parametric Equipment Modeling Macro (`ex3.mac`)
- **Source**: TM-2263 Appendix B3.
- **Problem**: Build a parametric Handwheel with center hub, washer, bolt, dish, spokes, and outer ring, using calculated variables, relative P-point connections, and loops to duplicate radial spokes.
```pml
------------------------------------------------------------------
-- Programming Macro Language Training Course
-- Exercise 3 - Parameterised Macro to build Handwheel with Loop
------------------------------------------------------------------
$d1=HandWheel
$d2=100
$d3=50
$d4=500

-- Calculate derived dimensions from parameters
!WashDia  = $2 - 20
!WashThk  = $2 / 20
!BoltSize = $2 / 2
!BoltThk  = $2 / 10
!Dia1     = $4 + ( $2 / 4 )
!Dia2     = !Dia1 + $3

NEW EQUIPMENT /$1

-- Center Hub
NEW SUBE /$1-Centre
NEW BOX /$1-Centre-Box XLEN $2 YLEN $2 ZLEN $2
NEW CYLINDER DIAM $!WashDia HEIG $!WashThk
CONN P1 TO P3 OF PREV
NEW BOX XLEN $!BoltSize YLEN $!BoltSize ZLEN $!BoltThk
CONN P6 TO P2 OF PREV
NEW DISH DIAM $!BoltSize HEIG $!BoltThk
CONN P2 TO P3 OF PREV

-- Arm 1 and Outer Ring Torus
NEW SUBE /$1-Arm-1
NEW CYLINDER DIAM $3 HEIG $4
CONN P1 TO P2 OF /$1-Centre-Box
NEW CTORUS RINS $!Dia1 ROUT $!Dia2
CONN P0 TO P0 OF /$1-Centre-Box

-- Loop to create rotated copies for the other 3 spokes
do !p from 2 to 4
  NEW SUBE /$1-Arm-$!p COPY PREV
  ROTATE BY 90 ABOUT U
enddo

ADD /$1 AUTO /$1
$P Handwheel /$1 created and added to 3D view.
```

---

### Recipe 2: Equipment & Nozzle Inspector Form (`ex10.pmlfrm`)
- **Source**: TM-2263 Appendix B14.
- **Problem**: Create a modeless form that queries all equipment under the current `SITE` or `ZONE`, displays them in an `OPTION` dropdown, and dynamically updates a `LIST` gadget with all child `NOZZ` elements using the PML 2 `COLLECTION` object.
```pml
-- ================================================================
-- Equipment and Nozzle Browser Form
-- ================================================================
setup form !!ex10 dialog resizable
  !this.formTitle = |Equipment and Nozzle Browser|
  !this.initcall  = |!this.init()|

  frame .equipframe at x 0 y 0
    para .title at xmin.equipframe + 0.5 ymin.equipframe + 0.5 text |Available Equipment:|
    option .equip at xmin.equipframe + 0.5 ymax.title call |!this.collNozz()| width 15
    button .site |Refresh| at xmax.equip + 1 ymax.title call |!this.init()|
    list .nozz at xmin.equipframe + 0.5 ymax.equip width 45 length 6
  exit
  button .dismiss 'Dismiss' at xmin.equipframe ymax.equipframe + 0.5 cancel autoquit
exit

define method .init()
  if (!!CE.type.eq(|SITE|)) then
    !level = |SITE|
  else
    !level = |ZONE|
  endif

  -- PML 1 collection to gather Equipment
  VAR !coll COLL ALL EQUIP FOR $!level
  handle ANY
    !!Alert.Error(|Navigate to an EQUI, ZONE, or SITE element first|)
  elsehandle NONE
    if (!coll.size().eq(0) and !level.eq(|ZONE|)) then
      VAR !coll COLL ALL EQUIP FOR SITE
      !!Alert.Message(|No equipment found in active ZONE; searching entire SITE|)
    endif
    VAR !name EVAL FLNN FOR ALL FROM !coll
    !this.equip.dtext = !name
    !this.equip.rtext = !coll
    !this.collNozz()
  endhandle
endmethod

define method .collNozz()
  !equipRef = !this.equip.selection().dbref()
  if (!equipRef.unset()) then
    !this.nozz.clear()
  else
    -- Modern PML 2 COLLECTION object
    !nozzColl = object COLLECTION()
    !nozzColl.type('NOZZ')
    !nozzColl.scope(!equipRef)
    !results = !nozzColl.results()

    if (!nozzColl.size().geq(1)) then
      !dtext = ARRAY()
      !rtext = ARRAY()
      do !i from 1 to !nozzColl.size()
        !dtext[!i] = !results[!i].flnn
        !rtext[!i] = !results[!i].string()
      enddo
      !this.nozz.dtext = !dtext
      !this.nozz.rtext = !rtext
    else
      !this.nozz.clear()
    endif
  endif
endmethod
```

---

### Recipe 3: Context Pop-Up Menu on Gadget (`ex11a.pmlfrm`)
- **Source**: TM-2263 Appendix B15.
- **Problem**: Attach a right-click pop-up menu to the nozzle list allowing immediate 3D navigation to the selected nozzle.
```pml
-- Method on form to attach right-click context menu
define method .setupContextMenu()
  !this.newMenu(|pop1|)
  !this.pop1.add('CALLBACK', 'Navigate to Nozzle', '!!CE = !this.nozz.selection().dbref()', 'NOZZ')
  !this.pop1.add('CALLBACK', 'Highlight Nozzle in 3D', '!this.highlightNozz()', 'NOZZ')
endmethod

define method .highlightNozz()
  !ref = !this.nozz.selection().dbref()
  if (not !ref.badRef()) then
    UNENHANCE ALL
    ENHANCE $!ref.name COLOUR CYAN
  endif
endmethod
```

---

### Recipe 4: Marine Drafting Drawing Inspector & Layer Setup
- **Source**: TM-2401 Chapter 4 & 5.
- **Problem**: Initialize MarAPI, check if a drawing is current, query drawing names, set layer to 10, and export document metadata.
```pml
import 'marapi'
handle (1000, 0)
  -- marapi already loaded
endhandle

!marDraft = object MarDrafting()
!marUi    = object MarUi()
!marUtil  = object MarUtil()

if (not !marDraft.DwgCurrent()) then
  !marUi.MessageConfirm('Please open a Marine Drafting drawing before running this tool.')
  return
endif

!dwgName  = !marDraft.DwgNameGet()
!formName = !marDraft.FormNameGet()
$P Active Drawing: $!dwgName on Form: $!formName

-- Activate Annotations Layer (Layer 10)
!marDraft.LayerActiveSet(10)

-- Confirm environment directory
!symbDir = !marUtil.TBEnvironmentGet('SBB_SYMBDIR')
$P Current Marine Symbol Path: $!symbDir

-- Save drawing changes
!marDraft.DwgSave()
$P Drawing $!dwgName saved successfully.
```

### Recipe 5: Marine Drafting Model Part Pick, DBREF Linking & Balloon Leader (`TM-2401 Exercise 3 & 4`)
- **Source**: TM-2401 Chapter 4.8, 4.13 & Chapter 5.
- **Problem**: Prompt the user to pick an element on the drawing, retrieve its underlying DABACON `DBREF` to obtain the part position number (`PosNo`), and automatically draw a position number balloon with leader line linked to the picked point.
```pml
import 'marapi'
handle (1000, 0)
endhandle

using namespace 'Aveva.Marine.Ui'
using namespace 'Aveva.Marine.Geometry'
using namespace 'Aveva.Marine.Drafting'

define function !!addPosnoLeaderFromPick() is ANY
  !marDraft = object MarDrafting()
  !marUi    = object MarUi()
  !marUtil  = object MarUtil()

  if (not !marDraft.DwgCurrent()) then
    !marUi.MessageConfirm('Open an active drawing first.')
    return
  endif

  -- 1. Prompt user to indicate model part on canvas
  !pickPt = object MarPointPlanar()
  !res = !marUi.PointPlanarReqPML('Indicate model part on sheet:', !pickPt)
  if (!res ne !marUtil.OkPML()) then
    return
  endif

  -- 2. Identify drafting element and resolve DABACON database reference
  !compHandle = !marDraft.ComponentIdentify(!pickPt)
  !dbrefNum   = !marDraft.ElementDbrefGet(!compHandle)

  !dbElem = object DBREF()
  !dbElem.Dbref(!dbrefNum)
  !posno = !dbElem.attribute('PosNo')

  if (!posno.unset() or !posno.string() eq '') then
    !marUi.MessageConfirm('Part has no assigned PosNo attribute in DABACON.')
    return
  endif

  -- 3. Prompt user for note/balloon placement position
  !balloonPt = object MarPointPlanar()
  !res2 = !marUi.PointPlanarReqPML('Indicate balloon position:', !balloonPt)
  if (!res2 ne !marUtil.OkPML()) then
    return
  endif

  -- 4. Construct leader line geometry (MarPolygonPlanar)
  !leaderLine = object MarPolygonPlanar(!pickPt)
  !leaderLine.AddPoint(!balloonPt)

  -- 5. Create position number balloon linked to leader line
  !hPosno = !marDraft.PosnoNew(!posno.string(), !leaderLine)
  !marDraft.DwgSave()
  !marUi.MessageNoConfirm('Placed PosNo balloon [' & !posno.string() & '] successfully.')
endfunction
```

---

### Recipe 6: Marine Drafting Hull Block Selection & Extraction (`TM-2401 Exercise 2`)
- **Source**: TM-2401 Chapter 3.4 & Exercise 2.
- **Problem**: Query the Product Information Model (PIM) for all hull blocks matching wildcard `'F*'`, present them in a standard selection dialog, and extract panel components.
```pml
import 'marapi'
handle (1000, 0)
endhandle

using namespace 'Aveva.Marine.Ui'
using namespace 'Aveva.Marine.Utility'

define function !!selectHullBlockAndExtract() is ANY
  !marUi = object MarUi()

  -- 1. Scoped DABACON Collection for BLOCK objects
  !collection = object COLLECTION()
  !collection.type('BLOCK')
  !filterExpr = object EXPRESSION(|MATCHWILD(ATTRIB NAMN, 'F*')|)
  !collection.filter(!filterExpr)

  !collRes = !collection.results()
  !blockQuery = object BLOCK(|!collRes[!evalIndex].namn|)
  !blockList = !collRes.evaluate(!blockQuery)

  if (!blockList.size() eq 0) then
    !marUi.MessageConfirm('No hull blocks found matching pattern F*.')
    return
  endif

  -- 2. Interactive Block Selection Dialog
  !selectedIdx = REAL()
  !marUi.StringSelect('Hull Production Blocks', 'Select Block:', '', !blockList, !selectedIdx)

  if (!selectedIdx gt 0) then
    !chosenBlock = !blockList[!selectedIdx]
    !marUi.MessageConfirm('Selected block: ' & !chosenBlock & '. Ready for panel extraction.')
  endif
endfunction
```

---

## Key Takeaways
1. Parameterized macros (`$d1=`, `$2`, `$p`) excel at procedural primitive modeling.
2. Forms should combine `VAR ... COLL` for top-level search and `object COLLECTION()` for scoped, typed child querying.
3. Marine Drafting procedures require checking `!marDraft.DwgCurrent()` before executing sheet operations.
4. Bridge 2D drawing entities to DABACON records via `!marDraft.ElementDbrefGet(!h)`.
5. Always pair visual enhancements with `UNENHANCE ALL` cleanup callbacks.

## Connects To
- **Ch 1**: PML Basics & Environment
- **Ch 8**: Forms Architecture & Lifecycle
- **Ch 9**: GUI Gadgets & Layout System
- **Ch 13**: Collections & Database Queries
- **Ch 14**: Marine Drafting Automation
- **Ch 18**: PDMS 3D Modeling Primitives
- **Ch 20**: SCRM Appendix A Expressions & Functions
