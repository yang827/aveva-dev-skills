# Chapter 15: MarAPI & .NET Interoperability

## Core Idea
PML 2 provides a native bridge to Microsoft .NET assemblies. Developers can import compiled C#/.NET libraries directly into PML using the `import` statement, instantiate .NET classes, invoke methods, and embed .NET Windows Forms / WPF controls inside PML forms.

## Frameworks Introduced
- **Assembly Import & Namespace Binding Pipeline**:
  - Load assembly: `import '<assembly_name>'`
  - Guard against re-import: `handle (1000, 0) ... endhandle`
  - Bind namespace: `using namespace '<Company.Namespace>'`
- **Type Marshaling & Object Instantiation**:
  - Once imported, .NET classes are instantiated in PML using standard object syntax:
    `!myObj = object ClassName(args)`
  - Automatic type marshaling:
    - PML `REAL` <-> C# `System.Double` / `float`
    - PML `STRING` <-> C# `System.String`
    - PML `BOOLEAN` <-> C# `System.Boolean`
    - PML `ARRAY` <-> C# `System.Array` / `ArrayList`
- **Embedding .NET Controls in PML Forms**:
  - Forms can integrate native .NET Windows Forms or WPF components via the `.net` setup modifier:
    `setup form !!myDotNetForm dialog .net`

## Key Concepts
- **`import` Directive**: PML 2 statement that loads a .NET DLL into the AVEVA process address space.
- **`using namespace`**: Directs PML method resolution to look within the specified .NET namespace.
- **`NETmarAPI.chm`**: Compiled HTML help documentation in the AVEVA Marine distribution detailing all exported classes, namespaces, and parameter signatures.
- **Event Callbacks between .NET and PML**: .NET components can fire events that trigger PML method callbacks.

## Mental Models
- **Think of PML 2 as a managed .NET scripting host**: Any public class in an imported .NET assembly becomes a first-class citizen inside PML 2, accessible with the same syntax as native PML objects.
- **Always catch error `(1000, 0)` on `import`**: If an assembly was already loaded by another macro or during startup, re-executing `import` raises error `(1000, 0)`. Always place `handle (1000, 0) endhandle` immediately **after** the `import` statement — the import itself stays outside the trap, and the block between `handle` and `endhandle` contains only the recovery for the "already loaded" error.

## Anti-patterns
- **Placing DLLs Outside AVEVA Search Path**: Placing custom .NET assemblies in arbitrary directories without configuring the application manifest or PATH causes assembly loader exceptions. Place assemblies in `%AVEVA_DESIGN_EXE%` or `%PDMSUI%`.
- **Passing Unsupported Complex Generics**: Complex generic collections (e.g. `Dictionary<TKey, TValue>`) cannot always be marshaled automatically into PML; expose helper wrapper methods accepting arrays and strings.
- **Uncaught Exceptions across Boundary**: An unhandled exception thrown in C# will bubble up into PML as a generic system error; always catch and wrap exceptions inside C# before returning to PML.

## Code Examples
```pml
-- ================================================================
-- Example: Importing and Invoking .NET Assemblies in PML 2
-- ================================================================

-- 1. Import Assemblies with Defensive Handlers
import 'marapi'
handle (1000, 0)
  -- marapi already loaded
endhandle

import 'Aveva.Core.Presentation'
handle (1000, 0)
  -- presentation layer already loaded
endhandle

using namespace 'Aveva.Marine.Ui'
using namespace 'Aveva.Marine.Utility'

-- 2. Instantiate .NET Classes from Assembly
!marUi   = object MarUi()
!marUtil = object MarUtil()

-- 3. Invoke .NET Methods with Marshaled Arguments
!projectName = !marUtil.TBEnvironmentGet('SB_PROJECT')
!userMessage = 'Connected to Marine Project: ' & !projectName

-- Call .NET Dialog Window
!marUi.MessageConfirm(!userMessage)

-- 4. Interactive Question via MarAPI Interface (TM-2401)
!res = !marUi.AnswerReqPML('Database Sync', 'Do you want to run database synchronization?')
if (!res eq !marUtil.YesPML()) then
  $P User clicked Yes. Executing synchronization...
else
  $P User cancelled or clicked No. Aborting.
endif
```
- **What it demonstrates**: Importing assemblies (`import`), trapping duplicate load errors `(1000, 0)`, namespace declaration, instantiating .NET objects (`MarUi`, `MarUtil`), parameter marshaling, and evaluating return codes.

## Reference Tables
| PML Type | .NET Equivalent | Marshaling Notes |
|---|---|---|
| `REAL` | `System.Double` | IEEE 64-bit floating point |
| `STRING` | `System.String` | UTF-16 Unicode string |
| `BOOLEAN` | `System.Boolean` | `true` or `false` |
| `ARRAY` | `System.Collections.ArrayList` | Heterogeneous indexed collection |
| `DBREF` | `Aveva.Core.Database.DbRef` | Direct reference to database record |

## Key Takeaways
1. Use `import '<dll>'` to bring .NET assemblies into PML 2.
2. Always catch error `(1000, 0)` after every `import` statement.
3. Bring namespaces into scope using `using namespace '<Namespace>'`.
4. Primitive types (`REAL`, `STRING`, `BOOLEAN`, `ARRAY`) marshal automatically across the PML-.NET boundary.

## Connects To
- **Ch 4**: Error Handling & Debugging
- **Ch 6**: User-Defined Objects (UDOs)
- **Ch 8**: Forms Architecture & Lifecycle
- **Ch 14**: Marine Drafting PML Automation
