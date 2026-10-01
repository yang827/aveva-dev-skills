# Chapter 1: AVEVA .NET Customisation Architecture & CAF Addin Framework

## Core Idea
AVEVA .NET 二次开发采用通用应用程序框架（Common Application Framework, CAF），通过实现 `IAddin` 接口并注册到模块配置文件（`*Addins.xml`），开发者可以在同一进程内与宿主程序共享数据库会话，利用 `WindowManager`、`CommandManager` 与 UIC 机制无缝扩充 AVEVA Plant / Marine 的用户界面与业务逻辑。

## Frameworks Introduced
- **CAF 插件生命周期模型 (CAF Addin Lifecycle Framework)**:
  - When to use: 任何为 AVEVA Marine/Plant（如 Design、Draft、Outfitting）开发独立功能模块、工具窗体或菜单命令时。
  - How:
    1. 引用 `Aveva.ApplicationFramework.dll` 与 `Aveva.ApplicationFramework.Presentation.dll`。
    2. 实现 `Aveva.ApplicationFramework.IAddin` 接口（`Name`, `Description`, `Start(ServiceManager)`, `Stop()`）。
    3. 在 `Start` 中通过 `ServiceManager.GetService(typeof(...))` 获取 `WindowManager` 与 `CommandManager`。
    4. 注册命令与创建停靠窗口（`DockedWindow`）。
    5. 在 `Stop` 中释放非托管资源与解绑事件。
- **命令与界面分离模式 (Command-UI Decoupling Pattern)**:
  - When to use: 管理界面控件（工具栏按钮、菜单项）与执行逻辑的解耦绑定。
  - How: 继承 `Aveva.ApplicationFramework.Presentation.Command`，指定全局唯一 `Key`，重写 `Execute()`，通过 UIC 界面配置文件将该 `Key` 绑定到界面工具（Tool）。

## Key Concepts
- **CAF (Common Application Framework)**: AVEVA 的 .NET 核心应用程序框架，提供服务发现、插件加载、窗口停靠与菜单命令管理。
- **ServiceManager**:  central service locator，负责注册并向 Addin 提供核心服务（如 WindowManager、CommandManager、SettingsManager）。
- **IAddin**: 所有 CAF Addin 的入口接口，定义插件启动和停止生命周期方法。
- **WindowManager**: 负责管理宿主程序中的浮动窗体（FloatingWindow）和停靠窗体（DockedWindow）。
- **DockedWindow**: 宿主 MDI 架构下的停靠面板，可吸附在左、右、顶、底或作为标签页停靠。
- **Command**: 抽象命令基类，包含 `Key`、`Checked`、`Enabled` 状态及 `Execute()` 动作。
- **UIC 文件 (User Interface Customisation, .uic)**: 基于 XML 的界面定制文件，定义命令栏（CommandBar）、菜单与工具按钮的层次结构。
- **Addins.xml**: 模块启动时扫描的 XML 配置文件，指定需加载的 Addin 程序集路径与全类名。

## Mental Models
- **Think of ServiceManager as a Service Bus**: 插件不要自己创建核心基础设施，而是通过 `ServiceManager.GetService` 索取宿主提供的服务。
- **Think of Command as State + Action**: 命令是单一真理来源（Single Source of Truth），界面的按钮只是命令状态（Checked/Enabled）与动作（Execute）的投影。
- **Use UIC for Layout, C# for Logic**: 界面布局在 UIC 文件中声明，交互与业务在 C# Command 中实现，切勿在窗体构造中硬编码菜单栏。

## Anti-patterns
- **跨线程直接操作 AVEVA 数据库**: AVEVA 内核是单线程单元模型，在后台工作线程（如 `Task.Run` 或 `Thread`）中直接调用 `DbElement` 会导致 Dabacon 数据库锁死或崩溃，必须通过 UI 调度器派发到主线程。
- **在 IAddin.Start 中执行重型阻塞任务**: `Start` 方法在宿主模块启动的主事件循环中同步执行，若执行耗时查询会导致启动卡死；应将重型加载延后至窗体首次打开或异步调度。
- **忽略 Stop() 中的事件注销**: 未在 `Stop` 中解绑事件委托或注销命令，会导致模块切换或二次加载时产生内存泄漏和重复回调。

## Code Examples
```csharp
using System;
using Aveva.ApplicationFramework;
using Aveva.ApplicationFramework.Presentation;

namespace Aveva.CustomAddins
{
    public class MarineToolsAddin : IAddin
    {
        private WindowManager _windowManager;
        private CommandManager _commandManager;
        private DockedWindow _dockedWindow;

        public string Name => "MarineToolsAddin";
        public string Description => "Custom tools and automation addin for AVEVA Marine";

        public void Start(ServiceManager serviceManager)
        {
            // 1. 获取核心管理服务
            _windowManager = (WindowManager)serviceManager.GetService(typeof(WindowManager));
            _commandManager = (CommandManager)serviceManager.GetService(typeof(CommandManager));

            // 2. 创建并配置用户自定义控件
            var userControl = new MyCustomMarinePanel();
            _dockedWindow = _windowManager.CreateDockedWindow(
                "Aveva.MarineTools.Window",
                "Marine Automation Tools",
                userControl,
                DockedPosition.Right
            );
            _dockedWindow.SaveLayout = true;

            // 3. 注册命令并绑定窗口控制
            var toggleCmd = new ToggleToolsWindowCommand(_dockedWindow);
            _commandManager.Commands.Add(toggleCmd);
        }

        public void Stop()
        {
            // 4. 清理资源与引用
            if (_dockedWindow != null)
            {
                _dockedWindow.Dispose();
                _dockedWindow = null;
            }
        }
    }

    public class ToggleToolsWindowCommand : Command
    {
        private readonly DockedWindow _window;

        public ToggleToolsWindowCommand(DockedWindow window)
        {
            Key = "Aveva.MarineTools.ToggleWindowCommand";
            _window = window;
        }

        public override void Execute()
        {
            if (_window.Visible)
            {
                _window.Hide();
                Checked = false;
            }
            else
            {
                _window.Show();
                Checked = true;
            }
        }
    }
}
```
- **What it demonstrates**: 标准 CAF Addin 实现，展示服务注入、DockedWindow 创建及 Command 双向状态绑定。

## Reference Tables

| 核心接口 / 类 | 所在程序集 | 核心职责 |
|---|---|---|
| `IAddin` | `Aveva.ApplicationFramework.dll` | 插件入口生命周期定义 (`Name`, `Description`, `Start`, `Stop`) |
| `ServiceManager` | `Aveva.ApplicationFramework.dll` | 基础服务注册中心，提供 `GetService(Type)` |
| `WindowManager` | `Aveva.ApplicationFramework.Presentation.dll` | 窗体管理器，提供 `CreateDockedWindow`, `CreateFloatingWindow` |
| `CommandManager` | `Aveva.ApplicationFramework.Presentation.dll` | 命令注册表管理器，维护 `Commands` 集合 |
| `Command` | `Aveva.ApplicationFramework.Presentation.dll` | 抽象命令基类，包含 `Key`, `Checked`, `Enabled`, `Execute()` |
| `DockedWindow` | `Aveva.ApplicationFramework.Presentation.dll` | 停靠窗口封装，提供 `Show()`, `Hide()`, `DockedPosition` |

### 模块 Addin 配置文件路径表 (`%AVEVA_DESIGN_USER%` 或模块根目录)
| 模块名称 | 默认配置文件名 |
|---|---|
| Design | `DesignAddins.xml` |
| Marine Outfitting | `MarineOutfittingAddins.xml` |
| Draft | `DraftAddins.xml` |

## Worked Example: 完整加载与 UIC 关联步骤
1. **编译程序集**: 将包含 `MarineToolsAddin` 的 C# 项目编译为 `MarineToolsAddin.dll`，拷贝到 `%PDMSEXE%` 或自定义插件目录。
2. **编辑 `DesignAddins.xml`**:
   ```xml
   <AddinList>
     <Addin>
       <Name>MarineToolsAddin</Name>
       <Assembly>MarineToolsAddin.dll</Assembly>
       <Class>Aveva.CustomAddins.MarineToolsAddin</Class>
     </Addin>
   </AddinList>
   ```
3. **编辑 UIC 界面配置文件 (`Custom.uic`)**:
   在 `<Tools>` 节点中声明所需控件工具（支持通过 Property Grid 进行视觉定制）：
   ```xml
   <Tools>
     <!-- 1. 普通操作按钮 -->
     <ButtonTool Key="Aveva.MarineTools.RunReport" Caption="Run Report" Tooltip="Generate hull report" Image="Report_16x16" />
     
     <!-- 2. 状态切换按钮 (双向同步 Command.Checked) -->
     <StateButtonTool Key="Aveva.MarineTools.ToggleWindowCommand" Caption="Marine Tools" Tooltip="Show/Hide Tools Window" BeginGroup="true" />
     
     <!-- 3. 下拉多级子菜单 -->
     <PopupMenuTool Key="Aveva.MarineTools.WeldMenu" Caption="Welding Utilities">
       <Tools>
         <ButtonTool Key="Aveva.MarineTools.CalculateWeld" Caption="Calculate Welds" />
         <ButtonTool Key="Aveva.MarineTools.ExportWeld" Caption="Export Weld Table" />
       </Tools>
     </PopupMenuTool>
     
     <!-- 4. 下拉组合框与单行输入 -->
     <ComboBoxTool Key="Aveva.MarineTools.BlockSelector" Caption="Current Block" />
     <TextBoxTool Key="Aveva.MarineTools.SearchKeyword" Caption="Search" />
   </Tools>
   ```
   并在目标菜单栏（`<MenuBar>`）或工具栏（`<ToolBar>`）中引用对应的 `Key`。
4. **启动 Design 模块**: 宿主解析 XML，实例化 Addin，执行 `Start()`，工具栏显示 "Marine Tools" 图标，点击即可呼出停靠窗体。

---

## 5. 插件性能诊断、CPU Profiling 与 UIC 生产部署

### 5.1 底层诊断与 CPU 耗时追踪 (`PdmsTrace` & `TraceEntry`)
在大型工程中，Addin 启动或高频事件处理可能导致界面卡顿，官方提供了微秒级诊断工具：
```csharp
using Aveva.ApplicationFramework.Diagnostics;

// 1. 设置跟踪标志位
PdmsTrace.SetTraceFlag((TraceNumber)101, 1);

// 2. 使用 using 作用域自动记录耗时
using (TraceEntry tr = TraceEntry.Enter("InitAddinLayout", (TraceNumber)101))
{
    // 初始化窗体或拉取数据...
}

// 3. 宿主 CPU Profiling 测速
PdmsTrace.StartCPUTrace();
// 待测代码...
PdmsTrace.StopCPUTrace(true); // 输出 CPU 时钟周期与耗时报表
```

### 5.2 企业级 UIC 部署与环境重定向 (`CAF_UIC_PATH` & `$1.uic`)
在企业网络中，主程序目录通常被锁定为只读权限，不能直接修改安装目录下的 Customisation XML：
1. **环境变量 `CAF_UIC_PATH`**: 将其指向本地开发目录或网络集中共享目录，宿主将优先从该路径检索并加载 UIC。
2. **项目专属配置 `$1.uic`**: 在 UICCustomizationFiles 节点中配置 `Path="$1.uic"`，启动时 `$1` 会自动解析替换为当前进入的项目代码（如 `SAM.uic`）。
3. **运行时动态加载 UIC**:
   ```csharp
   CommandBarManager cmdBarMgr = (CommandBarManager)serviceManager.GetService(typeof(CommandBarManager));
   cmdBarMgr.AddUICustomizationFile("DepartmentTools.uic", "DepartmentTools");
   ```

## Key Takeaways
1. 始终使用 `IAddin` + `ServiceManager` 作为 .NET 插件主入口，不要使用非托管钩子注入。
2. 每一个窗体交互逻辑必须封装为继承自 `Command` 的子类，并通过唯一 `Key` 与 UIC 工具映射。
3. 停靠窗口使用 `WindowManager.CreateDockedWindow`，并设置 `SaveLayout = true` 以便保留用户窗体停靠习惯。
4. 严格遵守单线程 UI 约束，任何涉及 AVEVA 数据模型（Dabacon）的操作必须在主线程中进行。
5. 善用 `PdmsTrace` 进行 CPU 性能剖析，生产部署时利用 `CAF_UIC_PATH` 环境变量解耦只读安装目录。

## Connects To
- **Ch 02**: [ch02-database-access-and-elements.md](ch02-database-access-and-elements.md)（在 Addin 中使用 `Aveva.Core.Database` 存取模型数据）
- **Ch 03**: [ch03-pmlnet-interop-and-controls.md](ch03-pmlnet-interop-and-controls.md)（与传统 PML 界面体系交互混合编程）
- **Ch 04**: [ch04-ui-controls-grid-mydata.md](ch04-ui-controls-grid-mydata.md)（在 Addin 窗体中使用 AVEVA 官方 C# Grid Control）
