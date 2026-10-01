# Chapter 10: Menus, Toolbars & Application Framework

## Core Idea
AVEVA PML integrates custom tools into the host application (Design, Marine Drafting, Outfitting) through the Application Framework using Menu Objects, Toolbars, PML Add-in descriptor files (`.pmladd`), and the system-level forms and window manager `!fmsys` (SOFTCG Chapter 22 & 23, TM-2263 Chapter 18).

## Frameworks Introduced

### 1. PML Menu Object Architecture
* **Declaration**: `define menu !!<menuname> ... exit`
* **Storage**: Stored in lowercase files `<menuname>.pmlfnc` or embedded directly inside `.pmlfrm`.
* **Structural Elements**:
  * Action Items: `add 'Label' '<callback>'`
  * Cascading Submenus: `add submenu !!<submenuname> 'Label'`
  * Visual Dividers: `add separator`
  * Toggle Items: `add toggle 'Label' '!this.onToggle()' val TRUE`
* **Context / Pop-Up Menus**: Bound to gadgets using `menu !!<menuname>`. Right-clicking the gadget triggers the menu.

### 2. Application Framework Add-in System (`.pmladd`)
Replaces legacy PML 1 `DBAR` edits with safe, isolated manifests placed in `%PDMSUI%\<MODULE>\ADDINS\`:
* **Manifest Attributes**:
  * Add-in Object: `ADDIN <AddinName>`
  * UI Insertion Point: Menu bar category, Ribbon tab, or Toolbar ID
  * Associated Icons: High-resolution PNG or BMP button icons
* **Lifecycle**: Automatically loaded by the host module during application startup.

### 3. The `FMSYS` System Manager Object (SOFTCG Chapter 22)
`!fmsys` is a pre-instantiated global runtime object controlling application-wide windowing, cursors, forms, and inter-application switching:
* **`.screensize()`**: Returns an `ARRAY` containing the current display resolution in pixels `[width, height]`.
* **`.clipboard(!text)`**: Writes string data to the operating system clipboard; without arguments, reads current clipboard text.
* **`.currentDocument()`**: Returns the handle to the active MDI document window.
* **`.loadForm(!formName)`**: Explicitly pre-compiles and loads a form definition into memory without displaying it.
* **`.refresh()`**: Forces an immediate redraw and refresh of all open graphical views and form layouts.
* **`.cursor(!cursorType)`**: Changes the application cursor icon (`'WAIT'`, `'ARROW'`, `'CROSS'`).
* **`.setDefaultFormat(!formatObj)`**: Enforces project-wide numerical precision and default engineering units on all text fields.
* **`.swapApplication(!appName)`**: Dynamically transitions the user session to another AVEVA application module (e.g. from Equipment to Pipework).

---

## Key Concepts
* **`define menu` / `exit`**: Syntactic block defining a reusable menu structure.
* **`BARMENU`**: Top-level menu bar attached to a form or main window.
* **`TOOLBAR`**: Container gadget hosting icon buttons, toggle states, and separators for quick tool access.
* **`.pmladd` File**: Plain text configuration registering a custom PML application with the module framework.
* **`!fmsys`**: Central system manager object handling windowing, documents, and environment state.

---

## Code Examples

### Comprehensive Example: Custom Context Menu and `!fmsys` Clipboard Integration
```pml
-- ================================================================
-- Example: Context Menu with FMSYS Clipboard & View Refresh
-- ================================================================

-- 1. Define Reusable Context Menu
define menu !!pipeContextMenu
  add 'Query Attributes'     '!this.querySelectedPipe()'
  add 'Copy Name to Clip'    '!this.copyNameToClipboard()'
  add separator
  add 'Highlight in 3D'      '!this.highlightSelectedPipe()'
  add 'Delete Element'       '!this.deleteSelectedPipe()'
exit

-- 2. Define Form Hosting List with Attached Menu
setup form !!pipeManager dialog
  title 'Piping Component Manager'
  
  paragraph .p1 text 'Right-click a pipe to access operations:' at x 1 y 1
  list .lstPipes 'Active Lines:' at x 1 ymax+0.5 width 28 height 8 menu !!pipeContextMenu
  
  button .btnRefresh 'Refresh View' at x 1 ymax+1 callback '!this.onRefreshViews()'
  button .dismiss    'Dismiss'      at xmax+1 ymin cancel autoquit
exit

define method .pipeManager()
  -- Constructor: Populate pipes
  !pipes = ARRAY()
  !pipes.append('/PIPE-100-CW-01')
  !pipes.append('/PIPE-100-CW-02')
  !pipes.append('/PIPE-150-FW-05')
  !this.lstPipes.dtext = !pipes
endmethod

define method .copyNameToClipboard()
  !sel = !this.lstPipes.selection
  if (!sel.unset()) then
    return
  endif
  !selectedName = !this.lstPipes.dtext[!sel]
  
  -- Use FMSYS to write to OS clipboard
  !fmsys.clipboard(!selectedName)
  $P Copied $!selectedName to clipboard.
endmethod

define method .highlightSelectedPipe()
  !sel = !this.lstPipes.selection
  if (!sel.unset()) then
    return
  endif
  !selectedName = !this.lstPipes.dtext[!sel]
  UNH ALL
  ENH $!selectedName COLOUR GREEN
endmethod

define method .onRefreshViews()
  -- Change cursor to wait and force redraw
  !fmsys.cursor('WAIT')
  !fmsys.refresh()
  !fmsys.cursor('ARROW')
  $P Views refreshed.
endmethod
```

---

## Anti-patterns
* **Modifying Core AVEVA Distribution Files (`dbar`)**: Directly editing AVEVA product distribution files breaks during software service pack upgrades. Always use `.pmladd` add-ins.
* **Menu Name Clashes**: Using generic menu names like `!!fileMenu` will override native application menus. Prefix custom menus with your company/project namespace (e.g., `!!corpMarineToolsMenu`).
* **Unescaped Quotes in Menu Callbacks**: Callbacks containing unescaped single quotes will fail parsing; use pipe delimiters `|...|` or call parameterless methods.

## Reference Tables
| Component / Method | Definition / Syntax | Role / Behavior |
|---|---|---|
| Menu Declaration | `define menu !!name ... exit` | Declares menu object |
| Menu Item | `add 'Label' 'callback'` | Invokes callback on click |
| Submenu | `add submenu !!sub 'Label'` | Cascades secondary menu |
| Separator | `add separator` | Visual horizontal divider |
| Gadget Menu Binding | `menu !!name` on gadget | Binds right-click popup |
| `!fmsys.clipboard(str)`| String parameter | Writes text to OS clipboard |
| `!fmsys.refresh()` | Parameterless | Redraws all viewports and forms |
| `!fmsys.cursor(type)` | `'WAIT'`, `'ARROW'`, `'CROSS'` | Switches system mouse cursor |
| `!fmsys.screensize()` | Parameterless | Returns `ARRAY` `[width, height]` in pixels |

## Key Takeaways
1. Menu objects are declared via `define menu !!name ... exit` and can be used as bar menus or right-click popups.
2. Bind menus to gadgets using the `menu !!menuname` attribute.
3. Integrate custom corporate applications using modern `.pmladd` add-in descriptors rather than modifying core `dbar` files.
4. `!fmsys` provides native platform access to clipboard, screen size, view refreshing, and system cursors.

### 4. Core Managed Objects Architecture (SOFTCG Appendix A)
At the lowest runtime layer, the PML GUI framework is underpinned by native C++ Core Managed Objects:
* **`FORM Core Code Interface`**: System-level methods handling message pump dispatch, HWND window handles, native focus management, and dialog parentage.
* **`GADGET Core Code Interface`**: Manages underlying OS widget styles, font metrics, low-level mouse click coordinates, and event dispatch.
* **`MENUFIELD Core Code Interface`**: Bridges PML defined menu actions with the AVEVA Application Framework menu dispatcher and toolbars.

---

## Connects To
* **Ch 8**: Forms Architecture & Lifecycle
* **Ch 9**: GUI Gadgets & Layout System
* **Ch 11**: 3D View Gadgets & Graphical Display
* **Ch 17**: SCRM System Objects Reference Catalog
