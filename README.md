# AVEVA Dev Skills 🚀

[English](README.md) | [简体中文](README_zh.md)

[![Agent Skills Standard](https://img.shields.io/badge/Standard-Agent%20Skills-blue?style=flat-square)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Compatible with OpenCode](https://img.shields.io/badge/Compatible-OpenCode-purple?style=flat-square)](https://opencode.ai)
[![Compatible with Claude Code](https://img.shields.io/badge/Compatible-Claude%20Code-orange?style=flat-square)](https://claude.ai)
[![Compatible with Antigravity](https://img.shields.io/badge/Compatible-Antigravity-4285F4?style=flat-square)](https://deepmind.google)
[![Compatible with Cline](https://img.shields.io/badge/Compatible-Cline%20%2F%20Roo%20Code-brightgreen?style=flat-square)](https://github.com/cline/cline)

**AVEVA Dev Skills** is a dedicated engineering knowledge base and professional skill suite designed for AI Coding Agents working on **AVEVA E3D, PDMS, and AVEVA Marine** secondary development and customization.

Built upon the open **[Agent Skills specification](https://agentskills.io)**, the project employs **Progressive Disclosure** architecture: agents load only high-level mental models and indexes at initialization, reading detailed chapters and reference documentation on demand.

Recognizing that modern **.NET / C# managed add-in development** and traditional **PML scripting & UI automation** represent two distinct engineering scenarios with differing requirements, this repository decouples them into two scenario-tailored skills that can be deployed together or independently.

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
> Scope: 20 Systematic Chapters + 80 SCRM System Objects + Production Recipes (858 pages distilled)  
> Best for: PML 1 batch command macros, PML 2 OOP and functions, GUI form layouts, Event Driven Graphics (EDG) 3D canvas interaction, and Marine Drafting automation.

* **Dual-Architecture Paradigm (PML 1 vs PML 2)**: Procedural command streams (`.mac`) vs. modern object-oriented runtime (`.pmlfnc`, `.pmlobj`, `.pmlfrm`).
* **PMLLIB Resolution Contract**: Strict lowercase naming, `pml rehash all` symbol table re-indexing, and `pml reload form` in-memory hot reloading.
* **Deterministic Control Flow**: Explicit loop discipline (AVEVA PML has **no `while` loops**; use `DO ... BREAK IF` and `VALUES`/`INDEX` iterators).
* **DABACON Query Pipeline**: `DBREF` reference semantics, `COLLECTION` query engine, expression filters, and transactional checkpoints (`MARK`/`UNDO`).
* **GUI & Graphics Systems**: Form lifecycle events, comprehensive gadget positioning, asynchronous Event Driven Graphics (EDG) picking callbacks.
* **Marine Drafting Automation**: `MarDrafting` single-document interface (SDI) lifecycle, coordinate transformations, automated dimensions and annotations.
* **Supporting Resources**: [Glossary (glossary.md)](skills/aveva-dev-pml/glossary.md) · [8 Production Patterns (patterns.md)](skills/aveva-dev-pml/patterns.md) · [Decision Cheatsheet (cheatsheet.md)](skills/aveva-dev-pml/cheatsheet.md).

---

## 🛠️ Universal Installation Guide

This suite adheres strictly to the open Agent Skills format. Each skill is prefixed with `aveva-dev-*` for unambiguous identification across any AI agent.

### Option A: Install Complete Suite (Both .NET & PML)
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
* **For .NET / C# Addin Engineers**: Copy only `skills/aveva-dev-dotnet`
* **For PML / Macro / Drawing Script Engineers**: Copy only `skills/aveva-dev-pml`

### Option C: Workspace Integration (Cline / Cursor / Windsurf)
* Clone this repository into your project workspace;
* Add a reference directive in your project instructions (`.clinerules`, `.cursorrules`, or `.windsurfrules`):
  > "For AVEVA .NET secondary development, refer to `skills/aveva-dev-dotnet/SKILL.md`. For PML automation, refer to `skills/aveva-dev-pml/SKILL.md`."

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
  > *"How do I implement non-blocking 3D object picking using Event Driven Graphics (EDG) in PDMS/E3D to retrieve a DBREF?"*
* **Code Review & Auditing**:
  > *"Review this PML snippet for illegal loops, memory leaks, and encoding flaws, then refactor it according to AVEVA best practices."*

---

## 📂 Directory Structure

```text
aveva-dev-skills/
├── .gitignore
├── LICENSE                         # MIT License & Trademark Disclaimer
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
    └── aveva-dev-pml/              # Scenario 2: PML 1/2 / GUI / EDG / Drafting
        ├── SKILL.md                # Entry point & architecture rules (name: aveva-dev-pml)
        ├── cheatsheet.md           # Diagnostic smells & decision rules
        ├── glossary.md             # System objects dictionary
        ├── patterns.md             # 8 Production PML design patterns
        └── chapters/               # 20 Systematic language chapters (ch01 - ch20)
```

---

## 📄 License & Disclaimer

* Licensed under the [MIT License](LICENSE).
* **Trademark & Non-Affiliation Disclaimer**:  
  * AVEVA, PDMS, Everything3D, E3D, DABACON, and PML are registered trademarks or trademarks of AVEVA Solutions Limited or Schneider Electric.
  * This repository is an independent open-source documentation and engineering skill suite maintained by secondary developers. It is **not affiliated with, endorsed by, or sponsored by AVEVA Solutions Limited or Schneider Electric**.
