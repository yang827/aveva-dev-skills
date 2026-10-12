# Cheatsheet & Decision Rules — AVEVA Data Model

## Core Decision Rules
- **Rule 1: Never Hardcode Spatial Offsets When P-points Exist**
  *When*: Connecting nozzles, piping components, or duct fittings.
  *Do*: Use `CONNECT` or snap to P-points (`P1`, `P2`, `PHEAD`, `PTAIL`).
  *Because*: P-points carry orientation, bore, and connection compatibility in addition to coordinate triplets.

- **Rule 2: Prefer System References (`=db/elem`) Over Element Names in Automation**
  *When*: Storing cross-element pointers in macros or batch scripts.
  *Do*: Store `CE.REFNO` or internal reference `=db/elem`.
  *Because*: Element names (`/P101A`) can be renamed during engineering revisions; reference IDs never change.

- **Rule 3: Check `ALIST` Before Querying Optional Attributes or UDAs**
  *When*: Iterating through mixed collections of elements.
  *Do*: Test `IF (CE.ALIST.CONTAINS('ATTRNAME'))`.
  *Because*: Querying an unassigned attribute terminates macro execution with an unhandled exception.

- **Rule 4: Partition Piping by Transport & Erection Limits in Spooler**
  *When*: Generating pipe spools in `SPOO`.
  *Do*: Ensure bounding box $\le 12\text{m} \times 2.5\text{m} \times 2.5\text{m}$ and weight $\le$ crane capacity.
  *Because*: Spools exceeding transport envelopes require expensive site cutting and re-welding.

- **Rule 5: Distinguish Native Attributes from UDAs via Leading Colon**
  *When*: Querying or setting metadata.
  *Do*: Use `:ATTRIBUTE` for Dictionary UDAs and `ATTRIBUTE` for native properties.
  *Because*: Omitting the colon treats the UDA as a syntax error.

---

## Attribute Type Query & Syntax Guide

| Target Data | Query Syntax | Assignment Syntax | Return Example |
|:---|:---|:---|:---|
| **Element Type** | `Q TYPE` | *Read-only* | `EQUI`, `VALV`, `NOZZ` |
| **Element Name** | `Q NAME` | `NAME /NEW_NAME` | `/P-101A-SUCTION` |
| **Owner Element**| `Q OWNER` | *Hierarchy move* | `=2401/100` (`/P-101A`) |
| **World Position** | `Q POS WRT /*` | `POS E 1000 N 2000 U 500` | `E 1000 N 2000 U 500` |
| **Orientation** | `Q ORI` | `ORI Y IS N AND Z IS U` | `Y IS N AND Z IS U` |
| **Direction** | `Q DIR` | `DIR E 45 N` | `E 45.00 N` |
| **Cut Length** | `Q CUTL` | *Dynamic pseudo* | `1250.5mm` |
| **Bounding Box**| `Q BBOX` | *Dynamic pseudo* | `X -500 500 Y -200 200 Z 0 1000` |
| **Catalogue Ref**| `Q CATREF` | `CATREF /VALV-GATE-100` | `/VALV-GATE-100` |
| **User Defined** | `Q :UDA_NAME` | `:UDA_NAME 'VALUE'` | `'APPROVED'` |

---

## Database Hierarchy Quick Reference

```
DESI (Design DB)
└── WORL (World)
    └── SITE
        └── ZONE
            ├── EQUI ──> SUBE ──> NOZZ, BOX, CYLI, DISH
            ├── PIPE ──> BRAN ──> GASK, FLAN, VALV, ELBO, TEE, TUBI
            ├── STRU ──> FRMW ──> SBFR ──> SCTN, GENSEC, PANE
            └── HVAC ──> HVBR ──> HVALV, HDUCT, HBEND

CATA (Catalogue DB)
└── CATALOGUE ──> SECT ──> CATEGORY ──> SKEY, PTSE, GMSE, BLTABLE, BRTAB

DRAF (Draft DB)
└── DEPT ──> REGI ──> DRWG ──> SHEE ──> VIEW ──> ACRULE, ACSTYLE, ADIM
```

---

## Tells & Smells (Diagnostic Heuristics)
- **"Cannot be created here" error**: Current element is not a legal owner of the target type. Run `Q TYPE` and consult Chapter 4 hierarchy.
- **Pipe components insert backwards**: Flow direction inverted. Check `Q ARRI` and `Q LEAV`; ensure `LEAV` points toward Tail.
- **Isometrics fail with "Discontinuous branch"**: Unconnected P-points. Query `Q CREF` along all fittings to locate the missing mating link.
- **"Insufficient access rights"**: User belongs to a team without write rights on the active DB. Query `Q DBWRITE` and `Q ACR`.
