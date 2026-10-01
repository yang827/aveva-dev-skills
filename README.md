# AVEVA Dev Skills 🚀

[![Agent Skills Standard](https://img.shields.io/badge/Standard-Agent%20Skills-blue?style=flat-square)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)
[![Compatible with OpenCode](https://img.shields.io/badge/Compatible-OpenCode-purple?style=flat-square)](https://opencode.ai)
[![Compatible with Claude Code](https://img.shields.io/badge/Compatible-Claude%20Code-orange?style=flat-square)](https://claude.ai)
[![Compatible with Antigravity](https://img.shields.io/badge/Compatible-Antigravity-4285F4?style=flat-square)](https://deepmind.google)
[![Compatible with Cline](https://img.shields.io/badge/Compatible-Cline%20%2F%20Roo%20Code-brightgreen?style=flat-square)](https://github.com/cline/cline)

**AVEVA Dev Skills** 是专为 AI 编程智能体（AI Coding Agents）打造的 **AVEVA Marine & Plant（PDMS / Everything3D / Tribon）二次开发工程知识库与专业技能包**。

本项目遵循开放的 **[Agent Skills 规范](https://agentskills.io)**，采用 **渐进式披露（Progressive Disclosure）** 架构设计。AI Agent 在启动时仅加载索引与核心心智模型，在具体编码和排错时才按需读取具体章节与 API 参考，在保障超高专业度与严谨度的同时，实现极高的 Token 效率。

---

## 📦 技能模块概览 (Included Skills)

本项目目前包含两套深度提炼的核心技能包：

### 1. `aveva-dotnet` — .NET 二次开发与架构体系
> 路径: [`skills/aveva-dotnet/`](skills/aveva-dotnet/SKILL.md)  
> 覆盖规模: 10 大核心章节 + 4 部全量 API 手册 (~1,822 页工程文档浓缩)

* **CAF 微内核应用框架**: `IAddin` 插件生命周期、`ServiceManager` 服务检索、`WindowManager` 吸附窗口管理、`Command` 与 UIC 声明式解耦。
* **Dabacon 对象数据库**: `DbElement` 指针值语义、STA 单线程调度防卫、伪属性矩阵（`PseudoAttribute`）、事务与变更监听（`DbEvents`）。
* **PMLNet 跨语言桥接**: `[PMLNetCallable]` 五大铁律、类型安全映射、事件双向总线、WinForms/WPF 控件内嵌。
* **Marine 领域对象 (marAPI)**: 非托管资源确定性释放（`IDisposable` 与 `using` 规程）、`MarDataBase` 构件准则查询、Vitesse Python 引擎打通。
* **平面分段参数化建模 (Planar)**: `PanelStatement` 语句体系、板架轮廓修剪、型材端切、开孔补强与数控下料制造特征。
* **配套文件**: [速查字典 (glossary.md)](skills/aveva-dotnet/glossary.md) · [工程模式 (patterns.md)](skills/aveva-dotnet/patterns.md) · [排错手册 (cheatsheet.md)](skills/aveva-dotnet/cheatsheet.md) · [全量 API 参考 (references/)](skills/aveva-dotnet/references/)。

---

### 2. `aveva-pml` — PML 宏、面向对象编程与界面自动化
> 路径: [`skills/aveva-pml/`](skills/aveva-pml/SKILL.md)  
> 覆盖规模: 20 大系统章节 + 80 种 SCRM 系统对象速查 + 实战代码配方 (858 页全量提炼)

* **双架构范式 (PML 1 vs PML 2)**: 命令行批处理宏（`.mac`）与现代面向对象运行时（`.pmlfnc`, `.pmlobj`, `.pmlfrm`）严格分工。
* **PMLLIB 模块检索规范**: 文件命名全小写契约、`pml rehash all` 符号表重建、`pml reload form` 热重载。
* **结构化循环与控制流**: PML 严禁使用 `while` 语法，全面规范 `DO ... BREAK IF` 与 `VALUES`/`INDEX` 迭代器。
* **DABACON 数据检索管道**: `DBREF` 引用语义、`COLLECTION` 查询引擎、表达式过滤器与事务撤销（`MARK`/`UNDO`）。
* **GUI 界面与交互系统**: 现代表单生命周期、全套 Gadget 布局器、Event Driven Graphics (EDG) 异步拾取交互。
* **Marine Drafting 出图自动化**: `MarDrafting` 单文档接口（SDI）控制、图纸坐标投影、文字与尺寸标注自动化。
* **配套文件**: [速查字典 (glossary.md)](skills/aveva-pml/glossary.md) · [八大生产级设计模式 (patterns.md)](skills/aveva-pml/patterns.md) · [诊断决策树 (cheatsheet.md)](skills/aveva-pml/cheatsheet.md)。

---

## 🛠️ 安装与引入指南 (Universal Installation)

本仓库保持 **纯净解耦** 的标准目录结构，不绑定任何特定工具，支持任意兼容 Agent Skills 或具备文件读取能力的 AI 编程工具：

```
aveva-dev-skills/
├── skills/
│   ├── aveva-dotnet/
│   └── aveva-pml/
```

您可以根据正在使用的 AI 工具，选择以下最适合的方式引入：

### 1. OpenCode (opencode.ai)
OpenCode 原生支持 Agent Skills 标准：
* **项目级引入**：直接将 `skills/` 文件夹复制到工程根目录，或在工程的 `opencode.jsonc` 中配置：
  ```jsonc
  {
    "skills": ["./skills"]
  }
  ```
* **全局引入**：将技能目录复制到用户全局配置路径：
  ```bash
  # Linux/macOS
  cp -r skills/* ~/.config/opencode/skills/
  # Windows (PowerShell)
  Copy-Item -Recurse skills/* "$env:USERPROFILE\.config\opencode\skills\"
  ```

### 2. Claude Code (Anthropic)
* **全局使用**：复制到 Claude 全局技能目录：
  ```bash
  # Linux/macOS
  cp -r skills/* ~/.claude/skills/
  # Windows (PowerShell)
  Copy-Item -Recurse skills/* "$env:USERPROFILE\.claude\skills\"
  ```
* **工作区使用**：复制到当前工程根目录下的 `.claude/skills/` 中。

### 3. Google Antigravity
* **全局使用**：
  ```powershell
  Copy-Item -Recurse skills/* "$env:USERPROFILE\.gemini\config\skills\"
  ```
* **工作区使用**：克隆或复制到当前工程根目录的 `.agents/skills/` 目录下。

### 4. Cline / Roo Code / Cursor / Windsurf
现代自主智能体具备自主检索文件能力：
* 将本仓库 clone 到您的工程工作区或子目录；
* 在您的项目说明（如 `.clinerules`、`.cursorrules` 或 `.windsurfrules`）中添加一行提示：
  > "For AVEVA Marine & Plant secondary development (.NET / PML), refer to `skills/aveva-dotnet/SKILL.md` and `skills/aveva-pml/SKILL.md`."

### 5. Web AI 知识库 (Claude Projects, Custom GPTs, Dify 等)
* 将各 Skill 根目录下的 `SKILL.md`、`cheatsheet.md` 和 `patterns.md` 作为知识库附件直接上传，即可赋予对话模型扎实的领域专有认知。

---

## 💡 提问与触发示例 (Example Prompts)

引入技能后，在日常对话中向 AI 提问即可自动激活：

* **.NET / CAF 场景**:
  > *"我想开发一个 AVEVA Marine 的吸附窗体插件，如何使用 CAF 的 WindowManager 和 CommandManager？请给出 C# 示例代码。"*
* **数据库操作场景**:
  > *"如何在 C# 中安全地读取和修改三维管道弯头的属性？需要注意哪些 STA 线程和事务控制事项？"*
* **PML 表单与界面场景**:
  > *"写一个 PML 2 表单，包含一个下拉选择框（SELECTOR）和一个用于展示构件属性的表格控件，要求带回调处理。"*
* **EDG 三维交互场景**:
  > *"如何在 PDMS/E3D 中使用 Event Driven Graphics (EDG) 实现让用户在三维视图中拾取设备并返回 DBREF？"*
* **排错与规范检查**:
  > *"检查这段 PML 代码中是否存在循环语法或编码问题，并给出符合 AVEVA 标准的重构方案。"*

---

## 📂 仓库目录结构 (Directory Structure)

```text
aveva-dev-skills/
├── .gitignore
├── LICENSE                         # MIT 许可证与商标免责声明
├── README.md                       # 项目说明文档
└── skills/                         # 遵循 agentskills.io 规范的技能集
    ├── aveva-dotnet/               # .NET / CAF / MarAPI / Planar 技能
    │   ├── SKILL.md                # 技能主入口与核心心智模型
    │   ├── cheatsheet.md           # 架构决策树与排错 Heuristics
    │   ├── glossary.md             # 核心类库与术语速查字典
    │   ├── patterns.md             # 生产级架构模式与避坑指南
    │   ├── chapters/               # 10 大子系统深入指南 (ch01 - ch10)
    │   └── references/             # 4 大全量 API 参考手册
    └── aveva-pml/                  # PML 1/2 / GUI / EDG / Drafting 技能
        ├── SKILL.md                # 技能主入口与双架构法则
        ├── cheatsheet.md           # 诊断与避坑速查表
        ├── glossary.md             # 术语与系统对象字典
        ├── patterns.md             # 8 大生产级 PML 架构模式
        └── chapters/               # 20 个完整系统章节 (ch01 - ch20)
```

---

## 📄 许可证与免责声明 (License & Disclaimer)

* 本项目基于 [MIT License](LICENSE) 开源。
* **第三方知识产权免责声明**：  
  * AVEVA, PDMS, Everything3D, E3D, Tribon, DABACON, PML 为 AVEVA Solutions Limited 或 Schneider Electric 的注册商标或商标。
  * 本知识库由独立二次开发工程师总结维护，旨在促进行业技术交流与 AI 辅助工程编程，**与 AVEVA Solutions Limited 或 Schneider Electric 官方无任何隶属、赞助或背书关系**。
