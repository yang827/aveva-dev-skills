# Chapter 3: PMLNet Interoperability & Hosting .NET Controls

## Core Idea
PMLNet 是连接 AVEVA 传统脚本语言 PML 与现代 .NET 托管代码的高性能双向桥梁；通过遵循 `PMLNetCallable` 契约（包括无参构造、`Assign` 方法及类型映射规范），C# 类可直接被 PML 当作原生对象实例化调用，同时支持将 .NET WinForms 控件宿主到 PML 表单中实现富交互。

## Frameworks Introduced
- **PMLNetCallable 规范架构 (PMLNetCallable Contract Framework)**:
  - When to use: 任何需要在现有 PML 宏、表单或函数中调用 C# 业务算法、数据库操作或第三方类库时。
  - How:
    1. 引入 `Aveva.Core.PMLNet.dll`。
    2. 类与被调用方法均标记 `[PMLNetCallable()]` 特性。
    3. 提供标记为 `[PMLNetCallable()]` 的公共无参构造函数。
    4. **必须**实现浅拷贝签名方法：`[PMLNetCallable()] public void Assign(MyClass that)`。
    5. 命名须忽略大小写差异（PML 对大小写不敏感）。
    6. 数值统一使用 `double`（PML 内部无整型，所有数字均为实数）。
- **PMLNet 事件委托总线 (PMLNet Event Callback Bus)**:
  - When to use: C# 逻辑执行完毕或触发异步动作时，反向通知 PML 表单更新或执行特定宏。
  - How:
    1. 在 C# 中声明事件：`public event PMLNetDelegate.PMLNetEventHandler MyEvent;`。
    2. 通过 `ArrayList` 打包参数并触发事件。
    3. 在 PML 中使用 `!obj.addeventhandler('myevent', !this, 'myCallback')` 绑定。

## Key Concepts
- **PMLNetEngine**: 宿主内部负责解析 .NET 程序集元数据并自动生成 PML 运行时代理对象（PML Proxy）的核心引擎。
- **PMLNetCallableAttribute**: 声明类或方法可被 PMLNet 引擎暴露的核心特性。
- **Assign() 方法**: PML 在对象赋值（`!a = !b`）时调用的深/浅复制钩子，缺少此方法会导致类型加载直接被拒绝。
- **PMLNetException**: 供 .NET 代码向 PML 抛出的专用异常类，格式为 `(1000, code, message)`，在 PML 中可用 `handle(1000, code)` 捕获。
- **PmlNetControl 容器小部件 (Container Gadget)**: PML 表单中专门用于嵌入 Windows Forms 控件句柄的容器控件。
- **Handle**: .NET 控件句柄，PML 表单通过 `container.control = !netCtrl.handle()` 实现控件嵌入。

## Mental Models
- **Think of C# as a PML Extension Engine**: PML 负责快速组装界面与轻量业务流，将密集计算、外部系统对接与现代化 UI 委派给 C#。
- **Strict Contract Enforcement**: PMLNetEngine 在加载程序集时极度严谨，任何一处不符合规则（缺少 `Assign`、参数包含不支持类型、存在重载大小写冲突）都会静默忽略该类并导致 PML 报错找不到对象定义。

## Anti-patterns
- **在可调用方法中使用 `int`、`float` 或复杂泛型**: PML 只能识别 `double`、`string`、`bool`、`Hashtable` 或数组；使用 `int` 会导致方法在 PML 层面不可见。
- **忘记编写 Assign(that) 方法**: 最常见的开发错误；PML 在编译期必须保证对象可赋值，无 `Assign` 则整个类被排除。
- **在 .NET 内部直接调用 PML 函数**: 架构上不允许 C# 直接调用 PML 对象的方法；只允许通过 `PMLNetDelegate.PMLNetEventHandler` 触发事件由 PML 回调处理。

## Code Examples

### 1. C# 业务服务类与事件定义
```csharp
using System;
using System.Collections;
using Aveva.Core.PMLNet;
using Aveva.Core.Database;

namespace Aveva.CustomMarine.PmlBridge
{
    [PMLNetCallable()]
    public class MarineModelService
    {
        // 声明 PMLNet 事件
        [PMLNetCallable()]
        public event PMLNetDelegate.PMLNetEventHandler CalculationCompleted;

        [PMLNetCallable()]
        public MarineModelService()
        {
        }

        // 必须实现 Assign 方法
        [PMLNetCallable()]
        public void Assign(MarineModelService that)
        {
            // 复制必要状态
        }

        // 接收 double 参数并执行计算
        [PMLNetCallable()]
        public double ComputeTotalWeight(string elementName, double factor)
        {
            DbElement element = DbElement.GetElement(elementName);
            if (!element.IsValid())
            {
                // 抛出 PML 可捕获的异常
                throw new PMLNetException(1000, 101, $"Invalid element: {elementName}");
            }

            double baseWeight = element.GetDouble(DbAttributeInstance.CMPW);
            double total = baseWeight * factor;

            // 触发事件通知 PML
            if (CalculationCompleted != null)
            {
                ArrayList args = new ArrayList();
                args.Add(elementName);
                args.Add(total);
                CalculationCompleted(args);
            }

            return total;
        }
    }
}
```

### 2. PML 中调用该对象与处理事件
```pml
-- 导入命名空间并创建对象
using namespace 'Aveva.CustomMarine.PmlBridge'
!service = object MARINEMODELSERVICE()

-- 订阅事件回调
!callbackObj = object MYPMLCALLBACK()
!handle = !service.addeventhandler('calculationcompleted', !callbackObj, 'onFinished')

-- 调用方法（含异常防护）
handle(1000, 101)
  $P Element not found or invalid!
elsehandle
  !weight = !service.computetotalweight('/BLOCK-01', 1.05)
  $P Total computed weight: $!weight
endhandle
```

### 3. PML 表单中宿主 WinForms 自定义控件
```pml
-- PML 表单定义
setup form !!marineControlDemo dialog
  title 'Marine .NET WinForm Host'
  -- 定义 PmlNetControl 容器
  container .netContainer pmlnetcontrol 'host' dock fill width 40 height 25
exit

-- 表单构造回调
define method .marineControlDemo()
  using namespace 'Aveva.CustomMarine.UI'
  -- 实例化 .NET 控件
  !this.gridControl = object CustomWinFormsGrid()
  -- 将控件句柄塞入容器
  !this.netContainer.control = !this.gridControl.handle()
endmethod
```

## Reference Tables

### PML 与 C# 数据类型转换映射表
| PML 数据类型 | C# 方法参数 / 返回类型 | 注意事项 |
|---|---|---|
| `REAL` | `double` | C# 严禁使用 `int`, `float` 作为公开签名 |
| `STRING` | `string` | 字符编码由宿主自动对齐 UTF-8 / ANSI |
| `BOOLEAN` | `bool` | 直接对应布尔类型 |
| `ARRAY` | `ArrayList` 或 `Array` | 包含简单类型的一维集合 |
| `OBJECT` | 实现了 `PMLNetCallable` 的自定义类 | 可以在 PML 间作为对象指针流转 |
| `DBREF` | `DbElement` 或 `string`（名称） | 推荐直接以字符串形式传递元素名或使用包装类 |

## Worked Example: 完整注册与调用流程
1. **程序集配置**: 将编译好的 DLL 放入 `%PDMSEXE%` 目录。
2. **启用诊断跟踪**: 在 `%PDMSEXE%\Design.exe.config`（或对应程序配置）中配置 `PMLNetTraceSwitch` 为 4：
   ```xml
   <system.diagnostics>
     <switches>
       <add name="PMLNetTraceSwitch" value="4" />
     </switches>
   </system.diagnostics>
   ```
   开启后将在控制台与日志中输出所有类反射加载日志，极大方便排查 `(46,87) Object definition for XXX could not be found` 错误。
3. **PML 验证测试**: 在命令行控制台输入：
   ```pml
   using namespace 'Aveva.CustomMarine.PmlBridge'
   !t = object MARINEMODELSERVICE()
   $P Success: $!t.string()
   ```
4. 如果输出对象字符串，证明契约匹配成功，类已正常载入运行时字典。

---

## 4. 原生文件选择对话框 (`PMLFileBrowser`)
在 PML 中如果直接弹 Windows API 对话框容易产生宿主线程锁死，官方提供了原生安全封装类 `Aveva.Pdms.Presentation.PMLFileBrowser`：
```pml
import 'PMLFileBrowser'
using namespace 'Aveva.Pdms.Presentation'

!browser = object PMLFileBrowser('OPEN') -- 支持 'OPEN' 或 'SAVE'

-- 弹出文件选择器: !browser.show(dir, seed, title, exists, filter, index)
!browser.show('C:\ShipData', 'block.txt', 'Open Hull Data', true, 'Data Files (*.txt)|*.txt|All files (*.*)|*.*', 1)

!filePath = !browser.file()
if (!filePath.unset() and not !filePath.empty()) then
    $P Target File: $!filePath
endif
```

---

## 5. 核心架构认知：双轨命名空间设计原则
AVEVA Marine 原厂类库（如 `netaveva.marine.planarapi.pdf`）广泛采用了双轨命名空间架构：
- **核心托管层 (`Aveva.Marine.Planar.*`)**: 供纯 C# 插件内部调用，支持强类型、重载、泛型与复杂内存控制。
- **PML 代理层 (`Aveva.Marine.Planar.PML.*`)**: 专为 PML 解释器设计的包装层，将 C# `enum` 封装为无参工厂方法（如 `!side.Ps()`），将数据结构包装为符合 `[PMLNetCallable]`、无重载歧义、仅使用 `double`/`string` 的安全类（如 `BracketArm`, `StiffenerStatement`）。
- **工程原则**: 在 PML 脚本中编写平面结构业务时，必须导入 `using namespace 'Aveva.Marine.Planar.PML'`；在 C# 插件中推荐直接使用 `Aveva.Marine.Planar.*`。

## Key Takeaways
1. 任何 PMLNetCallable 类必须同时满足：标记属性、公共无参构造函数、`Assign(that)` 拷贝方法。
2. 所有数值交互必须使用 `double`，禁止使用 `int`、`long` 或 `float`。
3. C# 无法直接下发指令到 PML，唯有依靠 `PMLNetDelegate.PMLNetEventHandler` 事件将 `ArrayList` 参数广播给订阅者。
4. 使用 `container ... pmlnetcontrol` 可在老旧 PML 界面体系中引入现代化 .NET 用户界面。

## Connects To
- **Ch 01**: [ch01-architecture-and-caf-addin.md](ch01-architecture-and-caf-addin.md)（与 CAF Addin 共享底层服务）
- **Ch 02**: [ch02-database-access-and-elements.md](ch02-database-access-and-elements.md)（在 PMLNet 桥接方法中存取 `DbElement`）
- **Ch 04**: [ch04-ui-controls-grid-mydata.md](ch04-ui-controls-grid-mydata.md)（将 AVEVA C# Grid Control 宿主到 PML 表单）
