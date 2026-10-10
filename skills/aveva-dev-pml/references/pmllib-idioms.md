# PMLLIB Delivered-Source Idioms — Verified Patterns from Official AVEVA Code

Distilled idioms mined from the bundled AVEVA-delivered PML snapshot ([PMLLIB/](../PMLLIB/), 6075 source files). Every snippet is **real shipped code** (lightly trimmed, never re-indented semantics); the source path and line are cited so you can open the original for full context. Prefer these patterns over inventing syntax — they compile on the shipping product.

**When to use**: after consulting the chapters and [cheatsheet](../cheatsheet.md), if a construct's exact official usage is unclear, grep [pmllib-index.md](pmllib-index.md) then open the cited file. Use these recipes for the 80% of cases below.

---

## 1. File Header & Form Skeleton

Every delivered file opens with the standard header block; keep it in new files (tooling like `pml.index` and upgrade diffs rely on it).

```pml
------------------------------------------------------------------------
--
-- Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
--
-- File:            edgdiameter.pmlfrm
--   Type:          Form Definition
--   Group:         Event Driven Graphics
--     Keyword:     EDG
--   Module:        common
--   Replaces:
-- Author:          <name>
-- Created:         <date>
-- Description:     <one-liner>
------------------------------------------------------------------------
```

Form body skeleton — properties, gadgets, `member` state, then `exit`; methods live in the **same file after the `exit`**:

```pml
setup form !!splMembers

  !!splMembers.formTitle     = 'Spooler Members'
  !!splMembers.iconTitle     = 'MEMBERS'
  !!splMembers.callback      = '!!splMembers.init()'      -- shown/raised callback
  !!splMembers.formRevision  = ' $Revision: 1.44 $ '

  member .isodCe     is DBREF
  member .currentDb  is STRING
  member .edgPacket  is EDGPACKET
  ...
exit
-- End of form definition for !!splMembers

define method .splMembers()
  ...   -- constructor: menus, pixmaps, callbacks
endmethod
```

*Source: `spooler/forms/splmembers.pmlfrm` L40–L136; `common/forms/edgdiameter.pmlfrm` L1–L74*

**Rule patterns observed**: `callback` on the form = run on show (`init()`); `cancelCall` = run on close (`close()`); gadget callbacks are **strings** naming methods, often with trailing `(` for partial application of the gadget argument.

---

## 2. Menus: newMenu, bar, toggle, popup

Menus are created in the constructor via `newMenu('<name>')` matching a `bar add` name in the form body:

```pml
-- form body
  bar
    add 'Control'   .controlMenu
    add 'Goto'      .navigateMenu
  exit

-- constructor method
  !this.newMenu('controlMenu')
  !this.controlMenu.add('callback', 'Resize...', 'show !!splMemResize')
  !this.controlMenu.add('separator')
  !this.controlMenu.add('toggle',  'Show Extract Claims', '!!spooler.functions.extractClaims(')
  !this.controlMenu.add('menu',    'Switch', 'switchMenu')          -- submenu
  !this.controlMenu.select(|Show Extract Claims|, !!showMemExtracts) -- set toggle state
```

Gadget right-mouse popup: `newMenu` + `!gadget.setPopup(!menu)`, and menu callbacks receive `(MENU, STRING pickedField)` — branch on `!menu.pickedField.upcase()`.

*Sources: `spooler/forms/splmembers.pmlfrm` L70–L136; `common/forms/edgdiameter.pmlfrm` L65–L119*

---

## 3. Selector on Database + Navigation

`selector ... database auto` lists elements; `selection().dbRef()` yields the DBREF inside the callback:

```pml
-- form body
  selector .dbList at xmin.prev ymax+0.2 single width $!!splMemWidth height $!!splMemHeight
           database auto $!!splExtractFlag

-- constructor
  !this.dbList.callback = '!!splMembers.navigate(!!splMembers.dbList.selection().dbRef())'
  !this.find.callback   = '!!splMembers.findName(!!splMembers.find)'   -- text gadget find
```

`$!!global` inline expansion sizes the gadget from globals so `pml reload form` keeps user resize choices (globals `!!splMemWidth/Height` are `undefined()`-defaulted at form-definition time).

*Source: `spooler/forms/splmembers.pmlfrm` L53–L134*

Option-style pick list (`dtext`/`rtext` parallel arrays, built at form-definition time):

```pml
  option .fontThk call |!this.formMethods.view()| width 4
  ...
  !dtext = ARRAY() !dtext[1] = |Thin| !dtext[2] = |Bold|
  !rtext = ARRAY() !rtext[1] = |1|    !rtext[2] = |4|
  !this.fontThk.dtext = !dtext
  !this.fontThk.rtext = !rtext
```

*Source: `draft/forms/drafontsel.pmlfrm` L42–L92*

---

## 4. Event Driven Graphics (this snapshot's API)

> Verified in this codebase: packets are built with `definePosition/elementPick/defineMeasure/definePlane/aidpick` and registered via `!!edgCntrl.add(!packet)`; removal by description string; `!!edgCntrl.escape()` cancels the current pick. (SCRM-style `definePick`/`edgPickPacket` names do **not** appear in this snapshot — prefer the delivered API above.)

Measure packet (full minimal example, 30 lines):

```pml
  !packet        = object EDGPACKET()
  !packet.defineMeasure('DISTANCE')             -- or 'SHORTEST'
  !packet.action = '!!edgDiameter.measure(!this.return[1])'
  !!edgCntrl.add(!packet)

  define method .measure(!line is LINE)         -- action callback payload: LINE
    if (!line.unset()) then
      !this.diameter.val = 0
    else
      !this.diameter.val = !line.length()
    endif
  endmethod
```

Position pick and element pick (from asl/accommodation forms):

```pml
  !packet = object EDGPACKET()
  !packet.definePosition('Pick elevation for side exit')
  !packet.action = '!!aslLadder.pickPosition(!this.return[1])'
  !!edgCntrl.add(!packet)

  !packet.elementPick(!prompt)                  -- payload = picked element(s)
  !!edgCntrl.add(!packet)
```

Pick payload object (`EDGPICKDATA`) members in use: `.item` (DBREF, guard `!edgPick.item.badref()`), `.primaryObject` (e.g. `'FACET'`), `.facets.unique()`, `.positionData().plane`.

Housekeeping: `!!edgCntrl.remove('<packet description>')` when a form closes; `!!edgCntrl.setPrompt('...')` to re-prompt.

*Sources: `common/forms/edgdiameter.pmlfrm` L94–L177; `asl/forms/aslladder.pmlfrm` L1556; `asl/forms/aslhandra.pmlfrm` L3113, L2752; `mds/design/objects/mdslsupport.pmlobj` L751–L786*

---

## 5. COLLECTION + EXPRESSION Queries

Canonical pipeline, straight from delivered code — note `MATCHWILD` inside the expression and `scope()` **after** `filter()`:

```pml
  !collection = object COLLECTION()
  !expression = object EXPRESSION('MATCHWILD(DESCRIPTION, |*' & !attributeName.upCase() & '|)')
  !collection.filter(!expression)
  !collection.scope(!allDDSets[1])
  !collection.type('DDAT')
  !allDDat = !collection.results()
  skip if (!allDDat.empty())
```

Iterate results with `do !x value <array>`; attribute access stays typed (`!allDDat[1].maxMin[1]`).

*Source: `common/functions/getcriteriasetintersection.pmlfnc` L51–L67*

---

## 6. Environment Variables (EVAR) — and the evars.bat link

Reading an env var inside PML (the delivered wrapper functions live in `limbo/functions/evar.pmlfnc` and `common/functions/evarsplit.pmlfnc`):

```pml
  var !tempDir evar temp                       -- raw command form
  !paths = !!evarSplit('PDMSUSER')             -- ARRAY of paths, splits on ';' or space,
  !first = !paths[1]                           --   drops entries whose FILE is unset
  !one   = !!evar('HOME')                      -- single STRING value
```

(Implementation of `!!evarSplit`: `var !row EVAR '$!evar'` then `split(|;|)`/`split()` — i.e. PML expands `$!evar` into the `EVAR` command.)

**The evars.bat contract, in AVEVA's own words** — delivered code warns the user and *generates batch scripts that call it*:

```pml
  !!alert.warning('Environment variable $!evar is not set in pdms evars.bat file. Set the variable ...')
  ...
  !batchFile.writeRecord(|call "%pdms_installed_addin_dir%\evars.bat" "%pdms_installed_addin_dir%"|)
```

Batch tooling must therefore `call` the instance's `evars.bat` (or parse it) before it can see `PMLLIB`/`PDMSWK`/... — offline scripts can read the file as text. `assembly/forms/assybatch.pmlfrm` even writes a fresh `evars_<date>.bat` per generated batch folder.

*Sources: `common/functions/evarsplit.pmlfnc` L34–L56; `asl/forms/aslselections.pmlfrm` L1491–L1493; `pipefabricationmanager/draft/functions/pfPipeMakeSpoolDrwg.pmlfnc` L94; `marinedrafting/functions/setmarptypebatch.pmlfnc` L86; `assembly/forms/assybatch.pmlfrm` L297–L312, L561*

Resolving **PMLLIB itself** at runtime (delivered usage):

```pml
  !directory = !!evarSplit('pmllib')[1] & |pipefabricationmanager\draft\functions\|
```

*Source: `pipefabricationmanager/draft/forms/pfPipeSpoolDwg.pmlfrm` L1489*

---

## 7. marapi Import — the Canonical Guard

Every delivered wrapper that touches MarAPI issues the import **at file top level**, immediately followed by the trailing trap (`import` stays OUTSIDE the `handle` block — the block is the recovery for the already-loaded error, not a wrapper):

```pml
import 'marapi'
handle (1000, 0)
endhandle

define function !!dimcreate(!act is REAL)
  using namespace 'AVEVA.Marine.UI'
  !mui = object MARUI()
  !mui.dimcreate(!act)
endfunction
```

`(1000, 0)` swallows the "assembly already loaded" error on re-execution. Note the object-name style: `object MARUI()` (uppercase), namespace string `'AVEVA.Marine.UI'`.

*Sources: `marinedrafting/functions/dimcreate.pmlfnc` L55–L63; `marinedrafting/functions/moddimension.pmlfnc` L31–L39 (same pattern in 13 more marinedrafting/assembly files)*

---

## 8. Embedding a .NET Control (pmlnetcontrol)

```pml
  frame .frmPosition panel                         anchor all at x1   ymax+0.2
    container .netPositionFrame PMLNetCONTROL 'NET' anchor all at x0.5 ymax width 36 height 4
  exit

  using namespace 'Aveva.Pdms.Presentation'
  member .posControl is POSITIONCONTROL

-- in initialise():
  !this.posControl = object POSITIONCONTROL()
  ...
  !this.netPositionFrame.control = !this.posControl.handle()   -- hand HWND to container
```

*Source: `common/forms/edgshipposition.pmlfrm` L31–L138*

---

## 9. File / Directory I/O

The `FILE` object doubles as directory handle; `readFile()` returns lines and throws on unreadable files, so the risky call is issued FIRST and a trailing `handle any / skip` trap catches it — never put the guarded call inside the trap (SKILL.md Core Framework 9):

```pml
  !dir = object FILE(!path & '\' & !module & '\ADDINS')
  skip if (!dir.exists().not())
  !files = !dir.files()                     -- ARRAY of FILE objects
  do !file values !files
    !lines = !file.readFile()
    handle any
      skip
    endhandle
    do !l values !lines
      skip if (!l.trim().substring(1, 1) eq '#' or !l.trim() eq '')
      !part1 = !l.trim().upcase().part(1, ':')
      !part2 = !l.after(':').trim()
      ...
```

Parsing idiom `part(1, ':')` / `.after(':')` / `.before()` is the official replacement for string arithmetic.

*Source: `common/functions/appreadappdefns.pmlfnc` L57–L80*

---

## 10. Icons & Shared Paths

Never hardcode icon paths — resolve through the PML resource function (icons ship under `PMLLIB/icons/`):

```pml
  !this.prev.addPixmap(!!pml.getPathName('leftarrow9x12.png'))
```

*Source: `spooler/forms/splmembers.pmlfrm` L125–L126*

---

## Cross-references

- Syntax rules & anti-patterns: [SKILL.md](../SKILL.md) Core Frameworks, [cheatsheet.md](../cheatsheet.md)
- Deeper recipes in the knowledge base (not from PMLLIB): [ch19](../chapters/ch19-production-exercises-recipes.md), [patterns.md](../patterns.md)
- Full file listing: [pmllib-index.md](pmllib-index.md) (grep by module/flag, then open the source)
