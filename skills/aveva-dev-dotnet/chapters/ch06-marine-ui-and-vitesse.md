# Chapter 6: Marine UI Automation & Vitesse Python Integration

## Core Idea
`Aveva.Marine.UI` 与 `Aveva.Marine.Vitesse` 构成了 AVEVA Marine 专有的交互与跨语言脚本桥梁；`MarUi` 提供了直接操控宿主窗口与原生对话框的轻量化界面接口，而 Vitesse 模块则将 Python 脚本引擎（`MarPythonEngine`）封装为托管对象，形成 C#、Python 与 PML 三者无缝协同的强大自动化生态。

## Frameworks Introduced
- **三元语言互操作架构 (Tri-Language Interoperability Architecture: C# - Python - PML)**:
  - When to use: 企业已有成熟的 Marine Python 脚本库（Vitesse），或需要结合 Python 的强大科学计算库与 C# 的现代化 WPF/WinForms 界面时。
  - How:
    1. 使用 `Aveva.Marine.Vitesse.MarPythonEngine` 在 C# 进程内加载执行 Python 代码。
    2. 使用 `MarPythonObject` 封装 Python 类实例与函数返回值。
    3. 利用 `MarPythonObjectPML` 将 Python 实例转化为 PML 友好的代理对象，直接传递给 PML 表单。
- **原生交互提示框架 (Native Modal Prompting Framework)**:
  - When to use: 在无繁重 WinForms 窗体的情况下，快速要求用户进行单步确认、选项列表单选或颜色挑选。
  - How: 使用 `MarUi.AnswerReq` 弹出输入框，`MarUi.ChoiceSelect` 弹出选择单，`MarUi.ColourSelect` 弹出调色板。

## Key Concepts
- **MarUi**: AVEVA Marine 原生界面自动化服务类，负责与宿主界面的直接交互（弹窗输入、颜色选择、窗口最大化/最小化/刷新）。
- **MarButtonState**: Marine 原生工具条或按钮的状态枚举（如禁用、按下、默认状态）。
- **Vitesse**: AVEVA Marine 的经典 Python 扩展环境，内置海量船体、舾装建模 API。
- **MarPythonEngine**: 运行在 Marine 进程内的 Python 执行引擎封装，提供执行脚本和初始化环境方法。
- **MarPythonObject**: Python 对象的托管包装，支持跨语言方法调用与属性读取。
- **MarPythonObjectPML**: 专为 PML 设计的 Python 包装器，打通 Python 与 PML 的直接通信。
- **MarVitesseException**: 捕获 Python 语法错误、运行时未处理异常的专用异常类。

## Mental Models
- **Think of MarUi as a Console Dialog Shortcut**: 当只需要用户输入一个“分段编号”或“选择左舷/右舷”时，不要新建庞大的 WinForms 表单，直接调用 `MarUi.ChoiceSelect`。
- **Think of Vitesse as the Legacy Logic Repository**: 许多船厂积累了 10~20 年的 Vitesse Python 规则与经验公式，通过 C# + `MarPythonEngine` 可直接复用，而无需全部用 C# 重写。

## Anti-patterns
- **直接使用外部 `Process.Start("python.exe")`**: 外部独立 Python 进程无法直接访问 Marine 宿主内存中的实时模型；必须通过 `MarPythonEngine` 运行在宿主进程内部的嵌入式 Python 环境中。
- **忽略 MarPythonEngine 抛出的 MarVitesseException**: Python 的语法错误或动态类型异常无法在 C# 编译期发现，调用 `RunScript` 必须包裹 `try...catch (MarVitesseException)`。

## Code Examples
```csharp
using System;
using Aveva.Marine.UI;
using Aveva.Marine.Vitesse;
using Aveva.Marine.Utility;

namespace Aveva.CustomMarine.Automation
{
    public class MarineInteractionService
    {
        /// <summary>
        /// 使用 MarUi 弹出原生交互提示
        /// </summary>
        public string PromptUserForBlock()
        {
            using (MarUi ui = new MarUi())
            {
                // 1. 刷新宿主窗口
                ui.AppWindowRefresh();

                // 2. 弹出原生输入框，询问用户分段号
                string defaultAnswer = "BLOCK-01";
                string prompt = "Please enter the Target Block Name:";
                string result = ui.AnswerReq(prompt, defaultAnswer);

                Console.WriteLine($"User responded with: {result}");
                return result;
            }
        }

        /// <summary>
        /// 使用 MarPythonEngine 运行嵌入式 Vitesse 脚本
        /// </summary>
        public void ExecuteVitesseCalculation(string scriptPath, string blockName)
        {
            using (MarPythonEngine engine = new MarPythonEngine())
            {
                try
                {
                    // 3. 执行 Python 脚本文件
                    engine.RunScript(scriptPath);

                    // 4. 调用 Python 内部全局函数或创建对象
                    // 引擎支持在宿主内存中直接同步执行 Marine Python API
                    Console.WriteLine($"Vitesse script {scriptPath} executed successfully on {blockName}.");
                }
                catch (MarVitesseException vex)
                {
                    // 5. 捕获 Python 执行期异常
                    Console.WriteLine($"Vitesse Python Runtime Error: {vex.Message}");
                }
            }
        }
    }
}
```
- **What it demonstrates**: `MarUi` 原生窗口弹窗交互、刷新以及使用 `MarPythonEngine` 执行 Vitesse 脚本并进行异常防护。

## Reference Tables

### `MarUi` 常用原生交互方法
| 方法名 | 返回值 | 功能说明 |
|---|---|---|
| `AnswerReq(string prompt, string def)` | `string` | 弹出简易输入框，让用户输入文本 |
| `ChoiceSelect(string title, ...)` | `int` | 弹出选项列表对话框，返回选中项索引 |
| `ColourSelect(...)` | `int` | 弹出调色盘选择 AVEVA 颜色代码 |
| `AppWindowMaximize()` | `void` | 最大化 Marine 主界面窗口 |
| `AppWindowMinimize()` | `void` | 最小化 Marine 主界面窗口 |
| `AppWindowRefresh()` | `void` | 强制重绘并刷新当前激活的图形视口 |
| `AppWindowRestore()` | `void` | 恢复窗口原始尺寸 |

### `Aveva.Marine.Vitesse` 核心类型表
| 类型名称 | 核心职责 |
|---|---|
| `MarPythonEngine` | Python 运行时引擎实例，负责脚本加载与执行 |
| `MarPythonObject` | 托管层封装的 Python 实体对象 |
| `MarPythonObjectPML` | PML 代理友好的 Python 对象包装，供 PML 直接消费 |
| `MarPythonUtil` | C# 基础类型与 Python 原生类型之间的快速序列化工具 |
| `MarVitesseException` | Vitesse 抛出的专属异常，携带 Python 错误回溯栈 |

## Worked Example: C# 界面驱动 Vitesse 脚本并回显结果
1. **界面发起**: 用户在 CAF Addin 界面输入计算参数。
2. **构建脚本入参**: 将参数写入临时上下文或直接作为实参注入。
3. **调用 Vitesse**:
   ```csharp
   using (var engine = new MarPythonEngine())
   {
       engine.RunScript(@"D:\MarineScripts\CheckPlateThickness.py");
   }
   ```
4. **宿主刷新**: 调用 `MarUi.AppWindowRefresh()`，让 Python 脚本生成的船体结构修改立即呈现在 3D 视图中。

## Key Takeaways
1. `MarUi` 提供最贴近 AVEVA 原生风格的轻量级弹窗与视口控制，适合快捷脚本与宏命令调用。
2. `MarPythonEngine` 是实现 C# 与现有 Vitesse Python 资产互通的关键设施，具备无需外挂进程的内存级高效协同。
3. Python 运行时所有异常均收敛于 `MarVitesseException`，务必做好捕获处理以防导致宿主闪退。
4. PML、C# 和 Python 可以形成环形互通，赋能造船工艺二次开发的各层级需求。

## Connects To
- **Ch 01**: [ch01-architecture-and-caf-addin.md](ch01-architecture-and-caf-addin.md)（将 Python 脚本封装为 CAF 菜单命令）
- **Ch 05**: [ch05-marine-utility-and-objects.md](ch05-marine-utility-and-objects.md)（与 Marine Utility 共享基础工具类）
- **Ch 08**: [ch08-planar-fundamentals-and-panels.md](ch08-planar-fundamentals-and-panels.md)（在自动化构建 Planar 结构时调用原生交互）
