# Changelog

All notable changes to the `aveva-dev-skills` suite will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [v0.4.0] - 2026-10-27

### Added
- **Zero-Dependency Offline PML Syntax Checker (`tools/pml-parse/`)**:
  - Integrated standalone Tree-sitter CLI (`bin/tree-sitter.exe` v0.27.1) and precompiled PML grammar library (`bin/pml.dll`).
  - Complete offline execution with zero external prerequisites: no Node.js, npm, C/C++ compiler, or network connectivity required.
  - Added [`parse-pml.ps1`](skills/aveva-dev-pml/tools/pml-parse/parse-pml.ps1) for validating individual files, projects, or directories (`-Recurse`), with AST inspection support (`-Tree`).
- **Mandatory 0-FAIL Quality Gate (Core Framework 2c)**:
  - Added Core Framework 2c to [`skills/aveva-dev-pml/SKILL.md`](skills/aveva-dev-pml/SKILL.md), requiring all newly generated or edited PML code (`.pml`, `.pmlobj`, `.pmlfnc`, `.pmlfrm`, `.mac`) to achieve 0 FAIL prior to user delivery.
- **Industrial PMLLIB Baseline Benchmark (94.02%)**:
  - Added [`bench-pmllib.ps1`](skills/aveva-dev-pml/tools/pml-parse/bench-pmllib.ps1) as a continuous parser sanity gate.
  - Achieved a **94.02%** clean parse baseline across the 6,075 bundled official AVEVA PMLLIB files (5,712 OK), with 22/22 unit corpus tests passing.
- **Verified Engineering Idioms (Section 10)**:
  - Added Section 10 to [`skills/aveva-dev-pml/references/pmllib-idioms.md`](skills/aveva-dev-pml/references/pmllib-idioms.md) detailing officially verified patterns for console print (`$P`) and numeric input gadgets (`numericinput` vs `text ... is REAL`) with line citations to delivered PMLLIB files.

### Fixed
- **Grammar False Positives (25 Official Files Rescued, 0 Regressions)**:
  - Fixed `$P` free text output containing trailing dots or ellipses (`$P ... starts...`, `$p Working....`), aligning parser behavior with the runtime command processor.
  - Added complete keyword and clause stack support for `numericinput` gadgets (`label`, `tagwidth`, `anchor`, `at`, `callback`, `range`, `ndp`, `width`).
  - Rescued 25 previously failing delivered PMLLIB files with zero regressions.

### Changed
- **Suite-Wide Metadata Bump**: Synchronized metadata version to `0.4.0` across [`aveva-dev-pml`](skills/aveva-dev-pml/SKILL.md), [`aveva-dev-dotnet`](skills/aveva-dev-dotnet/SKILL.md), and [`aveva-data-model`](skills/aveva-data-model/SKILL.md).
- **Documentation**: Updated [`README.md`](README.md) and [`README_zh.md`](README_zh.md) with the `v0.4.0` release badge, `tools/pml-parse/` directory layout, and evaluation comparison matrices.

---

## [v0.3.1] - 2026-10-13

### Added
- **Anti-Hallucination Core Rules for PML (`aveva-dev-pml`)**:
  - **Core Framework 10 (Prohibition of `null` & Typed Empty Returns)**: Eliminated AI hallucinations from Java/C#/Python habits (`return null`, `!x.null()`, `!x eq null`). Clarified engine behaviors (`CP: Syntax error` and `Method <STRING>.NULL() not found`). Standardized typed empty return idioms (`return ''`, `return object DBREF()`, `return object ARRAY()`) and call-site checks (`.unset()`, `.eq('')`, `undefined()`, `.badRef()`).
  - **Core Framework 11 (Bang-Prefix Arity Discipline)**: Established that built-in session globals (`!!CE`, `!!ALERT`, `!!edgCntrl`, `!!evar`) strictly exist in double-bang form only; single-bang `!ce` is an unassigned local variable. Standardized direct access (`!!ce.xxx`) and entry snapshots (`!ce = !!ce`).
- **Cross-Reference Sync**: Updated `ch02-variables-data-types.md`, `ch05-pml2-functions-methods.md`, `cheatsheet.md`, and `glossary.md` with anti-pattern tables and rules.

### Changed
- **Suite Version Alignment**: Upgraded metadata version to `0.3.1` across all three skills (`aveva-data-model`, `aveva-dev-dotnet`, `aveva-dev-pml`).

---

## [v0.3.0] - 2026-10-12

### Added
- **`aveva-data-model` Skill**:
  - Added new dedicated skill covering the DABACON database hierarchy and architecture across 17 chapters.
  - Comprehensive coverage of Catalogue, Design, Draft, Manu, Global, Property, Schematic, Spooler, System, and Transaction databases.
  - Added pseudo-attributes (`ch15`) and keyword-to-attribute mapping references (`ch16`, `ch17`).
  - Added companion files: `cheatsheet.md`, `glossary.md`, and `patterns.md`.

### Changed
- **Comment Formatting Discipline**: Enforced strict comment formatting across code examples and chapters.
- **Suite Version Alignment**: Upgraded metadata version across all skills to `0.3.0`.
- **Documentation**: Documented `aveva-data-model` across bilingual READMEs.

---

## [v0.2.0] - 2026-10-10

### Added
- **Bundled Delivered PMLLIB Snapshot**: Bundled an offline snapshot of AVEVA-delivered PML source (~6,075 files: `.pmlfrm`, `.pmlfnc`, `.pmlobj`) under `skills/aveva-dev-pml/PMLLIB/` as authoritative syntax ground truth.
- **Verified PMLLIB Index & Idioms**:
  - Added `references/pmllib-index.md` indexing module, flags, lines, and descriptions for all bundled files.
  - Added `references/pmllib-idioms.md` with verified code patterns citing actual PMLLIB source files.
  - Added `tools/regen-pmllib-index.ps1` for automated index regeneration.

### Fixed
- **Strict PML Syntax Rules**:
  - **Post-attached `HANDLE`**: Enforced rule that `HANDLE ... ENDHANDLE` must follow the failing statement, never wrap it.
  - **`ANY` Type Restrictions**: Clarified `is ANY` is only valid as a signature-position parameter/return specifier, forbidden for standard variable declarations.
  - **Gadget `.dtext` Property**: Clarified that `.dtext` requires an `ARRAY of STRING` assignment; calling `.dtext.append()` is invalid.
  - **`PARAGRAPH` Ordering**: Enforced syntax order where `at x y` position specifiers must precede `text '...'`.

### Changed
- Upgraded `aveva-dev-dotnet` and `aveva-dev-pml` skills to `0.2.0`.

---

## [v0.1.0] - 2026-10-01

### Added
- **Initial Public Release of `aveva-dev-skills`**:
  - **`aveva-dev-dotnet`**: Comprehensive developer knowledge base for AVEVA Marine & PDMS .NET development across 10 chapters (CAF Addin framework, Dabacon `DbElement`, PMLNet interop, `GridControl`, MarAPI, and Planar structural modeling).
  - **`aveva-dev-pml`**: Comprehensive knowledge base for AVEVA PML development across 20 chapters (PML 1/2 paradigms, form layouts, gadget mechanics, Event Driven Graphics, and Marine Drafting automation).
  - Production-grade design patterns (`patterns.md`), diagnostic cheatsheets (`cheatsheet.md`), and system object glossaries (`glossary.md`).
  - Fully bilingual documentation in English and Simplified Chinese (`README.md`, `README_zh.md`, `EVALS.md`, `EVALS_zh.md`).
  - Open standard compatibility for Agent Skills across OpenCode, Claude Code, Antigravity IDE, Cursor, and Windsurf.

---

[v0.4.0]: https://github.com/yang827/aveva-dev-skills/compare/v0.3.1...v0.4.0
[v0.3.1]: https://github.com/yang827/aveva-dev-skills/compare/v0.3.0...v0.3.1
[v0.3.0]: https://github.com/yang827/aveva-dev-skills/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/yang827/aveva-dev-skills/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/yang827/aveva-dev-skills/releases/tag/v0.1.0
