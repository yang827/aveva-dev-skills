<p align="center">
  <img src="assets/banner.jpg" alt="AVEVA Dev Skills Banner" width="100%" />
</p>

# AVEVA Dev Skills 🚀

[English](README.md) | [简体中文](README_zh.md) | [Benchmark & Evals](EVALS.md) | [Changelog](CHANGELOG.md)

[![Agent Skills Standard](https://img.shields.io/badge/Standard-Agent%20Skills-blue?style=flat-square)](https://agentskills.io)
[![Release: v0.4.0](https://img.shields.io/badge/Release-v0.4.0-informational?style=flat-square)](https://github.com/yang827/aveva-dev-skills/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Compatible with OpenCode](https://img.shields.io/badge/Compatible-OpenCode-purple?style=flat-square)](https://opencode.ai)
[![Compatible with Claude Code](https://img.shields.io/badge/Compatible-Claude%20Code-orange?style=flat-square)](https://claude.ai)
[![Compatible with Antigravity](https://img.shields.io/badge/Compatible-Antigravity-4285F4?style=flat-square)](https://deepmind.google)
[![Compatible with Cline](https://img.shields.io/badge/Compatible-Cline%20%2F%20Roo%20Code-brightgreen?style=flat-square)](https://github.com/cline/cline)

**AVEVA Dev Skills** is a dedicated engineering knowledge base and professional skill suite designed for AI Coding Agents working on **AVEVA Marine and AVEVA PDMS** secondary development and customization.

Built upon the open **[Agent Skills specification](https://agentskills.io)**, the project employs **Progressive Disclosure** architecture: agents load only high-level mental models and indexes at initialization, reading detailed chapters and reference documentation on demand.

Covering the three foundational pillars of AVEVA customization, this repository decouples engineering knowledge into three scenario-tailored skills that can be deployed together or independently:
1. **.NET / C# Managed Add-in Development & Architecture** (`aveva-dev-dotnet`)
2. **PML Scripting, Object-Oriented Runtime & GUI Automation** (`aveva-dev-pml`)
3. **DABACON Database Hierarchy, Element Schemas & Pseudo-Attribute Navigation** (`aveva-data-model`)

---

## 📦 Skills in this Suite

### Scenario 1: `aveva-dev-dotnet` — .NET Secondary Development & Architecture
> Path: [`skills/aveva-dev-dotnet/`](skills/aveva-dev-dotnet/SKILL.md)  
> Scope: 10 Core Chapters + 4 Comprehensive API References (~1,822 pages distilled)  
> Best for: Modern C# Add-ins, CAF Docked Windows, Dabacon object database access, PMLNet interop, and Marine structural modeling (marAPI / Planar).

* **Common Application Framework (CAF)**: `IAddin` lifecycle, `ServiceManager` locator, `WindowManager` docked panel management, declarative `Command` & UIC separation.
* **Dabacon Database Paradigm**: `DbElement` pointer value semantics, STA single-thread discipline, `PseudoAttribute` registration, transactions, and event listeners (`DbEvents`).
* **PMLNet Cross-Language Bridge**: The 5 golden rules of `[PMLNetCallable]`, type mapping safety, bidirectional event dispatching, WinForms/WPF embedding in PML containers.
* **Marine Domain Objects (marAPI)**: Deterministic native resource disposal (`IDisposable` & `using` patterns), `MarDataBase` component queries, Vitesse Python engine bridge.
* **Planar Structural Modeling**: `PanelStatement` declarative hierarchy, plate boundary trimming, stiffener end connections, hole compensations, and manufacturing features.
* **Supporting Resources**: [Glossary (glossary.md)](skills/aveva-dev-dotnet/glossary.md) · [Architectural Patterns (patterns.md)](skills/aveva-dev-dotnet/patterns.md) · [Diagnostics Cheatsheet (cheatsheet.md)](skills/aveva-dev-dotnet/cheatsheet.md) · [Full API References (references/)](skills/aveva-dev-dotnet/references/).

---

### Scenario 2: `aveva-dev-pml` — PML Scripting, OOP & GUI Automation
> Path: [`skills/aveva-dev-pml/`](skills/aveva-dev-pml/SKILL.md)  
> Scope: 20 Systematic Chapters + 80 SCRM System Objects + 6,075 Delivered Sources + Offline Syntax Gate  
> Best for: PML 1 batch command macros, PML 2 OOP and functions, GUI form layouts, Event Driven Graphics (EDG) 3D canvas interaction, and Marine Drafting automation.

* **Dual-Architecture Paradigm (PML 1 vs PML 2)**: Procedural command streams (`.mac`) vs. modern object-oriented runtime (`.pmlfnc`, `.pmlobj`, `.pmlfrm`).
* **PMLLIB Resolution Contract**: Strict lowercase naming, `pml rehash all` symbol table re-indexing, and `pml reload form` in-memory hot reloading.
* **Deterministic Control Flow**: Explicit loop discipline (AVEVA PML has **no `while` loops**; use `DO ... BREAK IF` and `VALUES`/`INDEX` iterators).
* **DABACON Query Pipeline**: `DBREF` reference semantics, `COLLECTION` query engine, expression filters, and transactional checkpoints (`MARK`/`UNDO`).
* **GUI & Graphics Systems**: Form lifecycle events, comprehensive gadget positioning, asynchronous Event Driven Graphics (EDG) picking callbacks.
* **Marine Drafting Automation**: `MarDrafting` single-document interface (SDI) lifecycle, coordinate transformations, automated dimensions and annotations.
* **Offline Syntax Gate & Verification (Tree-sitter)**: Bundled standalone PML parser (`tools/pml-parse/`) with zero external dependencies (no Node.js, compiler, or network). Parses PML 1 & PML 2 with a **94.02%** clean parse baseline across 6,075 official PMLLIB source files; enforces mandatory **0-FAIL** validation (`parse-pml.ps1`) for AI-generated code.
* **Supporting Resources**: [Glossary (glossary.md)](skills/aveva-dev-pml/glossary.md) · [8 Production Patterns (patterns.md)](skills/aveva-dev-pml/patterns.md) · [Decision Cheatsheet (cheatsheet.md)](skills/aveva-dev-pml/cheatsheet.md) · [Verified PMLLIB Idioms (references/)](skills/aveva-dev-pml/references/pmllib-idioms.md) · [Offline Syntax Gate (tools/pml-parse/)](skills/aveva-dev-pml/tools/pml-parse/README.md).

---

### Scenario 3: `aveva-data-model` — DABACON Database Schemas & Hierarchy Navigation
> Path: [`skills/aveva-data-model/`](skills/aveva-data-model/SKILL.md)  
> Scope: 17 Systematic Chapters + Comprehensive Element Taxonomy (~826 pages distilled)  
> Best for: Navigating database hierarchies, element schema queries (Legal Owner / Legal Member), attribute introspection, pseudo-attribute resolution, and Catalogue / Design / Draft / Spooler / System database architecture.

* **Invariant Directed Tree Architecture**: Strict hierarchical ownership rooted at `WORL`; explicit Legal Owner and Legal Member constraints; no orphan records.
* **Element Taxonomy & Schema**: Primary elements (`SITE`, `ZONE`, `EQUI`, `PIPE`, `STRU`, `DRWG`) vs secondary components (`NOZZ`, `BRAN`, `VALV`, `SCTN`, `VIEW`).
* **P-point Connection Topology**: Parametric Point Sets (`PTSE`), flow ports (`PARRIVE`, `PLEAVE`), branch ports, and connection compatibility (`COCO`).
* **Attribute System & Pseudo-Attributes**: Standard native attributes, Dictionary UDAs (`:ATTR`), and dynamic engine-evaluated pseudo-attributes (`POS WRT /*`, `CRFA`, `BBOX`, `CUTL`, `ARRI`, `LEAV`, `CREF`, `WVOL`).
* **Complete Database Ecosystem**: Dedicated deep dives into Catalogue (`CATA`), Design (`DESI`), Draft (`PADD`), Dictionary (`DICT`), Schematic (`SCHEM`), Spooler (`SPLR`), System (`SYST`), and Transaction databases.
* **Supporting Resources**: [Glossary (glossary.md)](skills/aveva-data-model/glossary.md) · [Architectural Patterns (patterns.md)](skills/aveva-data-model/patterns.md) · [Diagnostics Cheatsheet (cheatsheet.md)](skills/aveva-data-model/cheatsheet.md) · [Full Chapters (chapters/)](skills/aveva-data-model/chapters/).

---

## 🛠️ Universal Installation Guide

This suite adheres strictly to the open Agent Skills format. Each skill is prefixed with `aveva-*` for unambiguous identification across any AI agent.

### Option A: Install Complete Suite (All 3 Skills: .NET, PML & Data Model)
Copy all skills to your AI agent's global skills directory:

```bash
# OpenCode (opencode.ai)
cp -r skills/* ~/.config/opencode/skills/

# Claude Code (Anthropic)
cp -r skills/* ~/.claude/skills/

# Google Antigravity (PowerShell)
Copy-Item -Recurse skills/* "$env:USERPROFILE\.gemini\config\skills\"
```

### Option B: Scenario-Based Installation (Recommended)
Choose only the skill required for your current development task:
* **For .NET / C# Add-in Engineers**: Copy only `skills/aveva-dev-dotnet`
* **For PML / Macro / Drawing Script Engineers**: Copy only `skills/aveva-dev-pml`
* **For Database / Schema / Attribute Query Engineers**: Copy only `skills/aveva-data-model`

### Option C: Workspace Integration (Cline / Cursor / Windsurf)
* Clone this repository into your project workspace;
* Add a reference directive in your project instructions (`.clinerules`, `.cursorrules`, or `.windsurfrules`):
  > "For AVEVA .NET secondary development, refer to `skills/aveva-dev-dotnet/SKILL.md`. For PML automation, refer to `skills/aveva-dev-pml/SKILL.md`. For DABACON database hierarchies and attribute schemas, refer to `skills/aveva-data-model/SKILL.md`."

### Option D: Web AI & Knowledge Bases (Claude Projects, Custom GPTs, RAG)
Upload `SKILL.md`, `cheatsheet.md`, and `patterns.md` from the relevant skill directory into your project's knowledge base.

---

## 💡 Example Prompts & Inquiries

Once installed, simply converse naturally with your AI coding agent:

* **.NET / CAF**:
  > *"How do I implement a docked window add-in in AVEVA Marine using CAF WindowManager and CommandManager? Provide a complete C# example."*
* **Dabacon Database**:
  > *"Show me how to safely read and mutate 3D pipe component attributes in C#. What STA threading and transaction precautions must I take?"*
* **PML Forms & GUI**:
  > *"Create a PML 2 form with a SELECTOR dropdown, a data grid gadget, and callback methods for user selection."*
* **EDG 3D Picking**:
  > *"How do I implement non-blocking 3D object picking using Event Driven Graphics (EDG) in PDMS to retrieve a DBREF?"*
* **Code Review & Auditing**:
  > *"Review this PML snippet for illegal loops, memory leaks, and encoding flaws, then refactor it according to AVEVA best practices."*
* **Offline PML Syntax Verification**:
  > *"Validate my PML 2 form script with the bundled syntax checker and inspect the parsed AST tree for any syntax or gadget clause errors."*
* **Data Model & Element Hierarchy**:
  > *"What is the standard element hierarchy under an EQUI or PIPE in the Design database? What owner/member rules apply?"*
* **Pseudo-Attributes & Database Navigation**:
  > *"Which pseudo-attributes can I query on a NOZZ or BRAN element in PML/C#, and how do they evaluate coordinates and connectivity?"*

---

## ⚖️ AI Agent Benchmark & Anti-Hallucination Evals

General LLMs frequently hallucinate when dealing with AVEVA software due to sparse public training data and proprietary runtime rules. Here is a summary of real-world comparisons:

| Scenario | ❌ Unskilled AI (Common Hallucination) | ✅ With `aveva-dev-skills` | AVEVA Host Consequence |
|---|---|---|---|
| **PML Control Flow** | Inventing `while ... endwhile` or `for` | Strict `do ... break if (...) ... enddo` | `(61,2) Command not recognised` |
| **Dabacon DB Threading** | Asynchronous `Task.Run` on `DbElement` | Enforces STA single-thread + `PdmsException` guard | Unhandled AccessViolation crash |
| **PMLNet Bridge Contract** | Passing `int`/`float`, missing `Assign()` | Strict `double`, `ArrayList`, `[PMLNetCallable()]` | `(81,146) Method not found` |
| **marAPI Native Resource** | Leaving `MarDataBase`/`MarObject` to GC | Deterministic `using` / `IDisposable` lifecycle | Native handle leak & crash on save |
| **CAF UI Architecture** | Hardcoding `Click` events in Form | Decoupled `CommandManager` Key + `.uic` XML | Inoperable menus, docking failure |
| **PMLLIB Hot Reloading** | CamelCase filenames, restart-only advice | Lowercase filenames, `pml rehash all`, `reload form` | Form not found, stale code execution |
| **PML Syntax Verification** | Delivering unverified code with invalid gadget/command syntax | Offline Tree-sitter syntax gate (`parse-pml.ps1`, mandatory 0-FAIL) | Fatal parser crash or gadget declaration failure |

👉 **Read the comprehensive evaluation report with code examples in [EVALS.md](EVALS.md) (中文版: [EVALS_zh.md](EVALS_zh.md))**.

---


## 📂 Directory Structure

```text
aveva-dev-skills/
├── assets/
│   └── banner.jpg                  # Repository Social Preview Banner
├── .gitignore
├── LICENSE                         # MIT License & Trademark Disclaimer
├── EVALS.md                        # AI Benchmark & Anti-Hallucination Evals (English)
├── EVALS_zh.md                     # AI 实测基准与防幻觉评测报告 (中文)
├── README.md                       # English Documentation (Default)
├── README_zh.md                    # Chinese Documentation (中文文档)
└── skills/                         # Standard Agent Skills Suite
    ├── aveva-dev-dotnet/           # Scenario 1: C# / .NET / CAF / MarAPI
    │   ├── SKILL.md                # Entry point & core mental model (name: aveva-dev-dotnet)
    │   ├── cheatsheet.md           # Heuristics & diagnostics decision tree
    │   ├── glossary.md             # API class & terminology reference
    │   ├── patterns.md             # Production architectural patterns
    │   ├── chapters/               # 10 In-depth subsystem chapters (ch01 - ch10)
    │   └── references/             # 4 Full official API reference manuals
    ├── aveva-dev-pml/              # Scenario 2: PML 1/2 / GUI / EDG / Drafting
    │   ├── SKILL.md                # Entry point & architecture rules (name: aveva-dev-pml)
    │   ├── cheatsheet.md           # Diagnostic smells & decision rules
    │   ├── glossary.md             # System objects dictionary
    │   ├── patterns.md             # 8 Production PML design patterns
    │   ├── chapters/               # 20 Systematic language chapters (ch01 - ch20)
    │   ├── references/             # Delivered PMLLIB index & verified idioms
    │   ├── tools/                  # Automation scripts & offline quality gate
    │   │   ├── regen-pmllib-index.ps1  # Automated index regenerator
    │   │   └── pml-parse/          # Tree-sitter offline syntax checker (94.02% baseline)
    │   └── PMLLIB/                 # Bundled official PML source snapshot (~6,075 files)
    └── aveva-data-model/           # Scenario 3: DABACON Database Hierarchy & Schemas
        ├── SKILL.md                # Entry point & database navigation rules (name: aveva-data-model)
        ├── cheatsheet.md           # Database types & schema heuristics
        ├── glossary.md             # Element mnemonics & database dictionary
        ├── patterns.md             # Query & hierarchy traversal patterns
        └── chapters/               # 17 Reference manual chapters (ch01 - ch17)
```

---

## 📄 License & Disclaimer

* Licensed under the [MIT License](LICENSE).
* **Trademark & Non-Affiliation Disclaimer**:  
  * AVEVA, PDMS, DABACON, and PML are registered trademarks or trademarks of AVEVA Solutions Limited or Schneider Electric.
  * This repository is an independent open-source documentation and engineering skill suite maintained by secondary developers. It is **not affiliated with, endorsed by, or sponsored by AVEVA Solutions Limited or Schneider Electric**.

