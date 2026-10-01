# Chapter 2: Database Access, Navigation, Spatial Geometry & DbEvents

## Core Idea
AVEVA 的数据存储核心基于 Dabacon 数据库体系，`Aveva.Core.Database.dll` 提供了面向对象的强类型接口；所有数据库实体均抽象为 `DbElement`，通过 `DbElementType` 与 `DbAttribute` 进行元数据定义、层级导航与事务变更。结合 `Aveva.Core.Geometry` 几何数学库、`DbEvents` 实时事件总线与 `PseudoAttribute` 伪属性扩展机制，开发者可构建高度响应式的三维空间数据管道。

## Frameworks Introduced
- **DbElement 层次导航与属性存取模型 (DbElement Navigation & Access Model)**:
  - When to use: 任何对 AVEVA 模型树（如 Zone, Equipment, Pipe, Structure, Hull Panel）进行遍历、查询、创建与属性更新的操作。
  - How:
    1. 通过静态方法 `DbElement.GetElement("/NAME")` 或当前工作元素获取目标实体。
    2. 检查 `element.IsValid()` 与 `element.IsNull()` 确保实体处于已打开数据库且未被删除。
    3. 使用 `element.Owner` 或 `element.Members()` 进行树形层级遍历。
    4. 读取属性时优先使用类型化方法（如 `GetString(DbAttributeInstance.DESC)`, `GetDouble(DbAttributeInstance.POSX)`）。
    5. 写入属性前确保所在 DB 处于写模式（`element.Database.Writeable`），使用 `SetAttribute(...)` 修改。
- **三维空间几何映射框架 (3D Spatial Geometry Framework)**:
  - When to use: 从三维图元存取世界坐标（`POS`）、朝向姿态（`ORI`），或进行两点间距测量、向量叉乘及法向偏移时。
  - How:
    1. 引入 `Aveva.Core.Geometry`（或 `Aveva.Pdms.Geometry.dll`）。
    2. 使用 `element.GetPosition(DbAttributeInstance.POS)` 获得强类型 `Position` 对象。
    3. 使用 `element.GetOrientation(DbAttributeInstance.ORI)` 获得强类型 `Orientation` 对象（包含 `YDir`, `ZDir`, `XDir`）。
    4. 空间坐标位移通过 `pos.Offset(dir, distance)` 运算，并由 `element.SetPosition(...)` 写回。
- **数据库变更事件监听总线 (Database Events Bus)**:
  - When to use: 在插件窗体中实时监听用户或其他后台操作产生的数据变动，实现三维构件选中高亮、属性看板自动刷新。
  - How: 订阅 `DbEvents.AttributeChangeEvent` 与 `DbEvents.TransactionEvent`，在接收到通知后过滤感兴趣的 `DbElementType`。
- **自定义伪属性计算管道 (Pseudo Attribute Pipeline)**:
  - When to use: 需要为原生模型注入复杂的企业动态派生属性（如自动计算构件净重、油漆面积、造价评估），并支持在 PML 或命令行通过 `q :MYATTR` 即时查询。
  - How: 调用 `PseudoAttribute.Register(...)` 注册带冒号的属性标识符、适用类型及计算委托函数。

## Key Concepts
- **DbElement**: 数据库实体的核心抽象，具有“值语义”（Value Semantics）——比较两个 `DbElement` 实例时，只要指向同一数据库元素即判定相等。
- **DbElementType & DbAttribute**: 实体类型与属性定义；系统预置项通过 `DbElementTypeInstance` 与 `DbAttributeInstance` 提供静态单例。
- **Position & Direction & Orientation**: 三维几何核心类，分别表达绝对笛卡尔坐标点（East, North, Up）、单位方向向量与三维空间姿态矩阵。
- **DbEvents**: 宿主数据库核心事件分发中心，提供 `TransactionEvent`、`AttributeChangeEvent`、`ElementCreateEvent`、`ElementDeleteEvent`。
- **Pseudo Attribute (伪属性)**: 并非物理存储于 DB 中、而是通过 C# 委托实时计算派生的动态属性（以冒号开头）。
- **DbUnits & DbDouble**: 单位制与量纲封装类，支持公制（mm）与英制（inch）的自适应无损换算。
- **DbTable / DbColumn / DbCell**: Dabacon 内部关系表抽象，用于快速批量查询元数据与等级库映射。

## Mental Models
- **Think of DbElement as a Lightweight Pointer**: `DbElement` 只是轻量级数据库实体指针，其本身不驻留庞大属性值，所有属性读取均为向 Dabacon 内核的即时拉取。
- **Think of Geometry Classes as Vector Math Accelerators**: 严禁将三维坐标作为逗号分隔的文本字符串手动解析；始终利用 `Position` 与 `Direction` 的点乘、叉乘与偏移方法完成三维空间解析。
- **Think of PseudoAttribute as a Virtual Getter**: 伪属性就像给数据库图元动态挂载了一个只读属性的 Getter 委托，调用方无需感知背后的复杂计算逻辑。

## Anti-patterns
- **直接通过字符串拼接解析 POS/ORI 坐标**: 使用字符串分割 `E 1000mm N 2000mm U 500mm` 极易受不同用户设置的单位制与格式化影响；必须使用 `element.GetPosition(DbAttributeInstance.POS)`。
- **在 DbEvents 回调中无保护写入数据库**: 在属性变更事件处理器内再次调用 `SetAttribute` 会触发死循环递归事件风暴，必须设立防重入标志位（reentrancy guard）。
- **通过字符串反射高频检索系统属性**: 频繁使用 `DbAttribute.GetDbAttribute(":MYATTR")` 会导致额外的哈希查找；系统预置属性应统一使用 `DbAttributeInstance.X`。
- **跨线程直接操作 AVEVA 数据库**: Dabacon 核心为单线程单元（STA）模型，后台工作线程中直接调用 `DbElement` 会导致崩溃；必须通过 UI 调度器派发至主线程。

## Code Examples

### 1. 实体遍历、空间坐标解析与姿态变换
```csharp
using System;
using Aveva.Core.Database;
using Aveva.Core.Geometry;

namespace Aveva.CustomMarine.Data
{
    public class SpatialModelService
    {
        /// <summary>
        /// 检查设备三维几何坐标，并将其向上平移指定距离
        /// </summary>
        public void ElevateEquipment(string equipName, double deltaHeightMm)
        {
            // 1. 获取并验证实体
            DbElement equip = DbElement.GetElement(equipName);
            if (!equip.IsValid() || equip.IsNull())
            {
                throw new ArgumentException($"Invalid element: {equipName}");
            }

            // 2. 读取强类型 Position 与 Orientation
            Position currentPos = equip.GetPosition(DbAttributeInstance.POS);
            Orientation currentOri = equip.GetOrientation(DbAttributeInstance.ORI);

            Console.WriteLine($"Current Position: E={currentPos.East}, N={currentPos.North}, U={currentPos.Up}");
            Console.WriteLine($"Z-Axis Vector: ({currentOri.ZDir.X}, {currentOri.ZDir.Y}, {currentOri.ZDir.Z})");

            // 3. 检查写入权限并进行几何平移
            if (equip.Database.Writeable)
            {
                Position newPos = currentPos.Offset(Direction.Up, deltaHeightMm);
                equip.SetPosition(DbAttributeInstance.POS, newPos);
                Console.WriteLine($"Equip elevated to Up={newPos.Up}");
            }
        }
    }
}
```

### 2. 数据库变更监听与动态高亮更新 (DbEvents)
```csharp
using System;
using Aveva.Core.Database;

namespace Aveva.CustomMarine.Data
{
    public class DatabaseWatcher : IDisposable
    {
        private bool _isHandling = false;

        public void StartListening()
        {
            // 订阅属性变更与事务提交
            DbEvents.AttributeChangeEvent += OnAttributeChanged;
            DbEvents.TransactionEvent += OnTransactionChanged;
        }

        private void OnAttributeChanged(object sender, AttributeChangeEventArgs e)
        {
            if (_isHandling) return; // 防重入防卫

            try
            {
                _isHandling = true;
                DbElement modifiedElem = e.Element;
                DbAttribute attr = e.Attribute;

                if (attr == DbAttributeInstance.POS || attr == DbAttributeInstance.ORI)
                {
                    Console.WriteLine($"Geometry modified for {modifiedElem.GetAsString(DbAttributeInstance.NAME)}");
                }
            }
            finally
            {
                _isHandling = false;
            }
        }

        private void OnTransactionChanged(object sender, TransactionEventArgs e)
        {
            if (e.Type == TransactionEventArgs.TransactionType.Commit)
            {
                Console.WriteLine("Dabacon transaction committed successfully.");
            }
        }

        public void Dispose()
        {
            DbEvents.AttributeChangeEvent -= OnAttributeChanged;
            DbEvents.TransactionEvent -= OnTransactionChanged;
        }
    }
}
```

### 3. 注册企业级自定义伪属性 (PseudoAttribute)
```csharp
using System;
using Aveva.Core.Database;

namespace Aveva.CustomMarine.Data
{
    public static class CustomAttributeRegistrar
    {
        public static void RegisterFabricationAttributes()
        {
            // 注册计算重量的伪属性 :FABWEIGHT
            PseudoAttribute.Register(
                ":FABWEIGHT",
                DbElementTypeInstance.EQUIPMENT,
                DbAttributeType.Double,
                CalculateFabricationWeight
            );
        }

        private static object CalculateFabricationWeight(DbElement element)
        {
            if (!element.IsValid()) return 0.0;

            // 读取构件长宽高并计算估算重量
            double x = element.GetDouble(DbAttributeInstance.XLEN);
            double y = element.GetDouble(DbAttributeInstance.YLEN);
            double z = element.GetDouble(DbAttributeInstance.ZLEN);
            double steelDensity = 7.85e-6; // kg/mm^3

            return (x * y * z) * steelDensity;
        }
    }
}
```

### 4. 高效层级迭代与智能过滤 (`DBElementCollection`)
```csharp
using System;
using Aveva.Core.Database;
using Aveva.Core.Database.Filters;

namespace Aveva.CustomMarine.Data
{
    public class ModelQueryService
    {
        /// <summary>
        /// 使用 DBElementCollection 高性能查找指定根节点下的所有设备与管嘴
        /// </summary>
        public void ScanEquipmentTree(DbElement rootElement)
        {
            // 构造复合过滤器：类型为 EQUIPMENT 或 NOZZLE
            var equipFilter = new TypeFilter(DbElementTypeInstance.EQUIPMENT);
            var nozzleFilter = new TypeFilter(DbElementTypeInstance.NOZZLE);
            var compositeFilter = new OrFilter(equipFilter, nozzleFilter);

            // DBElementCollection 自动进行树形剪枝，跳过无关几何分支
            var collection = new DBElementCollection(rootElement, compositeFilter);

            foreach (DbElement ele in collection)
            {
                string name = ele.GetAsString(DbAttributeInstance.NAME);
                Console.WriteLine($"Found {ele.ElementType.Name}: {name}");

                // 检查该图元自上一 Session 以来是否发生过修改 (会话历史比对)
                bool isModified = ele.GetBoolean(DbAttribute.GetDbAttribute("ATTMOD"));
                if (isModified)
                {
                    int lastSession = ele.GetInteger(DbAttribute.GetDbAttribute("MSESS"));
                    Console.WriteLine($" -> Modified in Session #{lastSession}");
                }
            }
        }

        /// <summary>
        /// 动态解析并评估 PML 规则表达式 (DbExpression)
        /// </summary>
        public double CalculateDynamicClearance(DbElement element)
        {
            // 编译 PML1 表达式并对图元进行距离量纲求解
            DbExpression expr = DbExpression.Parse("(POSZ - 500) / 2");
            double clearanceMm = element.EvaluateDouble(expr, DbAttributeUnit.DIST);
            return clearanceMm;
        }
    }
}
```

## Reference Tables

### 官方高效过滤器族 (`Aveva.Core.Database.Filters`)
| 过滤器类 | 构造与用途 | 说明 |
|---|---|---|
| `TypeFilter` | `new TypeFilter(DbElementType)` | 仅匹配指定实体类型的图元（如 `NOZZLE`） |
| `AttributeTrueFilter` | `new AttributeTrueFilter(DbAttribute)` | 仅匹配指定布尔属性为 `true` 的图元 |
| `AttributeFalseFilter` | `new AttributeFalseFilter(DbAttribute)` | 仅匹配指定布尔属性为 `false` 的图元 |
| `AttributeRefFilter` | `new AttributeRefFilter(DbAttribute, DbElement)` | 仅匹配引用属性指向目标图元的构件 |
| `AndFilter` | `new AndFilter(filterA, filterB)` | 逻辑“与”复合过滤 |
| `OrFilter` | `new OrFilter(filterA, filterB)` | 逻辑“或”复合过滤 |
| `BelowFilter` | `new BelowFilter(baseFilter)` | 递归匹配位于满足条件的父节点之下的图元 |

### Dabacon 底层索引表与跨库迭代器 (NCUG 4.4)
| 表类名 | 适用范围 | 键/值类型 | 典型工程场景 |
|---|---|---|---|
| `NameTable` | 单个物理 DB | 键: `string` (名称) -> 值: `refno` | 根据名称瞬间检索图元指针 |
| `RefTable` | 单个物理 DB | 键: `refno` (元件) -> 值: `refno` (构件) | 极速反查引用了某个标准型材/等级库的所有构件 |
| `IntTable` | 单个物理 DB | 键: `int` (状态码) -> 值: `refno` | 根据状态数值快速定位特定批次零件 |
| `MdbNameTable` | 当前 MDB 全库 | 跨所有打开 DB 自动汇聚 | 全项目跨库名称定位 |
| `MdbIntTable` | 当前 MDB 全库 | 跨所有打开 DB 自动汇聚 | 全项目跨库整型状态过滤 |

> [!CAUTION]
> **Token 内存泄露陷阱**: 遍历表索引后必须显式销毁释放底层 Token，否则将导致命令行持续抛出 `"xx dabacon search tokens - Expected none"` 报警。

### 数据库、抽取库与历史会话伪属性矩阵 (NCUG 4.5)
| 伪属性名 | 返回类型 | 作用对象 | 说明 |
|---|---|---|---|
| `ATTMOD` | `bool` | 图元/属性 | 该图元/属性在当前会话中是否已被修改 |
| `ATTMODLIST` | `DbAttribute[]` | 图元 | 自指定历史 Session 以来被修改过的全部属性列表 |
| `ELECRE` / `ELEMOD` | `bool` | 图元 | 是否在指定 Session 之后新建 / 发生物理修改 |
| `HIST` | `int[]` | 图元 | 记录该图元被修改过的所有历史 Session 编号数组 |
| `LASTM` / `USERM` | `string` | 图元 | 最后一次修改的时间戳 / 操作员用户名 |
| `MSESS` / `SESSNO` | `int` | 图元 / 全局 | 最后修改所在会话编号 / 当前打开的会话编号 |
| `OKDROP` | `bool` | 抽取库图元 | 当前构件是否允许在工作抽取库中执行 Drop 放弃 |
| `OKRLEX` | `bool` | 抽取库图元 | 当前构件是否允许在抽取库中执行 Extract Release 释放 |
| `CLAIM` / `CLCCNT` | `string` / `int` | 数据库图元 | 数据库内持有的独占状态模式与 Claim 构件计数 |
| `ISWORK` / `ISDBFR` | `bool` | 数据库图元 | 是否为工作抽取副本 (Working Extract) / 外部项目库 |
| `EXTFAM` / `EXTALS` | `DbElement[]` | 抽取库图元 | 抽取分支的完整家族成员列表 / 祖先抽取分支 |
| `FILENAME` / `SIZEDB` | `string` / `int` | 数据库图元 | 物理数据库文件名与文件字节大小 |
| `CSESS` / `DSESS` | `string` | 历史会话 | 指定历史 Session 提交时填写的 Comment 备注与生成时间 |

### 数据库全量生命周期事件 (`DbEvents`)
| 事件名称 | 触发时机 | 典型订阅用途 |
|---|---|---|
| `AddChangeEventHandler` | PML 宏结束、命令执行完毕、窗体提交时 | 统一捕获 `DbUserChanges`，监听构件增删改 |
| `CommitPending` | `SaveWork`, `QuitWork`, `GetWork`, `Undo` 之前 | 各子系统将内存未落盘脏数据强制同步 |
| `ClearCache` | 会话切换、Undo/Redo、GetWork 之后 | 清除客户端构件本地内存缓存（必须高频轻量处理） |
| `Pre/Post Local Changes` | 本地视图变动（GetWork, Undo, Redo）前后 | 刷新当前客户端三维视口与构件树视图 |
| `Pre/Post DB Changes` | 物理文件变动（SaveWork, Refresh, Flush, Drop）前后 | 触发与外部系统的数据同步或写回日志 |
| `Post claim/release` | 构件被签出独占（Claim）或解除释放之后 | 实时更新多用户协同锁状态 |

### 常用属性访问方法 (`DbElement`)
| 方法名 | 返回类型 | 用途说明 |
|---|---|---|
| `GetAsString(DbAttribute)` | `string` | 读取文本属性（如 `NAME`, `DESC`, `PURP`） |
| `GetDouble(DbAttribute)` | `double` | 读取数值属性（如尺寸、标高） |
| `GetElement(DbAttribute)` | `DbElement` | 读取引用型属性（如参考对齐实体、等级材质指针） |
| `GetPosition(DbAttribute)` | `Position` | 直接返回强类型三维空间位置坐标 |
| `GetOrientation(DbAttribute)` | `Orientation` | 直接返回强类型三维朝向与旋转姿态 |
| `SetAttribute(DbAttribute, val)` | `void` | 修改属性值（支持 string, double, DbElement 等） |
| `SetPosition(DbAttribute, Position)` | `void` | 直接写入强类型三维空间位置坐标 |
| `EvaluateDouble(DbExpression, unit)` | `double` | 评估 PML 表达式并按指定量纲换算为标准毫米值 |
| `EvaluateElement(DbExpression)` | `DbElement` | 评估表达式并返回目标构件句柄 |

### 核心空间几何类型 (`Aveva.Core.Geometry`)
| 类型名称 | 核心成员 | 说明 |
|---|---|---|
| `Position` | `East`, `North`, `Up`, `DistanceTo()`, `Offset()` | 空间绝对坐标点 |
| `Direction` | `X`, `Y`, `Z`, `Angle()`, `Cross()`, `Dot()` | 空间单位方向矢量 |
| `Orientation` | `YDir`, `ZDir`, `XDir`, `Invert()` | 空间正交旋转姿态 |

### 单位制、物理量纲与自适应计算 (`Aveva.Core.Units`)
Dabacon 原生支持混合单位制（公制、英制、通径），二次开发必须使用 `DbDouble` 与量纲系统避免手动换算误差：
- **自适应实数创建**: `DbDouble d = DbDouble.Create("2.5 m");`
- **单位换算**: `DbDouble inchVal = d.ConvertUnits(DbDoubleUnits.GetUnits(DbUnits.INCH));`
- **量纲算术与异常防卫**: `DbDouble` 支持 `+`, `-`, `*`, `/` 运算并自动换算；若物理量纲不兼容（例如长度与质量相加），立即抛出 `PdmsException` 阻止数据库脏数据写入：
  ```csharp
  try
  {
      DbDouble len = DbDouble.Create("100 mm");
      DbDouble wt = DbDouble.Create("5 kg");
      DbDouble invalid = len + wt; // 抛出 PdmsException: Incompatible dimensions
  }
  catch (PdmsException ex)
  {
      Console.WriteLine($"Unit mismatch caught: {ex.Message}");
  }
  ```
- **格式化输出 (`DbFormat`)**:
  ```csharp
  DbFormat fmt = DbFormat.Create();
  fmt.Dimension = DbDoubleDimension.GetDimension(DbDimension.DIST);
  fmt.Units = DbDoubleUnits.GetUnits(DbUnits.MM);
  fmt.Label = "mm";
  string text = d.ToString(fmt); // 输出 "2500.0mm"
  ```

## Worked Example: 属性批量安全更新工作流
1. **启动操作**: 传入目标结构件数组 `DbElement[] parts`。
2. **权限与事务检查**: 确认 `parts[0].Database.Writeable == true`。
3. **安全更新**:
   ```csharp
   try
   {
       foreach (var part in parts)
       {
           if (part.IsValid() && !part.IsNull())
           {
               part.SetAttribute(DbAttributeInstance.PURP, "FABRICATION");
           }
       }
   }
   catch (PdmsException ex)
   {
       Console.WriteLine($"Dabacon DB error: {ex.Message}");
   }
   ```
4. **刷新视图**: 触发宿主更新或通知 CAF 界面重绘。

## Key Takeaways
1. `DbElement` 是操作 AVEVA 数据的统一核心载体，任何操作首要调用 `IsValid()` 进行有效性防卫。
2. 几何操作始终使用 `Position` 和 `Orientation` 强类型，杜绝字符串手工拼接解析。
3. 动态数据感知依赖 `DbEvents`，动态指标扩展依赖 `PseudoAttribute`，两者是打造响应式 AVEVA 工具的核心。
4. 任何对模型的修改（`Create`, `SetAttribute`, `Delete`）必须先验证 `Database.Writeable`，并放在 `try...catch (PdmsException)` 块中进行事务防卫。

## Connects To
- **Ch 01**: [ch01-architecture-and-caf-addin.md](ch01-architecture-and-caf-addin.md)（在 Addin 中结合 UI 呈现查询到的 `DbElement` 数据）
- **Ch 03**: [ch03-pmlnet-interop-and-controls.md](ch03-pmlnet-interop-and-controls.md)（在 PML 与 C# 之间传递 DbElement 引用）
- **Ch 08**: [ch08-planar-fundamentals-and-panels.md](ch08-planar-fundamentals-and-panels.md)（利用 `DbElement` 构建船体 Planar 结构语句）
- **Core Ref**: [../references/core-api-reference.md](../references/core-api-reference.md)（查看 CAF、Database 与 Geometry 完整 API 手册）
