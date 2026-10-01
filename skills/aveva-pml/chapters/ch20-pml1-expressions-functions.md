# Chapter 20: SCRM Appendix A — PML 1 Expressions & Functions Reference

## Core Idea
The AVEVA Software Customisation Reference Manual (SCRM Appendix A, pp. 289–332) provides the definitive reference specification for **PML 1 expressions, operators, and built-in functions**. Although PML 2 introduced object-oriented dot-syntax methods, the PML 1 expression engine remains fully supported across all AVEVA products (Marine, Plant, Outfitting, PDMS, E3D). It is fundamental for database queries, report generators, collection filters, and attribute evaluation.

---

## Frameworks Introduced

### 1. Expression Syntax & Operator Precedence (SCRM A.1)
Expressions in PML evaluate with strict operator precedence (highest to lowest):
1. **Parentheses**: `( ... )`
2. **Unary operators**: `+`, `-`, `NOT`
3. **Multiplicative**: `*`, `/` (units consolidated across multiplication/division)
4. **Additive & Concatenation**: `+`, `-`, `&`, `&+` (no-space string concat)
5. **Relational / Comparison**: `EQ`, `NE`, `GT`, `LT`, `GE`, `LE`, `LIKE`
6. **Logical**: `AND`, `OR`

*Note on String Concatenation*:
* `text1 + text2` : Concatenates with standard spacing or type-dependent rule.
* `text1 & text2` : Standard string concatenation.
* `text1 &+ text2` : **PML 1 No-Space Concatenation Operator**, joins strings strictly without inserting any separator space.

---

### 2. Logical Expressions & Functions (SCRM A.2)
Used extensively in database filters (`COLLECTION.filter()`) and conditional statements.

| Function | Signature / Syntax | Description & Behavior |
|---|---|---|
| **`BADREF`** | `BADREF(id)` | Returns `TRUE` if `id` (or `DBREF`) is invalid, unset, or `NULREF`. |
| **`DEFINED`** | `DEFINED(!var)`<br>`DEFINED(!arr, idx)` | Returns `TRUE` if the variable, array, or specific array index exists. |
| **`UNDEFINED`** | `UNDEFINED(!var)` | Equivalent to `NOT DEFINED(!var)`. |
| **`CREATED`** | `CREATED` | Logical keyword: `TRUE` if current database element was created since the project benchmark date. |
| **`DELETED`** | `DELETED` | Logical keyword: `TRUE` if element has been deleted. |
| **`MODIFIED`** | `MODIFIED` | Logical keyword: `TRUE` if element was modified since the project benchmark date. |
| **`EMPTY`** | `EMPTY(val)` | Returns `TRUE` if collection, string, or array has zero elements/length. |
| **`MATCHWILD`** | `MATCHWILD(text, pattern)` | Wildcard pattern match (`*` matches any sequence, `?` matches single char). e.g. `MATCHWILD(ATTRIB NAMN, 'F206*')`. |
| **`UNSET`** | `UNSET(attr)` | Returns `TRUE` if the specified database attribute has an unset status. |
| **`VLOGICAL`** | `VLOGICAL(varname)` | Late evaluation: reads variable name and evaluates its content as `BOOLEAN`. |

---

### 3. Numeric (Real) Functions (SCRM A.3)
Engineering mathematical functions. Trigonometric functions operate in **degrees** (not radians).

| Function | Syntax | Returns | Description & Example |
|---|---|---|---|
| **`ABS`** | `ABS(n)` | `REAL` | Absolute value: `ABS(-5.2)` -> `5.2` |
| **`INT`** | `INT(n)` | `REAL` | Truncated integer (chops decimal): `INT(3.9)` -> `3.0` |
| **`NINT`** | `NINT(n)` | `REAL` | **Nearest integer (rounding)**: `NINT(3.5)` -> `4.0`, `NINT(-3.5)` -> `-4.0` |
| **`SQRT`** | `SQRT(n)` | `REAL` | Square root: `SQRT(16)` -> `4.0` |
| **`POWER`** | `POWER(base, exp)` | `REAL` | Exponentiation: `POWER(2, 3)` -> `8.0` |
| **`MOD`** | `MOD(n1, n2)` | `REAL` | Modulo remainder: `MOD(10, 3)` -> `1.0` |
| **`NEGATE`** | `NEGATE(n)` | `REAL` | Multiply by -1.0: `NEGATE(4)` -> `-4.0` |
| **`SIN`** | `SIN(deg)` | `REAL` | Sine of angle in degrees: `SIN(90)` -> `1.0` |
| **`COS`** | `COS(deg)` | `REAL` | Cosine of angle in degrees: `COS(0)` -> `1.0` |
| **`TAN`** | `TAN(deg)` | `REAL` | Tangent of angle in degrees: `TAN(45)` -> `1.0` |
| **`ASIN`** | `ASIN(n)` | `REAL` | Arc sine returning degrees. |
| **`ACOS`** | `ACOS(n)` | `REAL` | Arc cosine returning degrees. |
| **`ATAN`** | `ATAN(n)` | `REAL` | Arc tangent returning degrees. |
| **`ATANT`** | `ATANT(n1, n2)` | `REAL` | Four-quadrant arc tangent of `n1/n2` with appropriate sign. |
| **`LOG`** | `LOG(n)` | `REAL` | Natural logarithm (base $e$). |
| **`ALOG`** | `ALOG(n)` | `REAL` | Natural anti-log ($e^n$). |
| **`MAX`** | `MAX(n1, n2, ...)` | `REAL` | Maximum value among arguments. |
| **`MIN`** | `MIN(n1, n2, ...)` | `REAL` | Minimum value among arguments. |
| **`OCCUR`** | `OCCUR(str, sub)` | `REAL` | Count of times `sub` appears in `str`. |
| **`ARRAYSIZE`** | `ARRAYSIZE(arr)` | `REAL` | Number of elements in array variable. |
| **`ARRAYWIDTH`**| `ARRAYWIDTH(arr)` | `REAL` | Maximum string length among all items in array. |
| **`COMPONENT`** | `COMPONENT dir OF pos` | `REAL` | Magnitude of 3D point `pos` projected along direction vector `dir`. |
| **`REAL`** | `REAL(str)` | `REAL` | Parses number from start of string: `REAL('120.5mm')` -> `120.5` |
| **`VVALUE`** | `VVALUE(varname)` | `REAL` | Late evaluation: reads variable name and evaluates as `REAL`. |

---

### 4. Text & String Functions (SCRM A.6)
PML 1 string manipulation functions (compatible with PML 2 `STRING` objects).

| Function | Syntax | Description & Example |
|---|---|---|
| **`AFTER`** | `AFTER(str, token)` | Substring after leftmost occurrence of `token`. If not found, returns `''`.<br>`AFTER('ABC-DEF-GHI', '-')` -> `'DEF-GHI'` |
| **`BEFORE`** | `BEFORE(str, token)` | Substring before leftmost occurrence of `token`. If not found, returns `str`.<br>`BEFORE('ABC-DEF-GHI', '-')` -> `'ABC'` |
| **`PART`** | `PART(str, idx, sep)` | Splits `str` by `sep` and returns the `idx`-th item (1-indexed).<br>`PART('PUMP-101-A', 2, '-')` -> `'101'` |
| **`SUBS` / `DSUBS`** | `SUBS(str, start, len)`<br>`DSUBS(str, start, len)` | Extracts `len` characters starting from index `start` (1-indexed). |
| **`LENGTH`** | `LENGTH(str)` | Returns string character count. |
| **`LOWCASE`** | `LOWCASE(str)` | Converts to lowercase. |
| **`UPCASE`** | `UPCASE(str)` | Converts to uppercase. |
| **`TRIM`** | `TRIM(str)` | Strips leading and trailing whitespace. |
| **`REPLACE`** | `REPLACE(str, old, new)` | Replaces occurrences of `old` with `new`. |
| **`MATCH`** | `MATCH(str, sub)` | Returns 1-based character position of `sub` in `str`; returns `0` if not found. |
| **`DISTANCE`** | `DISTANCE(num)`<br>`DISTANCE(d, f, u, fr, dp, z)` | Formats numeric distance into current distance units (metric or feet-and-inches, e.g. `12' 4.1/2"`). |
| **`VTEXT`** | `VTEXT(varname)` | Late evaluation: reads variable name and evaluates its content as `STRING`. |

---

### 5. Spatial & Positional Expressions (SCRM A.5)
AVEVA expressions support geometric calculation keywords directly within query expressions:
* **`WRT` (With Respect To)**:
  Transforms coordinates relative to a reference database element:
  ```pml
  !posWorld = POS OF /PUMP101 WRT /*
  !posLocal = POS OF /NOZZ1 WRT /PUMP101
  ```
* **`FROM`**:
  Calculates vector offset between two positions:
  ```pml
  !dist = DISTANCE FROM (POS OF /NOZZ1) TO (POS OF /NOZZ2)
  ```
* **`POLAR`**:
  Calculates position by distance and bearing:
  ```pml
  !newPos = POLAR(!basePos, 1500, !dir)
  ```
* **`ARRAY(pos/dir/ori)`**:
  Converts 3D position or orientation into an array of 3 real numbers `[East, North, Up]`.

---

### 6. Late Evaluation Framework (SCRM A.7)
Late evaluation defers expression substitution until runtime resolution, avoiding premature macro expansion errors.
* **`$!var` Syntax**: Evaluates variable contents at execution time:
  ```pml
  !attr = 'DESP'
  !val = $!attr OF /PIPE-100
  ```
* **Dynamic Resolution Trio**:
  * `VVALUE(!realName)` -> Real
  * `VTEXT(!strName)` -> Text
  * `VLOGICAL(!boolName)` -> Boolean

---

## Code Examples

### Advanced Collection Query Using Appendix A Expressions
```pml
-- ================================================================
-- Example: Querying Equipment Using Appendix A Mathematical & Logical Functions
-- Source: SCRM Appendix A.2, A.3, A.6
-- ================================================================
!coll = object COLLECTION()
!coll.type('EQUIP')

-- Appendix A compound filter:
-- Name starts with 'P', height > 1500mm, and not bad reference
!filterExpr = object EXPRESSION(|MATCHWILD(NAME, '*P*') AND (HEIG GT 1500mm) AND NOT BADREF(OWNER)|)
!coll.filter(!filterExpr)

!results = !coll.results()
do !item values !results
  !name = !item.name
  -- Extract prefix before hyphen using BEFORE()
  !prefix = BEFORE(!name, '-')
  -- Extract tag after hyphen using AFTER()
  !tag    = AFTER(!name, '-')
  
  -- Round position Z to nearest integer millimeter using NINT()
  !zPos = !item.pposition(1).up
  !zRounded = NINT(!zPos)
  
  $P Equipment $!name: Prefix=$!prefix, Tag=$!tag, Z(Rounded)=$!zRounded
enddo
```

---

## Anti-patterns
* **Using `INT()` for Rounding**: `INT(3.9)` truncates to `3.0`. For mathematical rounding, always use `NINT(3.9)` which yields `4.0`.
* **String Subtraction (`-`)**: In PML expressions, `-` on strings causes a type error. Always use `BEFORE()` or `AFTER()` or `PART()` for string parsing.
* **Assuming Radian Trigonometry**: PML trigonometric functions (`SIN`, `COS`, `TAN`, `ASIN`, `ACOS`, `ATAN`) operate in **degrees**. Passing radians produces invalid geometry.

## Key Takeaways
1. Appendix A defines the foundation of AVEVA expressions across PML 1, reports, and PML 2 query filters.
2. `&+` is the PML 1 no-space string concatenation operator.
3. String parsing is cleanest with `BEFORE()`, `AFTER()`, and `PART()`.
4. Mathematical rounding uses `NINT()`, not `INT()`.
5. Database validation uses `BADREF()`, `UNSET()`, `DEFINED()`, and `MATCHWILD()`.

## Connects To
* **Ch 2**: Variables, Data Types & Scope
* **Ch 3**: Control Flow & Logic
* **Ch 13**: Collections & DABACON Database Queries
* **Ch 17**: SCRM System Objects Catalog
