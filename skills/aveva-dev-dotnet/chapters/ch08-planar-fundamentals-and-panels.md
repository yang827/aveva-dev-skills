# Chapter 8: Planar Modeling Fundamentals & PanelStatement

## Core Idea
`Aveva.Marine.Planar.dll` 实现了 AVEVA Marine 标志性的平面结构语句体系（Planar Statements）；该体系以 `PanelStatement` 为基石，将船体平面构件（甲板、横舱壁、纵舱壁、强框架等）的参考基准面（`PlaneStatement`）、外边界（`BoundaryStatement`）、水密等级及局部坐标轴系抽象为强类型对象，支持从 `DbElement` 双向解析与逆向重构船体结构语句。

## Frameworks Introduced
- **平面语句声明式建模框架 (Planar Statement Declarative Modeling Framework)**:
  - When to use: 任何通过程序自动化创建、修改、克隆或解析 AVEVA Marine 平面分段（Planar Panel）几何与属性的场景。
  - How:
    1. 引入 `Aveva.Marine.Planar.dll`。
    2. 创建 `PanelStatement` 并绑定所属分段（`Block`）、水密性（`isWatertight`）、标记面（`GMS`）。
    3. 声明参考基准面 `PlaneStatement`（指定是肋位 Frame、纵剖面 LP 还是水线面 WL）。
    4. 声明外围边界 `BoundaryStatement`（确定与外板、相邻甲板或舱壁的搭接修剪关系）。
    5. 调用 `.Statement` 属性获取符合 Marine 语法的标准化建模语句串，或调用 API 直接生成/更新模型。
- **DbElement 到 Planar 语句的双向互转模式 (DbElement-to-Planar Roundtrip Pattern)**:
  - When to use: 逆向解析现有三维模型中特定板架的施工参数。
  - How: 使用重载构造函数 `new PanelStatement(dbElement)`，直接将数据库图元转化为结构化语句对象。

## Key Concepts
- **Planar Panel (平面分段/板架)**: 船体结构建模的顶级容器，由一块或多块母板、纵骨、肋骨及肘板构成的平面组合体。
- **PanelStatement**: 平面分段语句类，映射底层 `PANEL` 语句的所有工艺与几何定义。
- **PlaneStatement**: 平面空间基准定义，确立当前板架在全船坐标系（FR/LP/WL）中的空间绝对姿态。
- **BoundaryStatement**: 板架外轮廓边界语句，定义板架的几何封闭范围（受哪些外板曲线或其它构件约束）。
- **DoublePlateStatement**: 双层底板或复合双层板架专用的语句定义。
- **ComponentHelper**: 平面构件导航辅助类，提供快速查询父级板架名称（`getPanelName`）与构件分组（`GetGroups`）方法。
- **UAxis / VAxis**: 平面板架的局部二维 UV 正交坐标系，后续所有骨材间距、开孔位置均以该局部系为基准。

## Mental Models
- **Think of PanelStatement as the Canvas**: 船体结构不是自由杂乱的碎片，`PanelStatement` 是画布，所有母板、加筋、肘板都在这张画布上依附绘制。
- **Think of Statement Property as Code-Behind**: 每一个 Statement 对象的 `.Statement` 字符串属性即是 Marine 标准设计语句，可以直接作为日志记录或输入宏。

## Anti-patterns
- **直接手工拼接 Marine 文本宏字符串**: 易出现空格、标点、参数顺序错误；应使用强类型的 `PanelStatement` 类设置属性，由 `.Statement` 属性自动生成标准语法。
- **脱离基准面盲目定义局部坐标**: 平面板架严格依赖全局肋位（Frame）或纵剖线（LP），若未正确初始化 `PlaneStatement`，在视图刷新时会导致构件飘出船体范围。

## Code Examples
```csharp
using System;
using Aveva.Core.Database;
using Aveva.Marine.Planar;

namespace Aveva.CustomMarine.PlanarModeling
{
    public class PanelBuilderService
    {
        /// <summary>
        /// 从现有的 DbElement 读取并逆向解析 Panel 语句
        /// </summary>
        public void InspectExistingPanel(DbElement panelElement)
        {
            if (!panelElement.IsValid()) return;

            // 1. 利用 DbElement 构造重载直接逆向解析
            PanelStatement panelStmt = new PanelStatement(panelElement);

            Console.WriteLine($"Panel Name: {panelStmt.Name}");
            Console.WriteLine($"Block: {panelStmt.Block}");
            Console.WriteLine($"Watertight: {panelStmt.isWatertight}");
            Console.WriteLine($"Marking Side (GMS): {panelStmt.GMS}");
            
            // 2. 打印还原出来的标准化 Planar 语句文本
            Console.WriteLine($"Generated Statement:\n{panelStmt.Statement}");
        }

        /// <summary>
        /// 程序化构建一个新的横舱壁平面语句
        /// </summary>
        public PanelStatement BuildTransverseBulkhead(string blockName, string panelName, double frameNumber)
        {
            // 3. 实例化并配置 PanelStatement
            PanelStatement panel = new PanelStatement();
            panel.Name = panelName;
            panel.Block = blockName;
            panel.isWatertight = true;
            panel.Locationstr = $"FR {frameNumber}"; // 位于指定肋位

            // 4. 配置基准面与局部坐标系
            panel.Axis = "X"; // 垂向法向量
            panel.Functionalprop = "TRANSVERSE_BULKHEAD";

            Console.WriteLine($"Built Panel Statement for {panelName}: {panel.Statement}");
            return panel;
        }
    }
}
```
- **What it demonstrates**: `PanelStatement` 的两种用法——从 `DbElement` 逆向读取现有分段，以及正向构建横舱壁平面结构。

## Reference Tables

### `PanelStatement` 关键属性字典
| 属性名 | 类型 | 说明 / 对应 Marine 语法关键字 |
|---|---|---|
| `Name` | `string` | 平面分段名称（如 `T_BHD_FR50`） |
| `Block` | `string` | 所属建造分段名（`Block`） |
| `isWatertight` | `bool` | 是否为水密舱壁/结构 |
| `GMS` | `string` | 划线与工艺标记侧（General Marking Side） |
| `Locationstr` | `string` | 基准定位描述（如 `FR 45`, `LP 3500`, `WL 6200`） |
| `Axis` | `string` | 主法向轴（X, Y 或 Z） |
| `UAxis` / `VAxis` | `string` | 板架二维局部正交轴向定义 |
| `Statement` | `string` | (只读) 导出的完整 Marine Planar 语句字符串 |
| `Valid` | `bool` | 当前语句逻辑完整性验证标识 |

## Worked Example: 自动化批量分段水密性核查
1. **获取待测构件集合**: 从当前工程过滤出所有的 `PANEL` 类型的 `DbElement`。
2. **转换为 Statement**: 对每个元素执行 `new PanelStatement(elem)`。
3. **核查逻辑**:
   - 提取分段名 `panel.Block` 与水密标识 `panel.isWatertight`。
   - 对标造船设计规范表，若该区域要求水密但 `isWatertight == false`，记录进预警清单。
4. **输出结果**: 结合第 4 章的表格控件直接高亮标记异常分段。

---

## 4. 逆向工程助手与 PML 分类机制

### 4.1 `ComponentHelper` 层级逆向提取
当需要从 3D 图元反查所属板架结构时，`ComponentHelper` 提供了轻量工具方法：
```csharp
using Aveva.Marine.Planar;

ComponentHelper helper = new ComponentHelper();

// 1. 从子构件反查所属父级板架名称
string panelName = helper.getPanelName(stiffenerElement);

// 2. 提取板架内部定义的所有结构分组号 (Group Numbers)
ArrayList groupList = helper.GetGroups(panelElement);
foreach (double groupNo in groupList)
{
    Console.WriteLine($"Panel {panelName} contains Group: {groupNo}");
}
```

### 4.2 PMLNet 模式下的无参方法工厂枚举
在 PML 脚本中编写平面结构语句时，枚举值必须通过调用对应无参方法进行链式赋值（参考 [planar-enums-reference.md](../references/planar-enums-reference.md)）：
```pml
using namespace 'Aveva.Marine.Planar.PML'

!panel = object PanelStatement()
!panel.Name = 'DECK_PL_01'

!wt = object EnWatertightType()
!wt.Watertight()
!panel.isWatertight = true

!side = object EnSide()
!side.Top()
!panel.GMS = !side.ToString()
```

## Key Takeaways
1. `PanelStatement` 是所有平面结构建模的顶层入口，统领其下的母板、型材与肘板。
2. 构造函数 `PanelStatement(DbElement)` 实现了数据库实体与计算模型的轻量转换，是逆向工程的利器。
3. 利用 `ComponentHelper` 可以迅速反查图元所属板架名称及所有子部件组号集合。
4. 板架必须正确指定 `Block` 和定位基准面（`Locationstr` / `Axis`），否则无法进入下料流水线。
5. 始终检查 `panel.Valid` 验证关键参数是否完备；PML 调用时通过 `Aveva.Marine.Planar.PML` 的状态方法设定枚举分类。

## Connects To
- **Ch 02**: [ch02-database-access-and-elements.md](ch02-database-access-and-elements.md)（与 `DbElement` 相互构造互转）
- **Ch 09**: [ch09-planar-plates-stiffeners-brackets.md](ch09-planar-plates-stiffeners-brackets.md)（在 Panel 基础上构建 Plate、Stiffener 与 Bracket）
- **Ch 10**: [ch10-planar-features-cuts-holes-welds.md](ch10-planar-features-cuts-holes-welds.md)（在 Panel 上增加开孔、切角与焊缝）
