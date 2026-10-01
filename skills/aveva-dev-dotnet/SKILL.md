---
name: aveva-dev-dotnet
description: "Comprehensive developer knowledge base for AVEVA PDMS and AVEVA Marine .NET secondary development (part of the aveva-dev-skills suite). Covers Common Application Framework (CAF), Dabacon DbElement access, PMLNet interop, MarAPI, and Planar structural modeling."
metadata:
  suite: aveva-dev-skills
  version: "1.0.0"
---

<!-- argument-hint: [topic, class name, or chapter number] -->

# AVEVA PDMS & Marine .NET Customisation & Secondary Development Guide

**Author**: AVEVA Solutions Limited | **Pages**: ~1,822 | **Chapters**: 10 | **Generated**: 2026-09-29

## How to Use This Skill

- **Without arguments** — loads core architectural frameworks and decision guidelines for AVEVA Marine/Plant .NET development.
- **With a topic** — ask about `CAF`, `DbElement`, `PMLNet`, `GridControl`, `MarDataBase`, `Vitesse`, `Welding`, or `Planar`, and the skill will retrieve the relevant chapter.
- **With a chapter** — ask for `ch01` through `ch10` to dive into a specific subsystem.
- **Browse** — ask "what chapters do you have?" to inspect the complete chapter index.

When you ask about a topic not fully covered in Core Frameworks below, the relevant chapter file from `chapters/` will be read on demand.

---

## Core Frameworks & Mental Models

### 1. 通用应用程序框架与插件生命周期 (Common Application Framework - CAF)
AVEVA 现代界面与业务插件采用基于服务总线的微内核架构：
- **入口契约**: 必须实现 `Aveva.ApplicationFramework.IAddin`（定义 `Name`, `Description`, `Start`, `Stop`）。
- **服务检索**: 在 `Start(ServiceManager serviceManager)` 中统一向宿主索取核心服务：
  - `WindowManager`: 负责通过 `CreateDockedWindow()` 创建和管理吸附面板，设置 `SaveLayout = true` 维持用户停靠偏好。
  - `CommandManager`: 注册继承自 `Command` 的业务动作。命令持有全局唯一 `Key`、状态（`Checked`/`Enabled`）及 `Execute()`。
- **界面与逻辑解耦**: 按钮与菜单排布在 XML 格式的 `.uic` 文件中静态声明，通过 `Key` 绑定到 C# Command，严禁在窗体构造中硬编码菜单。
- **模块加载配置**: 模块启动时扫描 `%AVEVA_DESIGN_USER%\<Module>Addins.xml` 完成反射加载。

### 2. Dabacon 面向对象数据库操作体系 (Dabacon DbElement Paradigm)
AVEVA 所有工程模型数据均存储于分层式的 Dabacon 专有数据库中：
- **实体封装**: `Aveva.Core.Database.DbElement` 是操作图元的统一对象句柄，具备“值语义”（相同图元指针即判定相等）。
- **防卫式编程法则**: 访问任何实体首步必须检查 `if (!element.IsValid() || element.IsNull())`；写入前必须检查 `element.Database.Writeable`，并使用 `try...catch (PdmsException)` 进行事务防卫。
- **静态常量优化**: 实体类型与属性优先使用 `DbElementTypeInstance`（如 `EQUIPMENT`, `ZONE`）和 `DbAttributeInstance`（如 `NAME`, `DESC`, `POSX`），杜绝字符串反射开销。
- **单线程调度约束**: Dabacon 内核为非线程安全的 STA 架构，严禁在后台线程直接调用 `DbElement` 的读写 API。

### 3. PMLNet 双向跨语言互操作契约 (PMLNet Bridge Contract)
连接老旧 PML 脚本资产与现代 .NET 托管生态的核心桥梁：
- **可调用类五大铁律**:
  1. 程序集置于 `%PDMSEXE%` 目录或通过配置加载。
  2. 类和方法显式标记 `[PMLNetCallable()]` 特性。
  3. 提供标记为 `[PMLNetCallable()]` 的公共无参构造函数。
  4. 必须实现 `[PMLNetCallable()] public void Assign(MyClass that)` 浅拷贝方法。
  5. 只能使用基础兼容数据类型（数值严格使用 `double`，严禁 `int`/`float`）。
- **反向通知总线**: C# 无法直接调用 PML 方法，必须通过 `event PMLNetDelegate.PMLNetEventHandler` 发送 `ArrayList`，由 PML 使用 `!obj.addeventhandler()` 接收。
- **窗体嵌套**: PML 表单中使用 `container .name pmlnetcontrol ...` 接收 `!netCtrl.handle()` 实现 WinForms/WPF 控件的无缝内嵌。

### 4. Marine 原生实体与非托管资源管控 (Marine Native Objects & IDisposable)
`marAPI.dll` 是造船工艺专用的面向对象中介层：
- **确定性释放**: 所有以 `Mar` 开头的类型（`MarObject`, `MarDataBase`, `MarUtil`, `MarWeld`）均实现了 `IDisposable`，内部包裹非托管 C++ 句柄；必须使用 `using` 代码块或严格在 `finally` 中调用 `.Dispose()`。
- **查询与命令分工**: 使用 `MarDataBase.ObjectListGet` 结合 `MarObjectCriteria` 执行条件化构件检索；使用 `MarUtil.AddCommand()` 执行宿主底层宏命令注入。
- **三元语言融合 (Vitesse)**: 利用 `MarPythonEngine` 在进程内直接执行 Python 脚本，并配合 `MarPythonObjectPML` 打通 Python 与 PML。

### 5. 平面分段与工艺特征声明式建模 (Planar Statements Framework)
造船平直结构（甲板、舱壁、强框架）遵循参数化数学语句体系：
- **板架画布**: `PanelStatement` 是平面构件的顶级容器，结合 `PlaneStatement`（全船参考基准面）与 `BoundaryStatement`（外围轮廓修剪）定义基本骨架。
- **双向互转**: 支持通过 `new PanelStatement(dbElement)` 将现有 3D 数据库图元一键逆向提取为结构化语句，并可通过 `.Statement` 属性获取标准语法字符串。
- **骨架网络**: 母板（`PlateStatement`）上敷设型材筋条（`StiffenerStatement`，含端切连接 `StiffenerEndConnection`）、连接肘板（`BracketStatement`）与自由边面板（`FlangeStatement`）。
- **生产制造特征**: 涵盖开孔（`HoleStatement`）、流水/透气切口（`NotchStatement`）、板缝（`SeamStatement`）、余量（`ExcessStatement`）与焊接收缩补偿（`ShrinkageStatement`），全面衔接数控下料与现场建造。

---

## Chapter Index

| 章节编号 | 章节标题 | 核心框架与涉及类型 |
|---|---|---|
| [ch01](chapters/ch01-architecture-and-caf-addin.md) | AVEVA .NET 架构与 CAF Addin 框架 | `IAddin`, `ServiceManager`, `WindowManager`, `Command`, `DockedWindow`, UIC |
| [ch02](chapters/ch02-database-access-and-elements.md) | Dabacon 数据库操作、三维空间几何与 DbEvents | `DbElement`, `Position`, `Orientation`, `DbEvents`, `PseudoAttribute`, `DbUnits` |
| [ch03](chapters/ch03-pmlnet-interop-and-controls.md) | PMLNet 跨语言互操作与控件宿主 | `PMLNetCallable`, `Assign()`, `PMLNetEventHandler`, `PMLNetException`, `pmlnetcontrol` |
| [ch04](chapters/ch04-ui-controls-grid-mydata.md) | AVEVA C# Grid 控件、My Data 与文件浏览器 | `GridControl` 完整行/列/单元格 API, 输入掩码规则, `MyData`, `OpenFileDialog` |
| [ch05](chapters/ch05-marine-utility-and-objects.md) | AVEVA Marine Utility API 与领域对象 | `MarObject`, `MarUtil`, `MarDataBase`, `MarObjectCriteria`, `IDisposable` |
| [ch06](chapters/ch06-marine-ui-and-vitesse.md) | Marine UI 自动化与 Vitesse Python 集成 | `MarUi.AnswerReq`, `ChoiceSelect`, `MarPythonEngine`, `MarPythonObjectPML` |
| [ch07](chapters/ch07-marine-welding-and-production.md) | 造船焊接与生产制造数据管道 | `MarWeld`, `MarWeldedJoint`, `MarWeldTable`, `MarPinProfiles`, `GenerateSketch` |
| [ch08](chapters/ch08-planar-fundamentals-and-panels.md) | 平面建模基础与 PanelStatement 结构 | `PanelStatement`, `PlaneStatement`, `BoundaryStatement`, `ComponentHelper` |
| [ch09](chapters/ch09-planar-plates-stiffeners-brackets.md) | 结构板件、型材加筋与连接肘板 | `PlateStatement`, `StiffenerStatement`, `StiffenerEndConnection`, `BracketStatement` |
| [ch10](chapters/ch10-planar-features-cuts-holes-welds.md) | 制造特征、补强板、波形折边与 PML 包装层 | `HoleStatement`, `CompensationStatement`, `SwageStatement`, `HNCStatement`, `Clip`, `ExcessStatement` |

---

## Topic Index

- **Addin 生命周期与微内核服务定位** → ch01
- **命令与 UIC 菜单集成 (Button, StateButton, PopupMenu)** → ch01
- **插件性能分析与 CPU Profiling (PdmsTrace & TraceEntry)** → ch01
- **UIC 生产部署与环境重定向 (CAF_UIC_PATH & $1.uic)** → ch01
- **Dabacon 数据库与 DbElement 导航** → ch02
- **Dabacon 底层索引表与 Token 释放规程 (NameTable & RefTable)** → ch02 & core-api-reference
- **物理 DB/MDB 抽取与会话伪属性矩阵 (OKDROP, CLAIM, EXTFAM)** → ch02 & core-api-reference
- **层级快速迭代与树形过滤 (DBElementCollection & Filters)** → ch02
- **动态规则与表达式评估 (DbExpression & Rules)** → ch02
- **跨会话历史版本比对与差异追溯 (Session History)** → ch02
- **三维绝对坐标与空间姿态 (Position & Orientation)** → ch02
- **单位制、物理量纲与自适应计算 (DbDouble & PdmsException)** → ch02
- **数据库实时变更与整库生命周期监听 (DbEvents)** → ch02 & core-api-reference
- **自定义伪属性注册机制 (PseudoAttribute)** → ch02
- **属性读写与事务管理** → ch02
- **PMLNet 规范与类型映射** → ch03
- **C# 与 PML 事件双向通信** → ch03
- **原生标准文件选择对话框 (PMLFileBrowser)** → ch03
- **双轨命名空间架构设计 (Planar vs Planar.PML)** → ch03 & planar-api-reference
- **PMLNet 调试追踪与日志配置 (PMLNetTraceSwitch)** → ch03
- **AVEVA 官方表格控件 (GridControl 50+ 全量方法、行/列/单元格控制与掩码)** → ch04 & core-api-reference
- **表格数据库就地同步与图元图标 (DoDabaconCellUpdate & setNameColumnImage)** → ch04
- **共享/图形/工具周边程序集 (Shared, Graphics, Utilities)** → core-api-reference
- **官方 SDK 示例工程索引 (Samples.zip 5 大工程架构)** → core-api-reference
- **我的数据 (My Data) 会话收藏夹** → ch04
- **Marine 工具集与非托管资源释放** → ch05
- **Marine 对象准则查询 (MarDataBase)** → ch05
- **PMLNet 跨语言 Double/Int32 双重载机制与专用字典 (StringStringDictionary)** → ch05 & marine-api-reference
- **原生提示弹窗与视口控制 (MarUi)** → ch06
- **Vitesse Python 脚本引擎集成** → ch06
- **造船焊缝提取与工艺追溯** → ch07
- **曲面外板胎架 (Pin Jig) 与加工草图** → ch07
- **平面分段建模与逆向解析 (PanelStatement)** → ch08
- **板架层级逆向提取助手 (ComponentHelper)** → ch08 & planar-api-reference
- **Statement 底层宏语法生成标记映射 (Schema Syntax Mapping)** → planar-api-reference
- **板架外轮廓与基准面定义** → ch08
- **型材筋条排布与端部型切** → ch09
- **节点连接肘板与面板** → ch09
- **结构开孔、流水孔与管穿孔** → ch10
- **开孔补强板与局部加强 (CompensationStatement)** → ch10
- **波形舱壁压折成形 (SwageStatement)** → ch10
- **复合孔切卡马与穿越件 (HNCStatement & Clip & TAPStatement)** → ch10
- **板缝切分、加放余量与焊接收缩** → ch10
- **Planar 的 PML 包装器与枚举方法工厂** → ch10 & planar-enums-reference

---

## Supporting Files

- [glossary.md](glossary.md) — 核心专业术语、接口与核心类速查字典
- [patterns.md](patterns.md) — 高频架构模式、工程套路与避坑指南
- [cheatsheet.md](cheatsheet.md) — 快速决策树、故障诊断 Heuristics 与规则矩阵
- [references/core-api-reference.md](references/core-api-reference.md) — AVEVA Core, CAF (含 PdmsTrace/CPU Profiling/CAF_UIC_PATH), Database (含 Dabacon Tables/Token管理/DB及抽取伪属性/DbEvents/DBElementCollection/Filters/DbExpression/会话比对), Geometry, Units (DbDouble/量纲计算), GridControl (含 50+ 全量方法/自动同步), PMLFileBrowser, 共享/图形组件 & 官方 SDK 示例手册 (`NCUG.pdf`)
- [references/marine-api-reference.md](references/marine-api-reference.md) — `marAPI.dll` 完整 36 个类库、构造函数（Constructors）、运算符重载（Operators）、属性（Properties）、方法（Methods）全量速查手册，含 PMLNet Double/Int32 双重载规范与专用跨语言字典 (`NETmarAPI.pdf`)
- [references/planar-api-reference.md](references/planar-api-reference.md) — `Aveva.Marine.Planar.dll` 全部 63 个 Statement 语句类（含 4 重构造函数）、PML 包装类、ComponentHelper 与 Statement 语法标记映射详细速查 (`netaveva.marine.planarapi.pdf`)
- [references/planar-enums-reference.md](references/planar-enums-reference.md) — Planar 全部 29 个 PMLNet 枚举分类与无参方法工厂类完整速查手册 (`netaveva.marine.planarapi.pdf`)

---

## Scope & Limits

本 Skill 完整覆盖了 AVEVA Plant / Marine 官方文档中的 .NET 二次开发指南（NCUG.pdf）、Marine 核心 API 参考（NETmarAPI.pdf）及 Planar 平面结构建模 API（netaveva.marine.planarapi.pdf）。在具体工程中编写实现代码时，需结合目标项目安装的具体 AVEVA 版本（如 Marine 12.1、PDMS 12.0/12.1）及其引用的程序集版本；若涉及曲面外板高级成形算法或特定的第三方数据库，请辅以对应专项指南。

