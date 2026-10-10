# Chapter 8: Forms Architecture & Lifecycle

## Core Idea
Forms in AVEVA PML (`.pmlfrm`) are specialized, globally accessible user interface objects containing graphical controls (gadgets), member state, and event callbacks. Forms adhere to a formal lifecycle: definition, instantiation, initialization, display, event handling, and termination.

## Frameworks Introduced
- **Form Definition Architecture (`.pmlfrm`)**:
  - The visual specification is declared between `setup form !!<formname> [dialog] [resizable]` and `exit`.
  - Stored in a file named `<formname_in_lowercase>.pmlfrm` in `PMLLIB`.
  - Member variables are declared inside the form using `member .<varname> is <TYPE>`.
  - Methods and event handlers are implemented as member methods: `define method .<methodName>() ... endmethod`.
- **Form Lifecycle & Event Hooks**:
  - **Instantiate**: Loaded dynamically into memory on first reference.
  - **Constructor (`.formname()`)**: Initializes internal state before gadgets are shown.
  - **`initcall`**: Event fired each time the form is shown (`show !!formname`).
  - **`firstcall`**: Event fired only once the very first time the form is rendered.
  - **`opencall` / `open callback` (TM-2263 10.19)**: Event fired when a form opens or when a container/tabset page is activated.
  - **`okcall` / `cancelcall`**: Built-in callbacks triggered by default form action buttons.
  - **`quitcall`**: Event triggered when the user clicks the window close button (`X`).
  - **Termination**: `hide !!formname` or programmatic dismissal.
- **Runtime Hot-Reloading (`pml reload form`)**:
  - Developers can reload and recompile an active form definition in-place without restarting the AVEVA session using:
    `pml reload form !!formname`

## Key Concepts
- **`setup form` / `exit`**: Syntactic block defining the form window and layout of contained gadgets.
- **`dialog` vs Standard Form**: The `dialog` keyword styles the window as a tool dialog (without minimize/maximize buttons, typically kept on top).
- **`resizable`**: Allows the user to freely resize the window borders.
- **`show !!formname`**: Displays the form on screen.
- **`hide !!formname`**: Hides the form from the screen while preserving its state in memory.
- **`!this` in Forms**: Within form methods, `!this` references the form object itself. Gadgets are accessed as member properties (e.g., `!this.nozzleList`).
- **`autoquit`**: Button attribute causing the form to automatically dismiss after the button callback completes.

## Mental Models
- **Think of a Form as a specialized UDO with a visual canvas**: Everything true about a User-Defined Object (members, methods, encapsulation) applies to a form, with gadgets acting as member UI controls.
- **Always separate UI layout from business logic**: Keep gadget declarations in the `setup form ... exit` block clean; implement all validation and database modifications in member methods.

## Anti-patterns
- **Using Global Variables for Form State**: Storing form values in session globals (`!!selectedItem`) leads to state conflicts when multiple forms or instances are used. Always store state in form members (`!this.selectedItem`).
- **Restarting AVEVA to Test Form Changes**: Restarting the entire application to test an edit is a waste of time. Always use `pml reload form !!formname`.
- **Modifying DABACON directly in `initcall`**: Heavy database writes during `initcall` slow down form rendering and freeze the GUI. Keep `initcall` lightweight.

## Code Examples
```pml
-- ================================================================
-- File: equipmentmanager.pmlfrm
-- Location: %PMLLIB%\equipmentmanager.pmlfrm
-- ================================================================

-- 1. Setup Form Canvas and Gadgets
setup form !!equipmentmanager dialog resizable
  title 'Equipment Manager'
  
  -- Form member variables
  member .currentEqui is DBREF
  member .nozzleNames is ARRAY

  -- Layout gadgets
  paragraph .info at x 1 y 1 text 'Select Equipment from active 3D view'
  button .pickBtn 'Pick Equipment' at xmin ymax+0.5 callback '!this.pickEquipment()'
  
  text .equiName 'Name:' at xmin ymax+0.5 is STRING width 25
  list .nozzList 'Associated Nozzles:' at xmin ymax+0.5 width 30 height 6
  
  button .apply 'Apply' at x 1 ymax+1 callback '!this.apply()'
  button .dismiss 'Dismiss' at xmax+1 ymin cancel autoquit
exit

-- 2. Constructor: Initialize form state
define method .equipmentmanager()
  !this.nozzleNames = ARRAY()
endmethod

-- 3. Event Handler: Pick Equipment
define method .pickEquipment()
  !this.currentEqui = !!CE
  if (!this.currentEqui.badRef()) then
    !!Alert.Warning('No valid element currently selected.')
    return
  endif

  !this.equiName.val = !this.currentEqui.name
  
  -- Populate nozzle list
  !this.nozzleNames.clear()
  -- Query nozzles under current equipment
  var !nozz coll all nozz for $!this.currentEqui.name
  do !n values !nozz
    !this.nozzleNames.append(!n)
  enddo
  
  !this.nozzList.dtext = !this.nozzleNames
endmethod

-- 4. Event Handler: Apply Action
define method .apply()
  if (!this.currentEqui.badRef()) then
    return
  endif
  $P Applying modifications to $!this.currentEqui.name
  !!Alert.Message('Modifications saved successfully.')
endmethod
```
- **What it demonstrates**: Full form definition, form member variables, gadget layout, constructor initialization, method-based event callbacks, gadget value manipulation (`.val`, `.dtext`), and defensive handling.

## Reference Tables
| Form Attribute / Event | Syntax | Purpose |
|---|---|---|
| Dialog Window Style | `setup form !!name dialog` | Modeless utility window |
| Resizable Window | `setup form !!name resizable` | Enables border resizing |
| Window Title | `title 'Window Name'` | Sets title bar caption |
| Constructor Method | `define method .name()` | Executed on form instantiation |
| Show Callback | `initcall '!this.onShow()'` | Executed each time form appears |
| Window Close Event | `quitcall '!this.onQuit()'` | Intercepts click on 'X' close box |
| Hot Reload | `pml reload form !!name` | Reloads modified definition from disk |

## Key Takeaways
1. Forms are defined in `<formname>.pmlfrm` files in lowercase inside `PMLLIB`.
2. Gadgets are declared inside `setup form ... exit`; methods are declared outside the block.
3. Access form state and gadgets inside methods using `!this.<member>`.
4. Use `pml reload form !!name` to reload UI changes instantly without restarting the application.

## Connects To
- **Ch 1**: PML Basics & Environment
- **Ch 6**: User-Defined Objects
- **Ch 9**: GUI Gadgets & Layout System
- **Ch 10**: Menus, Toolbars & Integration
