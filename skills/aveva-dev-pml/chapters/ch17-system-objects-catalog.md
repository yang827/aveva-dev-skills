# Chapter 17: SCRM System Objects Reference Catalog

## Core Idea
The AVEVA Software Customisation Reference Manual (SCRM Chapter 2, Section 2.5) provides the definitive reference specification for **80 native system object and gadget types** built into the PML runtime. This catalog groups all 80 types into 7 operational domains, detailing their primary roles, key members, and method signatures.

## Universal Object Methods (SCRM Section 2.2)
Every PML 2 object inherits a set of universal built-in methods:
* `.eq(!other)`: `BOOLEAN` — Equality comparison.
* `.neq(!other)`: `BOOLEAN` — Inequality comparison.
* `.set(!other)`: Copies state from another instance.
* `.unset()`: Unsets/clears instance state.
* `.type()`: `STRING` — Returns type name keyword (e.g., `'DBREF'`, `'POSITION'`).
* `.string()`: `STRING` — Returns canonical string representation.
* `.copy()`: `OBJECT` — Creates a shallow copy.
* `.clone()`: `OBJECT` — Creates a deep clone of the object and child references.
* `.methods()`: `ARRAY of STRING` — Dynamic reflection listing all callable methods.
* `.members()`: `ARRAY of STRING` — Dynamic reflection listing all public members.

---

## The 80 SCRM System Objects Reference Catalog

### 1. Core Primitives & Scalar Data (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`REAL`** | 2.5.56 | IEEE 64-bit float | `.string()`, `.int()`, `.round()`, `.abs()`, `.sqrt()`, `.sin()`, `.cos()` |
| **`STRING`** | 2.5.64 | Unicode character text | `.length()`, `.upCase()`, `.lowCase()`, `.trim()`, `.split(delim)`, `.replace()`, `.match()` |
| **`BOOLEAN`** | 2.5.7 | Logical truth value | `.string()`, evaluated in logical `AND`/`OR`/`NOT` |
| **`ARRAY`** | 2.5.3 | Heterogeneous indexed array | `.append(!val)`, `.insert(idx, val)`, `.delete(idx)`, `.size()`, `.clear()`, `.sort()`, `.sortUnique()` |
| **`DATETIME`** | 2.5.16 | System timestamp & calendar | `.date()`, `.time()`, `.now()`, `.addDays(n)`, `.addHours(n)`, `.diff(!other)` |
| **`DATEFORMAT`**| 2.5.15 | Date parsing and display | `.format(dt)`, `.setFormat(str)` (e.g. `'DD-MMM-YYYY'`) |
| **`UNIT`** | 2.5.72 | Engineering units conversion | `.type()`, `.current()`, `.convert(val, fromUnit, toUnit)` |
| **`OBJECT`** | 2.5.40 | Base object prototype | Root ancestor providing universal methods |
| **`TABLE`** | 2.5.66 | 2D tabular data matrix | `.rows()`, `.columns()`, `.cell(r, c)`, `.addRow()`, `.addColumn()` |

### 2. DABACON Database & Project Administration (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`DBREF`** | 2.5.18 | DABACON element pointer | `.name`, `.type`, `.owner`, `.badRef()`, `.unset()`, `.mcount()`, `.attribute(name)`, `.attributes()`, `.pposition(i)`, `.pdirection(i)` |
| **`COLLECTION`**| 2.5.10 | High-performance search | `.type(str)`, `.scope(dbref)`, `.filter(expr)`, `.results()` -> `ARRAY of DBREF` |
| **`EXPRESSION`**| 2.5.21 | Attribute filter evaluator | `.evaluate(!dbref)`, `.string()`, `.isValid()` |
| **`DB`** | 2.5.17 | Database file handle | `.name()`, `.description()`, `.type()`, `.writable()`, `.claimMode()` |
| **`DBSESS`** | 2.5.19 | Database session control | `.saveWork()`, `.getWork()`, `.changes()`, `.undo()`, `.redo()` |
| **`MDB`** | 2.5.35 | Multiple Database container | `.name()`, `.current()`, `.databases()`, `.setCurrent(!name)` |
| **`PROJECT`** | 2.5.53 | Active project metadata | `.name()`, `.code()`, `.number()`, `.description()`, `.message()` |
| **`TEAM`** | 2.5.67 | User security team handle | `.name()`, `.users()`, `.databases()` |
| **`USER`** | 2.5.73 | Authenticated user profile | `.name()`, `.security()`, `.team()`, `.current()` |
| **`IDList`** | 2.5.28 | List of database references | `.add(!ref)`, `.remove(!ref)`, `.count()`, `.contains(!ref)` |
| **`SESSION`** | 2.5.62 | Current login session | `.user()`, `.project()`, `.mdb()`, `.module()`, `.startTime()` |
| **`STATE`** | 2.5.65 | Transactional state monitor | `.modified()`, `.locked()`, `.isClaimed()` |
| **`UNDOABLE`** | 2.5.71 | Database transaction tracker | `.mark(str)`, `.undo()`, `.redo()`, `.canUndo()` |
| **`VERIFY`** | 2.5.74 | Data consistency validation | `.check(!dbref)`, `.errors()`, `.warnings()` |

### 3. 3D Spatial Geometry & Mathematics (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`POSITION`** | 2.5.51 | 3D coordinate `(E, N, U)` | `.east`, `.north`, `.up`, `.distance(!pos)`, `.wrt(!ref)`, `.string()`, `.vector()` |
| **`DIRECTION`**| 2.5.20 | 3D unit direction vector | `.angle(!dir)`, `.string()`, `.vector()`, `.isParallel(!dir)`, `.isPerpendicular(!dir)` |
| **`ORIENTATION`**| 2.5.42 | 3D rotation matrix | `.matrix()`, `.wrt(!ref)`, `.isStandard()`, `.string()` |
| **`LINE`** | 2.5.30 | 3D line segment | `.start`, `.end`, `.length()`, `.midPoint()`, `.intersect(!line)` |
| **`PLANE`** | 2.5.44 | 3D mathematical plane | `.point`, `.normal`, `.distance(!pos)`, `.intersect(!line)` |
| **`POINTVECTOR`**| 2.5.50 | Point and vector composite | `.point`, `.direction`, `.translate(dist)`, `.evaluate()` |
| **`ARC`** | 2.5.2 | 3D circular arc entity | `.center`, `.radius`, `.startAngle`, `.endAngle`, `.normal` |
| **`BORE`** | 2.5.8 | Nominal piping bore | `.value`, `.units`, `.string()`, `.isEqual(!bore)` |
| **`LOCATION`** | 2.5.33 | Hierarchical spatial position | `.position`, `.orientation`, `.owner`, `.global()` |
| **`MEASURE`** | 2.5.36 | Interactive measurement tool | `.distance(!p1, !p2)`, `.angle(!d1, !d2)`, `.minimumDistance(!e1, !e2)` |
| **`XYPosition`**| 2.5.80 | 2D planar position `(X, Y)` | `.x`, `.y`, `.distance(!other)`, `.string()` |

### 4. Structural Grid Systems (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`PLANTGRID`** | 2.5.45 | Plant structural grid | `.name`, `.datum()`, `.lines()`, `.intersections()`, `.findLevel(u)` |
| **`LINEARGRID`**| 2.5.31 | Linear grid line array | `.startPos`, `.direction`, `.spacing()`, `.labels()`, `.count()` |
| **`RADIALGRID`**| 2.5.55 | Radial/cylindrical grid | `.origin`, `.innerRadius`, `.outerRadius`, `.radialAngles()`, `.rings()` |
| **`PLATFORMGRID`**| 2.5.46| Marine/offshore platform grid | `.deckElevation()`, `.frameLines()`, `.longitudinals()` |

### 5. Application Runtime, Printing & Security (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`ALERT`** | 2.5.1 | Modal GUI alerts | `.Message(str)`, `.Warning(str)`, `.Error(str)`, `.Confirm(str)`, `.Question(str)`, `.Input(p, def)` |
| **`FILE`** | 2.5.22 | Text file stream I/O | `.openFile(m)`, `.readFile()`, `.writeFile(s)`, `.readRecord()`, `.writeRecord(s)`, `.closeFile()`, `.exists()` |
| **`FMSYS`** | 2.5.23 | Application Forms Manager | `.screensize()`, `.clipboard()`, `.loadForm()`, `.currentDocument()`, `.cursor()`, `.refresh()` |
| **`FORM`** | 2.5.24 | Form object representation | `.show()`, `.hide()`, `.shown()`, `.title`, `.members()`, `.keyboardFocus()` |
| **`FORMAT`** | 2.5.25 | Numeric precision & units | `.precision(int)`, `.units(str)`, `.format(real)` |
| **`MENU`** | 2.5.37 | Context and bar menus | `.add(type, label, cb)`, `.show(!xypot)`, `.clear()`, `.remove(idx)` |
| **`MACRO`** | 2.5.34 | Macro execution container | `.run(path)`, `.arguments()`, `.status()` |
| **`BANNER`** | 2.5.4 | Header/banner message display | `.text(str)`, `.colour(c)`, `.clear()` |
| **`REPORT`** | 2.5.57 | Tabular reporting generator | `.generate()`, `.template(t)`, `.output(file)` |
| **`PMLReport`**| 2.5.47 | Diagnostic reporting tool | `.dumpObject(!obj)`, `.log(str)` |
| **`PMLSECURELOGIN`**| 2.5.48| Encrypted credential login | `.authenticate(user, token)`, `.isValid()` |
| **`PMLUSERLOGIN`**| 2.5.49 | Standard interactive login | `.prompt()`, `.user()`, `.status()` |
| **`POSTEVENTS`**| 2.5.52 | Event dispatching queue | `.post(event, payload)`, `.flush()` |
| **`ViewFinder`**| 2.5.75 | Graphical viewpoint finder | `.centerOn(!dbref)`, `.fitAll()`, `.zoom(factor)` |

### 6. GUI Gadgets & Visual Controls (SCRM 2.3 - 2.5 & SOFTCG Chapter 20)
| Gadget Type | SCRM Sec | Primary Role | Key Members & Methods |
|---|---|---|---|
| **`BUTTON`** | 2.5.9 | Clickable push button | `.callback`, `.background`, `.tooltip`, `.active`, `.visible` |
| **`TOGGLE`** | 2.5.70 | Two-state checkbox | `.val` (BOOLEAN), `.callback`, `.tag` |
| **`RTOGGLE`** | 2.5.58 | Radio toggle in radio group | `.val`, `.group`, `.callback` |
| **`OPTION`** | 2.5.41 | Dropdown selection list | `.val` (selected string), `.dtext` (ARRAY), `.rtext` (ARRAY) |
| **`COMBOBOX`** | 2.5.13 | Editable dropdown combo | `.val` (STRING), `.dtext` (ARRAY), `.callback` |
| **`LIST`** | 2.5.32 | Multi-row list box | `.dtext` (ARRAY), `.val` (ARRAY of selected indices), `.setRows(n)` |
| **`TEXT`** | 2.5.68 | Single-line text input | `.val` (STRING/REAL), `.format`, `.callback`, `.clear()` |
| **`TEXTPANE`** | 2.5.69 | Multi-line rich text area | `.val` (ARRAY of STRING), `.append(str)`, `.clear()`, `.scrollBottom()` |
| **`SLIDER`** | 2.5.63 | Numeric range slider | `.val` (REAL), `.min`, `.max`, `.step`, `.callback` |
| **`CONTAINER`**| 2.5.14 | Scrollable panel container | `.addGadget()`, `.scrollPos`, `.border` |
| **`FRAME`** | 2.5.26 | Grouping frame box | `.title`, `.val`, `.panel` |
| **`LINE`** | 2.5.29 | Decorative separator line | `.orientation` (`HORIZONTAL`/`VERTICAL`), `.width` |
| **`NUMERICINPUT`**| 2.5.39| Validated numeric field | `.val` (REAL), `.units`, `.precision`, `.validate()` |
| **`SELECTOR`** | 2.5.61 | DABACON tree navigator | `.root(!dbref)`, `.selected()`, `.callback`, `.multiSelect` |
| **`BAR`** | 2.5.5 | Form top menubar gadget | `.addMenu(!menu)`, `.clear()` |
| **`COLUMN`** | 2.5.11 | Table/list column header | `.title`, `.width`, `.alignment` |
| **`COLUMNFORMAT`**| 2.5.12| Column formatting rules | `.format`, `.sortable` |
| **`PARAGRAPH`**| 2.5.43 | Static text label or icon | `.text(str)`, `.val` |
| **`VIEW: ALPHA`**| 2.5.76| Command/text terminal view | `.write(str)`, `.clear()`, `.logFile(f)` |
| **`VIEW: AREA`** | 2.5.77| 2D schematic drawing view | `.draw()`, `.scale`, `.pan(dx, dy)` |
| **`VIEW: PLOT`** | 2.5.78| Plot preview window | `.plot(!sheet)`, `.zoom()`, `.print()` |
| **`VIEW: VOLUME`**| 2.5.79| Interactive 3D design view | `.volume(!limits)`, `.clipBox`, `.camera`, `.enhance(!dbref)` |

### 7. Routing, Profiles & Section Planes (SCRM 2.5)
| Object Type | SCRM Sec | Primary Role | Key Methods & Members |
|---|---|---|---|
| **`Multi Discipline Route Manager`** | 2.5.38 | Multi-discipline pipe/cable routing | `.route(!from, !to)`, `.checkClashes()`, `.spec(name)` |
| **`PROFILE`** | 2.5.54 | Structural section profile catalog | `.catalogueRef`, `.height`, `.width`, `.webThickness`, `.flangeThickness` |
| **`Section Plane`** | 2.5.59 | 3D model cutting plane | `.plane`, `.active`, `.cutModel()`, `.invert()` |
| **`Section Plane Manager`** | 2.5.60 | Section plane collection control | `.addPlane(!p)`, `.removePlane(!p)`, `.clearAll()` |
| **`Graphical Selection`** | 2.5.27 | Canvas entity selection set | `.elements()`, `.filter(expr)`, `.clear()` |
| **`BLOCK`** | 2.5.6 | Marine hull block container | `.name`, `.volume()`, `.weight()`, `.panels()` |

---

## Anti-patterns
* **Assuming Non-Existent Object Types**: Inventing classes outside this official 80-type catalog leads to runtime "Unknown Object" errors. Always check `.methods()` and `.members()` using PML reflection before writing integration code.
* **Calling Methods on Stale Handles**: Using `DBREF` or `FILE` instances without verifying `.badRef()` or `.exists()` crashes running macros.

## Key Takeaways
1. SCRM Chapter 2 Section 2.5 contains **80 distinct object and gadget types**.
2. Every object inherits universal reflection and lifecycle methods (`.eq()`, `.type()`, `.clone()`, `.methods()`, `.members()`).
3. Database access relies on `DBREF`, `COLLECTION`, and `EXPRESSION`.
4. 3D vector calculations should always leverage native `POSITION`, `DIRECTION`, and `ORIENTATION` objects rather than manual string parsing.

## Connects To
* **Ch 2**: Variables, Data Types & Scope
* **Ch 7**: Core Built-in System Objects
* **Ch 9**: GUI Gadgets & Layout System
* **Ch 12**: Event Driven Graphics (EDG)
* **Ch 13**: Collections & DABACON Queries
