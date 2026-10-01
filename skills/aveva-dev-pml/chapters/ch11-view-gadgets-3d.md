# Chapter 11: 3D View Gadgets & Graphical Display

## Core Idea
AVEVA PML allows embedding live graphical viewports directly inside forms using the `VIEW` gadget. Embedded views support full 3D interactive manipulation (rotate, pan, zoom), clipping boxes (`CLIPBOX`), 3D nozzle tagging, drawlist control, and element highlighting.

## Frameworks Introduced
- **`VIEW` Gadget Architecture**:
  - Declared via `view .<name> '<title>' at x y width <w> height <h> [volume] [plot] [alpha]`.
  - **Volume View (`volume`)**: Interactive 3D shaded model view connected to the active graphical pipeline.
  - **Plot View (`plot`)**: 2D vector preview viewport for drafts and drawing plots.
  - **Alpha View (`alpha`)**: Text terminal output display embedded within a form.
- **Drawlist & Visibility Management**:
  - Commands affecting the view drawlist:
    - `ADD <element>`: Inserts element into the view display list.
    - `REMOVE <element>`: Clears element from the view.
    - `AUTOCOLOUR`: Applies rule-based color coding to 3D elements.
- **Spatial Isolation & Tagging Framework**:
  - **Clipbox**: Restricts 3D rendering to a bounded spatial bounding box around an element.
  - **Tagging**: Dynamically annotates 3D components (e.g., displaying nozzle names in 3D space).
  - **Highlighting**: Enhances visual prominence via `ENHANCE <element> COLOUR <color>`.

## Key Concepts
- **`VIEW` Gadget**: Native viewport control embedded directly into a `.pmlfrm`.
- **`CLIPBOX`**: Bounding box isolating a volume of interest in 3D space.
- **`ENHANCE` / `UNENHANCE`**: Graphical enhancement commands highlighting specific database elements in contrasting colors without modifying their model attributes.
- **Camera Views**: Standard viewpoint orientations: `LOOK NORTH`, `LOOK SOUTH`, `LOOK EAST`, `LOOK WEST`, `LOOK PLAN`, `ISO 1`, `ISO 2`, `ISO 3`.
- **View Refresh**: Forcing redraw via `!this.viewGadget.refresh()`.

## Mental Models
- **Think of the VIEW gadget as an embedded 3D camera**: It shares the active design graphics pipeline, allowing custom dialogs to present a dedicated, isolated angle or component to the user.
- **Use Clipbox for performance on large models**: Loading entire plant or ship hulls into a subview slows rendering; a clipbox limits graphical computation to the immediate work zone.

## Anti-patterns
- **Forgetting to Clean Up Highlighting**: Failing to execute `UNENHANCE ALL` leaves permanent false highlights on elements across the session.
- **Hardcoding View Sizes Without Anchoring**: If a form is resizable, un-anchored view gadgets remain tiny while the window expands; always add `<fganch>` anchoring to the view gadget.
- **Issuing Global Navigation from Subviews**: Confusing the active view context; ensure commands target the intended viewport.

## Code Examples
```pml
-- ================================================================
-- Example: Form with Embedded 3D Volume View, Clipbox, and Tagging
-- ================================================================
setup form !!vessel3DViewer dialog resizable
  title '3D Vessel Inspector'

  -- Left: Controls
  list .lstVessels 'Available Vessels:' at x 1 y 1 width 20 height 10 callback '!this.onSelectVessel()'
  toggle .chkClipbox 'Enable Clipbox' at xmin ymax+0.5 val TRUE callback '!this.toggleClipbox()'
  toggle .chkTags 'Tag Nozzles' at xmin ymax+0.5 val TRUE callback '!this.toggleTags()'

  -- Right: Embedded 3D Viewport
  view .modelView '3D Model' at xmax+2 y 1 width 60 height 20 volume
  
  -- Bottom: Action bar
  button .btnIso 'Isometric View' at xmin ymax+0.5 callback '!this.setIso()'
  button .btnClose 'Close' at xmax+1 ymin cancel autoquit
exit

define method .vessel3DViewer()
  !vessels = ARRAY()
  !vessels.append('/V-101')
  !vessels.append('/V-102')
  !vessels.append('/V-103')
  !this.lstVessels.dtext = !vessels
endmethod

define method .onSelectVessel()
  !sel = !this.lstVessels.selection
  if (!sel.unset()) then
    return
  endif

  !vesselName = !this.lstVessels.dtext[!sel]
  !vesselRef = !vesselName.dbref()
  if (!vesselRef.badRef()) then
    return
  endif

  -- Clear view and add selected vessel
  var !currDrawlist coll all for ce
  -- Direct commands to active view
  ADD $!vesselName
  LOOK PLAN
  
  if (!this.chkClipbox.val) then
    !this.applyClipbox(!vesselName)
  endif
endmethod

define method .applyClipbox(!elemName is STRING)
  -- Create clipbox around target element
  ADD CLIPBOX $!elemName
endmethod

define method .setIso()
  ISO 3
endmethod
```
- **What it demonstrates**: Declaring an embedded 3D volume view (`view ... volume`), coordinating selection from a list with view contents (`ADD <element>`), camera control (`ISO 3`, `LOOK PLAN`), and clipbox integration.

## Reference Tables
| View Type | Declaration Syntax | Purpose |
|---|---|---|
| 3D Volume View | `view .v 'Title' width W height H volume` | Interactive 3D shaded model rendering |
| 2D Plot View | `view .v 'Title' width W height H plot` | 2D vector preview for drawings |
| Alpha View | `view .v 'Title' width W height H alpha` | Text console embedded in form |
| Clipbox Toggle | `ADD CLIPBOX <elem>` / `REMOVE CLIPBOX` | Spatial bounding box filter |
| Highlighting | `ENHANCE <elem> COLOUR RED` | Temporary visual emphasis |
| Clear Highlights | `UNENHANCE ALL` | Reverts all element colors |

## Key Takeaways
1. Embedded `VIEW` gadgets provide live 3D interaction inside PML forms.
2. Volume views support native AVEVA view commands (`ADD`, `REMOVE`, `LOOK`, `ISO`).
3. Use `CLIPBOX` to focus the user's attention and dramatically boost rendering speeds.
4. Always clear temporary graphical enhancements (`UNENHANCE ALL`) on form close.

## Connects To
- **Ch 8**: Forms Architecture & Lifecycle
- **Ch 9**: GUI Gadgets & Layout System
- **Ch 12**: Event Driven Graphics (Interactive picking in 3D views)
- **Ch 18**: PDMS 3D Modeling Primitives
