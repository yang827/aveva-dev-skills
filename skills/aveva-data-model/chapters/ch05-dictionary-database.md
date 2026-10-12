# Chapter 5: Dictionary Database

## Core Idea
The Dictionary Database (`DICT`) manages metadata schemas, User-Defined Attributes (UDAs), custom element classifications, and database view configurations, allowing organizations to extend native AVEVA element schemas with custom engineering data.

## Frameworks Introduced
- **User-Defined Attribute (UDA) Extension Framework**:
  - When to use: Storing company-specific, project-specific, or lifecycle data on native elements (e.g. stress status, purchase order numbers, vendor IDs, calculation codes).
  - How: UDAs are created in `DICT` under Lexicon definitions. Once declared, they are available on specified element types and are always referenced with a leading colon (`:UDA_NAME`).
- **Database View & Filter Architecture**:
  - When to use: Restricting, projecting, or transforming database queries for downstream reporting.
  - How: Definitions using `DBVW`, `ATTCOLUMN`, and `ATTFILTER` define structured projections of attributes across target element classes.

## Key Concepts
- **`UWLD` / `LEXICON`**: Administrative roots within the Dictionary database defining attribute scopes.
- **`UDA` (User Defined Attribute)**: Custom attribute definition record specifying data type, length, default value, and applicable element types.
- **Prefix Colon (`:`)**: Mandatory syntactic character distinguishing UDAs from standard native attributes (e.g., `:PO_NUMBER` vs `NAME`).
- **`ATTCOLUMN`**: Column projection element defining attribute representation in database views.
- **`ATTFILTER`**: Filter rule element restricting which elements match a view based on logical conditions.
- **`DBVW` (Database View)**: Virtual table definition compiling element attributes for reporting tools.

## Mental Models
- **Think of the Dictionary DB as the System Schema Catalog**: It does not store physical plant instances; it defines the metadata types and validation rules applied across other databases.

## Anti-patterns
- **Forgetting the Colon Prefix on UDAs**: Writing `Q PO_NUMBER` triggers an unknown attribute error; you must write `Q :PO_NUMBER`.
- **Applying UDAs Globally Without Element Scoping**: Defining a UDA without constraining element types wastes database index space and pollutes unrelated elements.

## Code Examples
```pml
-- Querying a UDA on the Current Element
Q :STRESS_STATUS
Q :CALCULATION_NOTE
Q :VENDOR_CODE

-- Setting a UDA value
:STRESS_STATUS 'APPROVED'
:CALCULATION_NOTE 'Calc-Rev-04 checked by stress engineer'

-- Querying UDA metadata in Lexicon/Dict
Q ATTR /:STRESS_STATUS TYPE ELEMTYPES DEFAULT
```
- **What it demonstrates**: Usage and querying of User-Defined Attributes on active design elements.

## Reference Tables
| UDA Data Type | Description | PML Example Format |
|:---|:---|:---|
| `STRING` / `TEXT` | Alphanumeric text string | `:VENDOR 'Sulzer Pumps Ltd'` |
| `REAL` | Floating point numerical value | `:DESIGN_TEMP 145.5` |
| `INTEGER` | Whole number | `:INSPECTION_CLASS 1` |
| `LOGICAL` | Boolean truth value | `:IS_CRITICAL TRUE` |
| `ELEMENT` / `REF` | Pointer reference to another database element | `:LINKED_DOC =124/512` |

## Worked Example
Deploying a piping stress analysis tracking attribute:
1. Dictionary administrator defines `:STRESS_STATUS` in `DICT`:
   - Type: `STRING`.
   - Element types allowed: `PIPE`, `BRAN`.
   - Valid values / default: `'UNCHECKED'`.
2. Designer in Design DB checks branch:
   - Navigates to `/100-P-1001-A1/B1`.
   - Queries initial value: `Q :STRESS_STATUS` -> `'UNCHECKED'`.
3. Stress engineer reviews calculation:
   - Sets approved state: `:STRESS_STATUS 'STRESS_PASSED'`.
   - Sets note: `:STRESS_NOTE 'Calcs complete in Caesar II Rev B'`.

## Key Takeaways
1. The Dictionary Database (`DICT`) extends standard schemas with custom User-Defined Attributes.
2. All UDAs are prefixed with a colon (`:`) in queries and assignments.
3. UDAs can store strings, numbers, booleans, and element references.
4. Database views (`DBVW`) leverage dictionary elements for structured engineering reporting.

## Connects To
- **Ch 4 (Design Database)**: Design elements host UDAs for project metadata.
- **Ch 16 (Introduction to Attributes)**: Places UDAs within the broader attribute typology.
