# Chapter 6: User-Defined Objects (UDOs)

## Core Idea
User-Defined Objects (UDOs) in PML 2 provide true object-oriented encapsulation. A UDO combines state (typed member variables) and behavior (methods) into an instantiable type stored in a `<typename>.pmlobj` definition file.

## Frameworks Introduced
- **Object Definition Contract (`.pmlobj`)**:
  - The object blueprint is declared via `define object <name> ... endobject`.
  - Member variables are declared using `member .<varname> is <TYPE>`.
  - Stored in a file named strictly `<typename_lowercase>.pmlobj` located in `PMLLIB`.
- **Constructor Method Pattern**:
  - A constructor method shares the name of the object type: `define method .<typename>(!<arg1> is <TYPE>, ...)`.
  - Executed automatically when the object is instantiated via `!instance = object <typename>(<args>)`.
- **Instance Encapsulation & Self-Reference (`!this`)**:
  - Inside any object method, the active instance is referenced using `!this`.
  - Member variables are accessed via `!this.<membername>`.
  - Methods within the object are called via `!this.<methodname>()`.

## Key Concepts
- **`define object` / `endobject`**: Defines the type name and lists all member attributes.
- **`define method` / `endmethod`**: Implements a method on the object.
- **Constructor**: Method `.name()` matching the object name, used to initialize members, allocate arrays, and set defaults.
- **`!this`**: Reserved PML keyword pointing to the current instance context.
- **`object <typename>(...)`**: Constructor invocation expression creating a new instance.
- **Destructor (`.delete()` method)**: Special method executed when the object is explicitly deleted via `delete var !myObj`.

## Mental Models
- **Think of `.pmlobj` as a C++ or Java Class**: It bundles data fields and algorithms together, preventing global variable pollution and ensuring modular architecture.
- **Always initialize arrays in the constructor**: An uninitialized `ARRAY` member will be unset, causing runtime errors if accessed before assignment.

## Anti-patterns
- **Directly Mutating Internal Members Without Validation**: Exposing member variables directly without setter methods risks corrupting the object's invariant state.
- **Writing Multiple Object Types in One File**: AVEVA PML loader requires that each `.pmlobj` file defines exactly one object type matching its filename.
- **Forgetting `!this.` Prefix**: Referencing `.diameter` instead of `!this.diameter` inside a method will result in undefined variable errors.

## Code Examples
```pml
-- ================================================================
-- File: vesseldata.pmlobj
-- Location: %PMLLIB%\vesseldata.pmlobj
-- ================================================================

-- 1. Declare Object and its Members
define object vesseldata
  member .name is STRING
  member .height is REAL
  member .diameter is REAL
  member .nozzleRefs is ARRAY
endobject

-- 2. Constructor Method
define method .vesseldata(!name is STRING, !h is REAL, !d is REAL)
  !this.name = !name
  !this.height = !h
  !this.diameter = !d
  !this.nozzleRefs = ARRAY()
endmethod

-- 3. Business Logic Method
define method .calculateCylinderVolume() is REAL
  !pi = 3.14159265
  !radius = !this.diameter / 2.0
  !vol = !pi * POW(!radius, 2) * !this.height
  return !vol
endmethod

-- 4. Mutator Method with Defensive Check
define method .addNozzle(!nozzRef is DBREF)
  if (!nozzRef.badRef()) then
    $P Warning: Attempted to add invalid DBREF to vessel $!this.name
    return
  endif
  !this.nozzleRefs.append(!nozzRef)
  $P Nozzle $!nozzRef.name added to $!this.name
endmethod

-- ================================================================
-- Usage Script:
-- ================================================================
!vessel = object vesseldata('V-201', 5000.0, 1800.0)
!vol = !vessel.calculateCylinderVolume()
$P Calculated volume for $!vessel.name: $!vol mm3
```
- **What it demonstrates**: Full UDO definition, member declarations, constructor with parameter binding and array initialization, getter/calculation method, setter with validation, and external instantiation.

## Reference Tables
| Definition Element | Syntax | Purpose |
|---|---|---|
| Type Declaration | `define object <name>` | Initiates object definition block |
| Member Declaration | `member .<varname> is <TYPE>` | Declares typed property |
| Block Closer | `endobject` | Terminates member declarations |
| Constructor Method | `define method .<name>(...)` | Initializes new instances |
| Instance Method | `define method .<methodName>(...) [is TYPE]` | Defines object behavior |
| Instantiation | `!var = object <name>(...)` | Creates object in memory |

## Key Takeaways
1. UDOs are saved in `<typename>.pmlobj` files in lowercase inside `PMLLIB`.
2. Always define a constructor method matching the type name to initialize member variables.
3. Access member state within methods using `!this.<membername>`.
4. Run `pml rehash all` whenever you create or edit a `.pmlobj` file.

## Connects To
- **Ch 2**: Variables, Data Types & Scope
- **Ch 5**: PML 2 Functions & Methods
- **Ch 7**: Core System Objects
- **Ch 8**: Forms & GUI Customisation (Forms are specialized global objects)
