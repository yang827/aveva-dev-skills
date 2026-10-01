# Chapter 9: Planar Structural Elements: Plates, Stiffeners & Brackets

## Core Idea
在造船板架体系中，母板（`PlateStatement`）、型材筋条（`StiffenerStatement`）与连接肘板（`BracketStatement`）构成了最基本的承载骨骼网络；`Aveva.Marine.Planar` 提供了细致到端部型切（`StiffenerEndConnection`）、倾角（`Inclination`）、肘板臂长（`ArmA`/`ArmB`）以及面板（`FlangeStatement`）的强类型全参数建模机制。

## Frameworks Introduced
- **型材筋条参数化排布模型 (Stiffener Parametric Layout Model)**:
  - When to use: 甲板纵骨、舱壁加筋、肋骨的快速批量生成与工艺端切定义。
  - How:
    1. 实例化 `StiffenerStatement`。
    2. 设置所属装配参考（`AssemblyReference`，对应语法 `AR`）。
    3. 设置排布间距距离（`Distance`，对应语法 `M1`）与法向偏角（`DirectionAngel`，对应语法 `T`）。
    4. 定义端部节点：为 `End1` 与 `End2` 配置 `StiffenerEndConnection`（指定端切形式：齐切、斜切、过渡或搭接肘板）。
    5. 设置材质倾角（`Inclination`，对应 `INC`）与型材规格库代码。
- **节点肘板刚度过渡体系 (Bracket Structural Transition Framework)**:
  - When to use: 在纵桁与肋板交汇处、强框架转角处建立补强肘板。
  - How:
    1. 实例化 `BracketStatement` 并指定宿主板架 `BracketPanel`。
    2. 设置两臂边长（`ArmA`, `ArmB`，可配置过渡圆弧 `ArmC`）。
    3. 设定坡口参数（`Bevel`）与所属结构位置编号（`BNO`）。

## Key Concepts
- **PlateStatement**: 母板语句，定义钢板轮廓、厚度、钢级（如 A36, DH36）及搭接缝。
- **StiffenerStatement**: 型材加筋语句，映射球扁钢（HP）、角钢（L）或T型材（T-bar）在母板上的敷设。
- **StiffenerEnd & StiffenerEndConnection**: 型材端部定义类，细化了型材在两端如何收尾（端部切角代码 Endcut、通孔让位与装配间隙）。
- **BracketStatement**: 肘板语句，专门用于连接梁柱转角、型材断开处的受力过渡构件。
- **ArmA / ArmB / ArmC**: 肘板的几何特征尺寸，A与B对应两直角边搭接长，C对应自由边法向或修圆参数。
- **FlangeStatement**: 面板语句，用于在平钢板（如实肋板、强梁）自由边缘焊接面板构成组合T型梁。
- **PillarStatement**: 支柱语句，定义甲板层间的垂直受压受拉圆管柱或型钢支柱。

## Mental Models
- **Stiffener is a Trajectory on the Canvas**: 筋条是吸附在 `Panel` 画布上的轨迹线，通过 `Distance`（模数间距）和 `End1/End2`（边界约束）确定起止。
- **Bracket as the Bridge**: 肘板是型材与型材之间、型材与垂直板面之间的力学传递桥梁，负责消除应力集中。

## Anti-patterns
- **忽略端部连接定义 (End1 / End2)**: 筋条如果未配置 `StiffenerEndConnection`，在 Tribon 制造模型编译时会报错断裂或干涉，无法通过生产预制校验。
- **直接指定无效的材料规格代码**: 型材规格必须严格匹配船厂当前项目的结构截面库（Profiles Library），传入不存在的规格会导致构件生成失败。

## Code Examples
```csharp
using System;
using Aveva.Core.Database;
using Aveva.Marine.Planar;

namespace Aveva.CustomMarine.PlanarModeling
{
    public class StiffenerBuilderService
    {
        /// <summary>
        /// 为指定分段创建一组等间距纵骨
        /// </summary>
        public void CreateDeckLongitudinals(string panelName, double spacing, int count)
        {
            for (int i = 1; i <= count; i++)
            {
                // 1. 实例化加筋语句
                StiffenerStatement stiffener = new StiffenerStatement();
                stiffener.FunctionalDescription = "DECK_LONGITUDINAL";
                stiffener.Distance = (i * spacing).ToString(); // M1 参数：间距
                stiffener.DirectionAngel = "0";                // T 参数：角度
                stiffener.Inclination = "90";                  // INC 参数：垂直板面

                // 2. 配置端部型切连接
                StiffenerEndConnection end1 = new StiffenerEndConnection();
                // 设定端部型切代码（如 SNIP 切斜、BRACKET 连肘板）
                stiffener.End1 = new StiffenerEnd();
                stiffener.End1.Connection = end1;

                StiffenerEndConnection end2 = new StiffenerEndConnection();
                stiffener.End2 = new StiffenerEnd();
                stiffener.End2.Connection = end2;

                // 3. 打印生成的加筋语句
                Console.WriteLine($"Stiffener #{i}: {stiffener.Statement}");
            }
        }

        /// <summary>
        /// 创建并配置角隅连接肘板
        /// </summary>
        public BracketStatement BuildCornerBracket(string panelName, double armA, double armB)
        {
            BracketStatement bracket = new BracketStatement();
            bracket.BracketPanel = panelName;
            bracket.BracketType = "STANDARD_TRIANGULAR";
            
            // 4. 设定两臂长尺寸
            bracket.A = armA.ToString();
            bracket.B = armB.ToString();

            Console.WriteLine($"Bracket Statement:\n{bracket.Statement}");
            return bracket;
        }
    }
}
```
- **What it demonstrates**: `StiffenerStatement` 的间距倾角设置、端切连接赋值，以及 `BracketStatement` 的尺寸配置。

## Reference Tables

### `StiffenerStatement` 核心字段对照表
| 属性名 | Tribon 语法关键字 | 含义说明 |
|---|---|---|
| `Distance` | `M1` | 距离基准线偏移距离（间距值） |
| `DirectionAngel` | `T` | 铺设偏转角度 |
| `Inclination` | `INC` | 相对母板平面的倾斜角（通常为 90 度） |
| `AssemblyReference` | `AR` | 装配装搭参考基准代码 |
| `End1` / `End2` | `End1` / `End2` | 型材首末端部切角与连接定义 |
| `FunctionalDescription`| - | 功能用途标识（如 LONGITUDINAL, FRAME） |

### `BracketStatement` 核心字段对照表
| 属性名 | 含义说明 |
|---|---|
| `BracketPanel` | 所属安装板架名称 (`BRP`) |
| `A` / `B` | 肘板主装配两臂尺寸（对应 `ArmA` / `ArmB`） |
| `BracketType` | 肘板构型标准库代号（直角三角、带翻边、修圆弧） |
| `Bevel` | 坡口开切工艺参数 |

## Worked Example: 自动批量修复断开型材的端切
1. **遍历查询**: 使用 `DbElement.Members()` 抓取指定 Panel 下所有型材构件。
2. **状态检查**: 转化为 `StiffenerStatement`，读取其 `End1` 和 `End2`。
3. **缺陷检测**: 若发现端部无连接定义（空切），根据与相邻纵骨的间距自动补偿标准斜切（Sniped Cut）参数。
4. **提交更新**: 重新生成 Statement 语句并更新回数据库。

## Key Takeaways
1. 型材加筋（Stiffener）在造船工程中数量极大，其定位严格基于板架局部坐标系的 `Distance`（M1）与 `DirectionAngel`（T）。
2. 端切（`StiffenerEndConnection`）决定了下料车间等离子割枪的切割轨迹，切勿遗漏。
3. 肘板（Bracket）需紧密依托母板 `BracketPanel`，是控制船体疲劳寿命与结构刚度的核心节点。
4. 所有类继承自 `IDisposable` 并提供完整 `Statement` 序列化输出。

## Connects To
- **Ch 08**: [ch08-planar-fundamentals-and-panels.md](ch08-planar-fundamentals-and-panels.md)（所有构件依附于 PanelStatement 存在）
- **Ch 07**: [ch07-marine-welding-and-production.md](ch07-marine-welding-and-production.md)（型材与母板相焊产生焊缝 `MarWeldedJoint`）
- **Ch 10**: [ch10-planar-features-cuts-holes-welds.md](ch10-planar-features-cuts-holes-welds.md)（为板件与型材开设流通孔与流水孔）
