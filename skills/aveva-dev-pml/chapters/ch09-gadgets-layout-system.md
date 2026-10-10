# Chapter 9: GUI Gadgets & Layout System

## Core Idea
AVEVA PML provides an extensive palette of user interface controls (gadgets) embedded inside forms (SOFTCG Chapter 19 & 20, SCRM Section 2.4). Gadget placement uses a flexible relative grid positioning syntax (character columns and line rows) coupled with anchoring (`<fganch>`), docking (`<fgdock>`), and container hierarchy.

## The Complete AVEVA PML Gadget Suite

### 1. Action & Hyperlink Gadgets
* **`BUTTON`**: Standard clickable push button.
  * Modifiers: `ok`, `cancel`, `apply`, `reset`, `autoquit`, `pixmap /icon.png`.
  * Syntax: `button .btnName 'Label' at x y callback '!this.onAction()'`
* **`LINKLABEL`**: Hyperlink-style text button triggering navigation or URL callbacks.
  * Syntax: `linklabel .lnkDocs 'Open Online Manual' at x y callback '!this.openHelp()'`

### 2. Input & Numeric Validation Gadgets
* **`TEXT`**: Single-line text input field.
  * Syntax: `text .txtName 'Tag:' at x y is STRING width 20`
* **`NUMERICINPUT`**: Numeric field bound to unit conversion and precision formatting.
  * Syntax: `numericinput .numDist 'Offset (mm):' at x y is REAL width 15 format 'DISTANCE'`
* **`SLIDER`**: Continuous range slider for rapid interactive parameter adjustments.
  * Syntax: `slider .sldAlpha 'Transparency:' at x y width 20 range 0 100 callback '!this.onSlide()'`

### 3. Selection & Choice Gadgets
* **`OPTION`**: Drop-down selection list (read-only combo).
  * Syntax: `option .optType 'Element Type:' at x y width 15 callback '!this.onTypeChange()'`
  * Properties: `.dtext` (`ARRAY` of display strings), `.val` (selected string), `.selection` (selected index).
* **`COMBOBOX`**: Editable drop-down combining free text typing with a list of suggestions.
  * Syntax: `combobox .cboSearch 'Filter:' at x y width 20 callback '!this.onEdit()'`
* **`LIST`**: Scrollable multi-row list box.
  * Modifiers: `single` (default) or `multiple` (multi-select).
  * Syntax: `list .lstItems 'Available Pipes:' at x y width 25 height 8 multiple`
  * **Multi-Column List Gadget (SOFTCG 20.12 & SCRM 2.5.11/12)**:
    Defines tabular multi-column grids with explicit headers, column widths, and alignments:
    ```pml
    list .grid 'Components:' at x y width 45 height 10 -
      columns |Name| width 18 alignment left -
              |Type| width 12 alignment centre -
              |Bore| width 10 alignment right
    ```
    * Populating columns: Supply an `ARRAY of ARRAY of STRING` or 2D string matrix to `.dtext`.
    * Fast item iteration: `do !row values !this.grid.items() ... enddo`.
* **`TOGGLE`**: Standard boolean checkbox.
  * Syntax: `toggle .chkLock 'Lock Coordinates' at x y val FALSE`
* **`RTOGGLE`**: Radio toggle button operating within a mutually exclusive radio group.
  * Syntax: `rtoggle .radMode1 'Plan View' at x y group 1 val TRUE`
  * Syntax: `rtoggle .radMode2 'Section View' at x y group 1`
* **Pixmap Option & Button Support (SOFTCG 20.8)**:
  Buttons and Option gadgets support icon bitmaps alongside or replacing text:
  * `button .btnSearch pixmap 16 16 at x y callback '!this.onSearch()'`
  * Assigning icons dynamically: `!this.btnSearch.addPixmap('search_icon.png')`.
  * Option items with status pixmaps: `!this.optStatus.addPixmap('online.png', 'offline.png')`.

### 4. Container & Structural Grouping Gadgets
* **`FRAME`**: Visual border enclosing related gadgets.
  * **Standard Frame**: `frame .fraProps 'Properties' at x y ... exit`
  * **Tabset Frame (SOFTCG Chapter 18 & TM-2263 Chapter 10.19)**:
    Hosts multiple switchable sub-pages within a single screen area:
    ```pml
    frame .tabs '' at x y width 40 height 15 tabset anchor all callback '!this.onTabChange()'
      frame .tabGeom 'Geometry'
        text .txtLen 'Length:' at x 1 y 1 is REAL
      exit
      frame .tabSpecs 'Specifications'
        option .optSpec 'Spec Code:' at x 1 y 1
      exit
    exit
    ```
    * Programmatic tab switching: `!this.tabs.val = 1` or `!this.tabs.val = 'Specifications'`.
    * Dynamic tab page management (SOFTCG Chapter 18): `!this.tabs.ManagePages()`, `!this.tabs.AddPage('NewPage')`, `!this.tabs.SetPage(2)`.
    * Open callback triggered whenever a tab page becomes active.
  * **Fold Up Panel Frame (SOFTCG 18.5 & TM-2263 10.11.1)**:
    Collapsible accordion header panel:
    ```pml
    frame .fldAdv 'Advanced Settings' at x y foldup ... exit
    ```
    * Programmatic control: `!this.fldAdv.fold()`, `!this.fldAdv.unfold()`.
    * State query: `!this.fldAdv.folded()` returns `BOOLEAN`.
* **`CONTAINER`**: Scrollable panel viewport hosting nested gadgets or child forms.
  * Syntax: `container .pnlScroll at x y width 30 height 15 scroll`
* **`SELECTOR`**: Native DABACON database tree hierarchy navigator widget.
  * Displays the database hierarchy tree directly inside a PML form.
  * Syntax: `selector .dbTree at x y width 30 height 12 callback '!this.onSelect()'`
  * Methods: `.root(!dbref)` (sets tree root), `.selected()` (returns active picked `DBREF`).
* **`LINE`**: Decorative divider line.
  * Syntax: `line .div1 at x y horizontal width 35`

### 5. Display & Multiline Gadgets
* **`PARAGRAPH`**: Static text label, multi-line description, or static icon.
  * Syntax: `paragraph .lblDesc at x y text 'Select a pipe to inspect details:' width 30`
* **`TEXTPANE`**: Multi-line rich text area for logging, notes, or multi-line reports.
  * Syntax: `textpane .logArea 'Event Log:' at x y width 40 height 6 scroll`
  * Methods: `.val = !array`, `.append('new line')`, `.clear()`.
* **`PROGRESSBAR`**: Visual operation completion indicator.
  * Syntax: `progressbar .bar at x y width 30 range 0 100`

---

## Form Layout Geometry System

### 1. Relative Placement Syntax
Gadget positions are measured in character column widths (`x`) and text line heights (`y`):
* `xmin`, `xmax`: Left and right coordinate boundaries of the preceding gadget.
* `ymin`, `ymax`: Top and bottom coordinate boundaries of the preceding gadget.
* **Common Placement Formulas**:
  * Directly below previous gadget: `at xmin ymax+0.5`
  * Immediately to the right: `at xmax+1 ymin`
  * Align with left edge: `at xmin ...`

### 2. Auto-placement & Directional Flow
* `path right`: Successive gadgets are automatically placed horizontally from left to right.
* `path down`: Successive gadgets are automatically placed vertically downwards.
* `dist <x_dist> <y_dist>`: Sets default spacing between auto-placed gadgets.

### 3. Responsive Anchoring & Docking
Controls how gadgets move and stretch when a `resizable` form is resized by the user:
* **Anchoring (`anchor`)**:
  * `anchor top + left` (default for top controls)
  * `anchor bottom + right` (standard for Dismiss / OK / Cancel buttons)
  * `anchor all` (stretches lists, textpanes, and 3D views to fill expanding windows)
* **Docking (`dock`)**:
  * `dock top`, `dock bottom`, `dock left`, `dock right`, `dock fill`.

---

## Code Examples

### Comprehensive Form Demonstrating Modern Gadgets & Selector
```pml
-- ================================================================
-- Example: Advanced Engineering Inspection Form
-- ================================================================
setup form !!engInspector dialog resizable
  title 'Engineering Model & Component Inspector'

  -- Left Column: Database Hierarchy Tree Selector
  paragraph .p1 at x 1 y 1 text 'DABACON Hierarchy:'
  selector .tree at xmin ymax+0.5 width 25 height 14 anchor top+bottom+left callback '!this.onTreeSelect()'

  -- Right Column: Tabset Container
  frame .mainTabs '' at xmax+1 y 1 width 40 height 14 tabset anchor all
    
    -- Tab 1: Core Attributes & Options
    frame .tabAttr 'Attributes'
      text .txtElem 'Element Name:' at x 1 y 1 is STRING width 22
      text .txtType 'Element Type:' at xmin ymax+0.5 is STRING width 15
      line .sep1 at xmin ymax+0.5 horizontal width 35
      option .optMaterial 'Specification:' at xmin ymax+0.5 width 20
      toggle .chkLock 'Lock Modifications' at xmin ymax+0.5 val FALSE
    exit

    -- Tab 2: Multiline Textpane Log
    frame .tabLog 'Execution Log'
      textpane .logBox 'Operation History:' at x 1 y 1 width 36 height 9 anchor all
    exit
  exit

  -- Bottom Action Bar with responsive anchoring
  line .sepBottom at x 1 ymax+0.5 horizontal width 68 anchor bottom+left+right
  button .btnApply  'Apply Changes' at x 1 ymax+0.5 ok anchor bottom+left
  button .btnCancel 'Cancel'        at xmax+1 ymin cancel autoquit anchor bottom+right
exit

define method .engInspector()
  -- Constructor: Initialize database selector root
  !this.tree.root(!!CE)

  -- Initialize options
  !specs = ARRAY()
  !specs.append('A1A - Standard Carbon Steel')
  !specs.append('F1C - High Pressure Alloy')
  !this.optMaterial.dtext = !specs
endmethod

define method .onTreeSelect()
  !selectedRef = !this.tree.selected()
  if (not !selectedRef.badRef()) then
    !this.txtElem.val = !selectedRef.name
    !this.txtType.val = !selectedRef.type
    !this.logBox.append('Navigated to: ' & !selectedRef.name)
  endif
endmethod
```

---

## Anti-patterns
* **Hardcoding Absolute Layout Coordinates**: Specifying bare numbers (`at x 20 y 35`) breaks across different system display scaling settings. Always use relative coordinates (`xmin`, `xmax`, `ymin`, `ymax`).
* **Unclosed Frames**: Forgetting `exit` on child `frame` or `container` declarations creates broken layout hierarchies.
* **Assigning Non-Array to `.dtext`**: Setting `.dtext` on `LIST` or `OPTION` gadgets with a scalar string causes runtime assignment errors; always supply an `ARRAY`.
* **Calling `.dtext.append(...)`**: `.dtext` is a *property* holding an `ARRAY of STRING` — it exposes no methods. `!this.myList.dtext.append('new item')` is invalid PML. `.append()` belongs to the `ARRAY` object (Ch 2): build or extend an `ARRAY` with `.append()`, then assign the whole array to `.dtext` (see the Ch 8 nozzle-list pattern). This applies identically to `.dtext` on `OPTION`, `LIST`, and `COMBOBOX`.

## Reference Tables
| Gadget Keyword | Primary Attributes | Return / Data Property |
|---|---|---|
| `BUTTON` | `ok`, `cancel`, `apply`, `pixmap` | Fires `.callback` |
| `LINKLABEL` | Hyperlink appearance | Fires `.callback` |
| `TEXT` | `is STRING` / `is REAL`, `width` | `.val` (holds entered text/value) |
| `NUMERICINPUT` | `format`, `units`, `width` | `.val` (validated `REAL`) |
| `SLIDER` | `range min max`, `step` | `.val` (current numeric position) |
| `OPTION` | `width`, `.dtext` | `.val` (selected string), `.selection` (index) |
| `COMBOBOX` | `width`, `.dtext` | `.val` (typed or selected string) |
| `LIST` | `width`, `height`, `multiple` | `.val` (selected index / array of indices) |
| `TOGGLE` | Checkbox | `.val` (`TRUE` or `FALSE`) |
| `RTOGGLE` | `group <id>` | `.val` (mutually exclusive `BOOLEAN`) |
| `SELECTOR` | `root(!ref)`, `width`, `height` | `.selected()` (returns chosen `DBREF`) |
| `TEXTPANE` | `width`, `height`, `scroll` | `.val` (`ARRAY of STRING`), `.append(s)` |
| `CONTAINER` | `scroll`, `width`, `height` | Viewport hosting nested gadgets |
| `FRAME` | `tabset`, `foldup` | Container boundary |

## Key Takeaways
1. AVEVA PML provides 15+ specialized gadgets covering actions, text, lists, selectors, and containers.
2. Build responsive layouts using relative anchors (`xmin`, `xmax`, `ymin`, `ymax`) and `anchor all` / `dock fill`.
3. Use `SELECTOR` for direct tree navigation of the DABACON database hierarchy.
4. Always pair opening `frame` and `container` blocks with corresponding `exit` statements.

## Connects To
* **Ch 8**: Forms Architecture & Lifecycle
* **Ch 10**: Menus, Toolbars & Application Framework
* **Ch 11**: 3D View Gadgets & Graphical Display
* **Ch 17**: SCRM System Objects Reference Catalog
