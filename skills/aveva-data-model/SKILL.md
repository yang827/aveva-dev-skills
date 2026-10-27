---
name: aveva-data-model
description: "Knowledge base from the AVEVA Data Model Reference Manual by AVEVA Solutions Ltd. Use when navigating database hierarchies, developing PML automation macros, querying native and pseudo attributes, managing Catalogue/Design/Draft/System databases, or resolving connectivity across AVEVA Plant, Marine, and Everything3D (E3D) models."
metadata:
  suite: aveva-dev-skills
  version: "0.4.0"
---
<!-- argument-hint: [topic, database name, element mnemonic, or chapter number] -->

# AVEVA Data Model Reference Manual

**Author**: AVEVA Solutions Ltd | **Pages**: 826 | **Chapters**: 17 | **Generated**: 2026-10-12

## How to Use This Skill

- **Without arguments** — loads core database frameworks, navigation rules, and mental models below.
- **With a topic or database** — ask about `design database`, `pseudo attributes`, `catalogue`, `pml queries`, or `spooling`; loads relevant chapters.
- **With an element mnemonic** — ask about `NOZZ`, `BRAN`, `EQUI`, `BLTABLE`, `ACRULE`, or `ENGITE`; jumps directly to element schema and owner/member definitions.
- **With chapter number** — ask for `ch04` or `ch15` to dive into specific reference chapters.
- **Browse** — ask "what chapters do you have?" to see the full chapter index.

When you ask about a specific database or element schema, I will read the corresponding chapter file before answering.

---

## Core Frameworks & Mental Models

### 1. Invariant Directed Tree Architecture

Every element in an AVEVA database resides in a strict hierarchical ownership tree. There are no orphan records.

- Root element is `WORL` (World).
- Every non-root element has exactly one `OWNER`.
- Each element type has an explicit, unalterable set of **Legal Owners** and **Legal Members**.
- Moving up the hierarchy: use `OWNER`. Moving down: use member indexing (`FIRST`, `LAST`, `MEMBER N`). Moving sideways: use `NEXT` and `PREV`.

### 2. Primary vs. Secondary Elements

- **Primary Elements** (`SITE`, `ZONE`, `EQUI`, `PIPE`, `STRU`, `BLTABLE`, `DRWG`): Standalone engineering assets capable of carrying global unique names (`/NAME`) and independent drawing/clash representation.
- **Secondary Elements** (`NOZZ`, `BOX`, `CYLI`, `BRAN`, `VALV`, `SCTN`, `VIEW`): Component parts and geometry primitives that cannot exist without their owning primary element.

### 3. P-point Connection & Spatial Topology

Physical connectivity across all disciplines (Piping, HVAC, Steel, Cabling) is governed by parametric Point Sets (`PTSE`):

- `P0`: Insertion origin of the component.
- `P1`: Flow entry port (`PARRIVE`).
- `P2`: Flow exit port (`PLEAVE`).
- `P3`+: Branch or auxiliary connection ports.
- Connecting components snaps P-points in space and enforces bore, rating, and connection type compatibility (`COCO`).

### 4. Attribute Taxonomy: Standard, Pseudo, and UDAs

- **General Native Attributes**: Common to all elements (`NAME`, `TYPE`, `OWNER`, `POS`, `ORI`, `LOCK`).
- **Special Native Attributes**: Specific to an element class (`BORE`, `TEMP`, `PRESS`, `HBOR`, `TBOR`).
- **Pseudo Attributes**: Dynamic runtime computations evaluated on the fly by the engine (`POS WRT /*`, `CRFA`, `BBOX`, `CUTL`, `ARRI`, `LEAV`, `CREF`, `WVOL`). Never stored statically on disk; read-only.
- **User-Defined Attributes (UDAs)**: Project-specific schema extensions defined in the Dictionary database (`DICT`) and always prefixed with a colon (`:STRESS_REV`, `:PO_NUM`).

---

## Chapter Index

| #                                                   | Title                          | Key Frameworks & Mnemonic Elements                                                          |
| :-------------------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------------------ |
| [ch01](chapters/ch01-introduction.md)                | Introduction                   | Database concepts, PML macro automation, Assumptions, MDB                                   |
| [ch02](chapters/ch02-catalogue-database.md)          | Catalogue Database             | `CATALOGUE`, `SECT`, `CATEGORY`, `PTSE`, `GMSE`, `BLTABLE`, `COCO`, `BRTAB` |
| [ch03](chapters/ch03-communications-database.md)     | Communications Database        | `COMW`, `COMM`, Inter-process messaging, claim routing                                  |
| [ch04](chapters/ch04-elements-in-design-database.md) | Elements in Design Database    | `WORL`, `SITE`, `ZONE`, `EQUI`, `PIPE`, `BRAN`, `STRU`, `NOZZ`, `VALV`    |
| [ch05](chapters/ch05-dictionary-database.md)         | Dictionary Database            | `DICT`, `UDA`, `DBVW`, `ATTCOLUMN`, `ATTFILTER`, Lexicon schemas                  |
| [ch06](chapters/ch06-draft-database.md)              | Draft Database                 | `DEPT`, `REGI`, `DRWG`, `SHEE`, `VIEW`, `ACRULE`, `ACSTYLE`, 2D projection    |
| [ch07](chapters/ch07-global-database.md)             | Global Database                | `GLOCWL`, `DBLOC`, `DBALL`, `GRP`, Multi-site replication, Token claim              |
| [ch08](chapters/ch08-manu-database.md)               | Manu Database                  | `MANPKG`, `CPIN`, `CPINJG`, `MBURN`, `MAPLNS`, Hull NC plate cutting              |
| [ch09](chapters/ch09-property-database.md)           | Property Database              | `CASWORLD`, `CABDATA`, `CARD`, `CMPDATA`, Material and cable sizing data            |
| [ch10](chapters/ch10-schematic-database.md)          | Schematic Database             | `SCDIAGRAM`, `SCPIPE`, `SCBRANCH`, `SCVALV`, P&ID topology, 2D-3D compare           |
| [ch11](chapters/ch11-spooler-database.md)            | Spooler Database               | `SPOOL`, `FIELD`, `IWELD`, `AWELD`, `AITEMS`, Spool fabrication breakdown         |
| [ch12](chapters/ch12-system-database.md)             | System Database                | `ACRW`, `ACR`, `ACRL`, `USER`, `TEAM`, `MDB`, Role-based access security        |
| [ch13](chapters/ch13-transaction-database.md)        | Transaction Database           | `TRMONTH`, `TRDAY`, `TRINCOMMAND`, `TRFAILURE`, Audit history, Checkpoints          |
| [ch14](chapters/ch14-other-databases.md)             | Other Databases                | `ENGWLD`, `ENGGRP`, `ENGITE`, Centralized engineering item tag registers              |
| [ch15](chapters/ch15-pseudo-attributes.md)           | Pseudo Attributes              | Dynamic attributes: `CRFA`, `CUTL`, `BBOX`, `ARRI`, `LEAV`, `CREF`, `WVOL`    |
| [ch16](chapters/ch16-introduction-to-attributes.md)  | Introduction to Attributes     | Strongly typed attributes: Name, Ref, Real, Integer, Position, Orientation                  |
| [ch17](chapters/ch17-mapping-keywords-attributes.md) | Mapping Keywords to Attributes | Legacy Hull Data Extraction keywords to modern database attributes                          |

---

## Topic Index

- **Access Control & Permissions** → [ch12](chapters/ch12-system-database.md)
- **Annotations & 2D Drawings** → [ch06](chapters/ch06-draft-database.md)
- **Attributes (Native & Strongly Typed)** → [ch16](chapters/ch16-introduction-to-attributes.md)
- **Attributes (Pseudo & Computed)** → [ch15](chapters/ch15-pseudo-attributes.md)
- **Attributes (User-Defined / UDAs)** → [ch05](chapters/ch05-dictionary-database.md)
- **Bolting & Compatibility Tables** → [ch02](chapters/ch02-catalogue-database.md)
- **Cable & Material Properties** → [ch09](chapters/ch09-property-database.md)
- **Catalogue & Point Sets (PTSE)** → [ch02](chapters/ch02-catalogue-database.md)
- **Design 3D Hierarchy (Pipe, Equi, Stru)** → [ch04](chapters/ch04-elements-in-design-database.md)
- **Engineering Items & Tag Management** → [ch14](chapters/ch14-other-databases.md)
- **Global Multi-site Replication** → [ch07](chapters/ch07-global-database.md)
- **Legacy Hull Extraction Migration** → [ch17](chapters/ch17-mapping-keywords-attributes.md)
- **Manufacturing, Pin Jigs & Burning** → [ch08](chapters/ch08-manu-database.md)
- **P&ID & Schematic Connectivity** → [ch10](chapters/ch10-schematic-database.md)
- **Piping Spools & Welds** → [ch11](chapters/ch11-spooler-database.md)
- **Transaction Logs & Audit Trails** → [ch13](chapters/ch13-transaction-database.md)

---

## Supporting Files

- [glossary.md](glossary.md) — Alphabetical dictionary of all key elements and concepts
- [patterns.md](patterns.md) — Reusable PML traversal, query, and spec-driven insertion patterns
- [cheatsheet.md](cheatsheet.md) — Quick reference tables, decision rules, and syntax diagnostics

---

## Scope & Limits

This skill covers the database schema, element types, and attribute models defined in the AVEVA Data Model Reference Manual (AVEVA Marine / Plant / Everything3D). For hands-on PML programming syntax, GUI form creation, or module-specific workflows (e.g. ISODRAFT, PARAGON, LEXICON), combine this skill with the respective AVEVA Reference Guides.
