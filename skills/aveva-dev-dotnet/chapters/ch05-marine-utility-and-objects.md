# Chapter 5: AVEVA Marine Utility API & Core Domain Objects

## Core Idea
`marAPI.dll` 中的 `Aveva.Marine.Utility` 命名空间是 AVEVA Marine 二次开发的基础底层框架；它提供了对 Marine 专有实体模型的对象化封装（如 `MarObject`、`MarDataBase`、`MarUtil`），并规范了命令注入、图纸与模型列表检索、二维几何轮廓以及基于 `IDisposable` 的非托管资源生命周期管理。

## Frameworks Introduced
- **Marine 非托管资源生命周期管理模式 (Marine Resource Disposal Pattern)**:
  - When to use: 任何使用 `marAPI.dll` 中以 `Mar...` 开头的类（如 `MarObject`, `MarDataBase`, `MarUtil`）时。
  - How:
    1. 所有核心业务类均实现了 `System.IDisposable` 接口，底层紧密包装了 C/C++ 内存句柄与 Marine 内部数据块。
    2. 必须在 C# 中采用 `using (...) { ... }` 语句块或在 `finally` 块中调用 `.Dispose()`。
    3. 严禁放任垃圾回收器（GC）非确定性回收，否则可能导致底层 Marine 数据通信通道未正常释放或产生内存碎片。
- **MarDataBase 准则查询体系 (Criteria-Based Query Framework)**:
  - When to use: 从 AVEVA Marine 工程中批量提取特定图纸（Dwg）或构件对象清单（ObjectList）时。
  - How: 构建 `MarObjectCriteria` 准则过滤条件，传给 `MarDataBase.ObjectListGet` 获得目标集合。

## Key Concepts
- **MarObject**: AVEVA Marine 所有业务对象的通用基类，提供深浅复制 `Assign(that)` 与非托管指针清理逻辑。
- **MarUtil**: 通用工具服务类，提供应用程序类型检测（如 `AppCurvedHull`、`AppBasicDesign`）、宏命令动态注入（`AddCommand`）及坐标系变换。
- **MarDataBase**: 专门面向 Marine 结构模型的查询网关，提供 `ObjectListGet` 与 `DwgListGet` 方法。
- **MarObjectCriteria**: 查询过滤器描述类，用于设定构件名匹配模式、类型过滤器和模型状态掩码。
- **MarPoint2D / MarContour2D**: 二维空间坐标点与平面轮廓线段集合，是船体板缝、开孔轮廓的数学描述基础。
- **MarTbBaseException**: Marine 底层异常基类，所有来自 Marine 原生核心的错误均继承自此类。

## Mental Models
- **Think of MarObject as a Managed Handle to a Marine C++ Structure**: `MarObject` 并不包含全部数据副本，它是对 Marine 核心引擎中内存块的托管安全代理。
- **Think of MarUtil as the Command & Context Hub**: 当需要知道“当前是否在曲面外板模块”或“向控制台发送一行宏指令”时，第一选择是 `MarUtil`。

## Anti-patterns
- **忽略 Dispose() 导致连接泄露**: 在循环中大量 `new MarObject()` 或 `new MarDataBase()` 而不调用 `Dispose()`，极易耗尽底层 Marine IPC 通信套接字或内存句柄。
- **混淆 Aveva.Core.Database 与 Aveva.Marine.Utility**: `Aveva.Core.Database.DbElement` 偏向 Plant/Common Dabacon 树形层级，而 `MarObject` / `MarDataBase` 偏向船体造船工艺（Marine 业务逻辑），两者应结合使用而非相互混淆。

## Code Examples
```csharp
using System;
using Aveva.Marine.Utility;

namespace Aveva.CustomMarine.Utilities
{
    public class MarineQueryExample
    {
        /// <summary>
        /// 检查当前模块并使用 MarDataBase 查询符合条件的船体对象
        /// </summary>
        public void QueryMarineObjects()
        {
            // 1. 使用 using 严格管理非托管资源
            using (MarUtil util = new MarUtil())
            using (MarDataBase db = new MarDataBase())
            using (MarObjectCriteria criteria = new MarObjectCriteria())
            {
                // 2. 检测当前所处的 Marine 业务模块
                if (util.AppCurvedHull())
                {
                    Console.WriteLine("Currently active in Curved Hull Modelling.");
                }
                else if (util.AppBasicDesign())
                {
                    Console.WriteLine("Currently active in Basic Design.");
                }

                // 3. 配置查询准则（例如检索特定名称前缀的构件）
                // criteria 提供了对构件类别、命名模式等筛选配置

                try
                {
                    // 4. 获取符合条件的构件列表
                    using (MarStringlist resultList = db.ObjectListGet(criteria))
                    {
                        if (resultList != null)
                        {
                            int count = resultList.Count;
                            Console.WriteLine($"Found {count} matching marine objects:");
                            for (int i = 0; i < count; i++)
                            {
                                Console.WriteLine($"  [{i}] {resultList[i]}");
                            }
                        }
                    }
                }
                catch (MarTbBaseException tbEx)
                {
                    // 5. 捕获 Marine 内核特定异常
                    Console.WriteLine($"Marine Core Error: {tbEx.Message}");
                }
            }
        }

        /// <summary>
        /// 动态向 AVEVA 宿主注入命令行指令
        /// </summary>
        public void SendMacroCommand(string cmd)
        {
            using (MarUtil util = new MarUtil())
            {
                util.AddCommand(cmd);
            }
        }
    }
}
```
- **What it demonstrates**: `MarUtil`、`MarDataBase` 和 `MarObjectCriteria` 的生命周期管控、环境检测、准则过滤及安全异常处理。

## Reference Tables

### `Aveva.Marine.Utility` 关键类型表
| 类型名称 | 接口 / 基类 | 核心功能 |
|---|---|---|
| `MarObject` | `IDisposable` | 基础模型包装，实现 `Assign(MarObject that)` |
| `MarUtil` | `IDisposable` | 工具函数库（环境判断、命令发送、坐标变换） |
| `MarDataBase` | `IDisposable` | 模型与图纸查询网关 (`ObjectListGet`, `DwgListGet`) |
| `MarObjectCriteria` | `IDisposable` | 查询过滤条件封装器 |
| `MarStringlist` | `IDisposable` | 专用的非托管安全字符串列表 |
| `MarPoint2D` | `IDisposable` | 二维几何点坐标 (`X`, `Y`) |
| `MarContour2D` | `IDisposable` | 二维轮廓，由有序的折线或圆弧构成 |
| `MarTbBaseException`| `System.Exception` | Marine 底层通用异常类型 |

### PMLNet 跨语言调用双重载规范 (Int32 与 Double 并存机制)
在 `marAPI.dll` 中，大量核心方法与属性提供成对的重载版本：
- **C# 原生版本**: 采用 `int` / `Int32` 参数（如 `int Layers`, `int GetNoSegments()`）。在纯 C# 插件开发中应优先使用，确保强类型与极致性能。
- **PML 兼容版本**: 带有 `PML` 后缀或入参为 `double`（如 `double LayersPML`, `double GetNoSegmentsPML()`）。由于 PML 解释器内部无整型概念，所有数值变量均为双精度浮点数（`double`），因此在 PML 脚本或 PMLNet 包装层中必须调用带 `PML` 后缀或 `double` 重载的方法。

### 跨语言专用字典集合类 (NCUG 与 marAPI Interop Dictionaries)
为了在无法直接传递 C# 复杂泛型字典的 PML 环境中完成键值对通信，`marAPI.dll` 封装了 5 大专用字典类：
| 字典类名 | 键类型 | 值类型 | PML 互操作方法 | 典型业务场景 |
|---|---|---|---|---|
| `StringStringDictionary` | `string` | `string` | `KeysPML()`, `ValuesPML()` | 构件元数据键值对映射 |
| `StringIntDictionary` | `string` | `int` | `KeysPML()`, `ValuesPML()` | 枚举名称与底层状态码映射 |
| `StringDoubleArrayDictionary`| `string` | `double[]` | `KeysPML()`, `ValuesPML()` | 构件名称对应坐标/尺寸数组 |
| `StringStringArrayDictionary`| `string` | `string[]` | `KeysPML()`, `ValuesPML()` | 分段归属的多个零件批次清单 |
| `IntStringArrayDictionary` | `int` | `string[]` | `KeysPML()`, `ValuesPML()` | 焊工技能代码对应的质量报表 |

在 PML 中调用字典对象的 `!dict.keyspml()` 与 `!dict.valuespml()`，会自动转化为 PML 原生 `Hashtable` 供脚本遍历。

## Worked Example: 构件检索与指令批量后处理
1. **构建准则**: 实例化 `MarObjectCriteria`，配置需检索的结构件范围。
2. **执行检索**: 调用 `MarDataBase.ObjectListGet(criteria)` 获得构件名单。
3. **后处理执行**: 遍历构件清单，拼接属性刷新或检查命令，使用 `MarUtil.AddCommand("...")` 依次发送给宿主交互引擎执行。
4. **资源释放**: 确保所有 `Mar...` 对象在退出当前作用域前被释放，杜绝非托管资源堆积。

## Key Takeaways
1. `marAPI.dll` 中绝大多数类继承自 `IDisposable`，务必遵循 `using` 块模式确保确定性析构。
2. `MarUtil` 是执行交互式命令（`AddCommand`）和识别当前子模块的统一入口。
3. 查询结果返回的 `MarStringlist` 也是非托管资源包装，必须及时 `Dispose()`。
4. 任何底层错误均抛出 `MarTbBaseException`，应在业务代码中针对性捕获以友好提示用户。

## Connects To
- **Ch 02**: [ch02-database-access-and-elements.md](ch02-database-access-and-elements.md)（与通用 `DbElement` 相互印证）
- **Ch 06**: [ch06-marine-ui-and-vitesse.md](ch06-marine-ui-and-vitesse.md)（结合 `MarUi` 进行交互提示）
- **Ch 07**: [ch07-marine-welding-and-production.md](ch07-marine-welding-and-production.md)（基于 Utility 支撑焊接与生产管线）
