# Chapter 10: Planar Manufacturing Features, Penetrations, Advanced Statements & PML Wrappers

## Core Idea
造船生产制造要求板件具备详尽的工艺特征细节；`Aveva.Marine.Planar` 不仅提供了包括人孔与减重孔（`HoleStatement`）、流水/透气切口（`NotchStatement`）、板缝（`SeamStatement`）、余量（`ExcessStatement`）与焊接收缩（`ShrinkageStatement`）在内的全套工艺特征，还涵盖了波形舱壁压折（`SwageStatement`）、孔切卡马复合语句（`HNCStatement`）、开孔补强板（`CompensationStatement`）、加强筋卡马夹板（`Clip`）与穿越附件（`TAPStatement`），并通过 `Aveva.Marine.Planar.PML` 包装层使传统 PML 脚本能够直接调用平面语句模型。

## Frameworks Introduced
- **工艺贯穿孔与切口全要素建模框架 (Penetration & Notch Feature Framework)**:
  - When to use: 在肋板、隔舱或纵桁上开设人孔（Manhole）、管系电缆贯穿孔（Penetrations）或流水孔/通气孔（Drain/Air Scallops）。
  - How:
    1. 声明 `HoleStatement` 或 `NotchStatement`。
    2. 设置孔型枚举（如 `EnHoleType`、`EnCutOutType`）。
    3. 指定定位基准（`EnHoleLocationType`）与空间中心坐标。
    4. 设定几何参数（长、宽、倒角半径或开孔标准图号）。
    5. 设置补强环或面板（若开孔带补强圈）。
- **结构局部补强与波形折边建模体系 (Compensation & Swage Structural System)**:
  - When to use: 油轮/散货船波形横舱壁（Corrugated Bulkhead）建模、开孔高应力区的补强环板（Compensation Plate）装配。
  - How:
    1. 使用 `SwageStatement` 指定波形压折的节距、波高、斜角与过渡半径。
    2. 使用 `CompensationStatement` 绑定宿主开孔（`Hole`），配置补强板材质、厚度与搭接形式。
- **造船复合装配特征管道 (HNC & Clip Assembly Pipeline)**:
  - When to use: 纵骨穿过水密肋板或强框架时的防倾覆与密封节点（开孔 + 切口 + 嵌条夹板三合一）。
  - How: 声明 `HNCStatement` 或组合 `Clip`（卡马嵌条）封闭骨材穿越孔周围的间隙。
- **造船制造工艺余量补偿体系 (Production Allowance & Shrinkage Pipeline)**:
  - When to use: 为船体零件下料预留焊接热收缩量或合拢修割余量（Green Margin）。
  - How: 使用 `ShrinkageStatement` 定义板向或骨向收缩系数，使用 `ExcessStatement` 指定指定边界边缘的放量数值。

## Key Concepts
- **HoleStatement**: 开孔语句，包含人孔、减重孔、管隧通过孔及各类标准化孔型。
- **NotchStatement**: 切口/凹口语句，通常指骨材穿越板件时的包板切口或角隅释放孔（Corner Relief）。
- **CutStatement**: 轮廓切除语句，定义板件端部的大范围几何修剪。
- **CompensationStatement**: 补强补偿语句，专门用于在受力集中的开孔边缘或板件局部敷设补强板（Doubling Plate）。
- **SwageStatement**: 压折/波折板语句，用于无骨架波形舱壁（Swaged Bulkhead）的参数化折压。
- **HNCStatement**: Hole-Notch-Clip 三合一复合语句，将型材穿板孔、端部型切和密封夹板一次性完成拓扑绑定。
- **Clip**: 夹板/卡马语句，用于跨接在穿越型材腹板与母板之间，恢复被切削母板的剪切传力刚度。
- **TAPStatement**: Tool / Attachment / Penetration 工艺穿越件语句，定义电缆管穿舱套管或工艺装配吊环孔。
- **ParallelCurveStatement**: 平行曲线语句，沿外板、平直边或参考基准线生成指定偏移距的几何轨迹线。
- **SeamStatement**: 板缝语句，定义母板如何被对接缝切分为多块单板（如 A-1, A-2）。
- **BeadStatement**: 压筋/防波筋语句，薄板上的冲压加强筋或焊道加强。
- **MarkingStatement**: 划线/工艺标记语句，指示数控切割机打标喷印骨材装配参考线、流水孔位置。
- **ShrinkageStatement**: 焊接收缩补偿语句，按百分比或绝对量拉伸零件下料外形。
- **ExcessStatement**: 余量语句，在分段大合拢边缘保留的修割“绿边”（Green Margin）。
- **Aveva.Marine.Planar.PML**: 专门为 PML 提供运行时代理解析的子命名空间，提供 `BracketArm`, `Clip`, `FlangeEnd`, `PillarEnd`, `Point`, `StiffenerEnd`, `StiffenerEndConnection`, `StiffenerStatement` 的 PML 代理。

## Mental Models
- **Holes and Notches as Boolean Subtractions with Semantics**: 开孔不仅是几何上的“挖空”，它携带了造船工艺语义（水密要求、补强规范、检验标准）。
- **Compensation as Strength Restorer**: 开孔破坏了板架整体连续性，`CompensationStatement` 负责在数字模型中重新建立受力闭环。
- **Swage as Self-Stiffening Geometry**: 波形折边利用几何截面二次惯性矩代替了传统焊接骨材，`SwageStatement` 直接定义了板材的几何折弯模态。
- **Shrinkage and Excess as Reality Absorbers**: 计算机里的模型是理想尺寸，制造特征（`Shrinkage`/`Excess`）是在虚拟模型与车间热加工变形之间建立的数字缓冲区。

## Anti-patterns
- **开孔边缘距离型材或板边太近**: 违反造船规范的最小搭接边距要求；程序生成 `HoleStatement` 时必须预先计算与临近 `StiffenerStatement` 的净距防碰撞检测。
- **大开孔未配置 CompensationStatement 导致有限元应力超标**: 在横梁大减重孔或甲板人孔处，若未按图纸规程配置补强环，直接送交生产下料会导致现场返工贴板。
- **漏记板缝 SeamStatement 导致无法套料**: 钢厂供货板材尺寸有限（如宽 2.5m 或 3m），若未用 `SeamStatement` 切分母板，板件将超出最大钢板尺寸无法参与数控套料排版。

## Code Examples
```csharp
using System;
using Aveva.Marine.Planar;

namespace Aveva.CustomMarine.PlanarFeatures
{
    public class AdvancedFeatureBuilderService
    {
        /// <summary>
        /// 在大受力开孔处建立标准化补强板 (CompensationStatement)
        /// </summary>
        public CompensationStatement ReinforceManhole(string panelName, string holeRef, double thickness, string steelGrade)
        {
            CompensationStatement comp = new CompensationStatement();
            // 1. 关联宿主孔与材质参数
            Console.WriteLine($"Adding Compensation Plate to Hole {holeRef} on Panel {panelName}");
            Console.WriteLine($"Thickness: {thickness}mm, Grade: {steelGrade}");
            
            return comp;
        }

        /// <summary>
        /// 创建波形舱壁折折语句 (SwageStatement)
        /// </summary>
        public SwageStatement BuildCorrugatedBulkhead(string panelName, double pitch, double depth, double angle)
        {
            SwageStatement swage = new SwageStatement();
            // 2. 配置波形几何参数：节距、波深与折角
            Console.WriteLine($"Configuring Swaged Bulkhead {panelName}: Pitch={pitch}mm, Depth={depth}mm, Angle={angle}°");
            
            return swage;
        }

        /// <summary>
        /// 声明管系电缆穿越件与工具孔 (TAPStatement)
        /// </summary>
        public TAPStatement AddPipePenetration(string panelName, string pipeSystemId, double nominalDiameter)
        {
            TAPStatement tap = new TAPStatement();
            // 3. 关联贯穿件系统与通径
            Console.WriteLine($"Configuring TAP for {pipeSystemId} (DN{nominalDiameter}) on Panel {panelName}");
            
            return tap;
        }

        /// <summary>
        /// 为分段大合拢边缘添加 50mm 预留修割余量 (Green Margin)
        /// </summary>
        public ExcessStatement AddWeldingMargin(string panelName, int boundaryEdgeIndex, double marginMm)
        {
            ExcessStatement excess = new ExcessStatement();
            Console.WriteLine($"Adding {marginMm}mm Excess to boundary edge #{boundaryEdgeIndex} on {panelName}");
            return excess;
        }
    }
}
```

## Reference Tables

### `Aveva.Marine.Planar` 全部结构与制造特征类型全览 (34 类)
| 类型名称 | 分类 | 核心职责 |
|---|---|---|
| `PanelStatement` | 基础容器 | 平面分段/板架画布核心定义 |
| `PlaneStatement` | 几何基准 | 确定板架在全船（FR/LP/WL）绝对参考系姿态 |
| `BoundaryStatement` | 轮廓边界 | 外轮廓封闭与修剪条件集合 |
| `PlateStatement` | 承载构件 | 母板几何外形、板厚与钢级材质 |
| `DoublePlateStatement` | 承载构件 | 双层底/夹层板专用复合板架 |
| `StiffenerStatement` | 骨骼体系 | 型材加筋（纵骨/肋骨）排布与规格 |
| `StiffenerEnd` | 节点连接 | 加筋起止端部几何定义 |
| `StiffenerEndConnection` | 节点连接 | 型材端部型切代码、装配间隙与连接形式 |
| `BracketStatement` | 节点补强 | 梁柱连接过渡肘板 |
| `BracketArm` | 节点补强 | 肘板两搭接臂几何参数 |
| `FlangeStatement` | 构件面板 | 平钢板自由边焊接面板（组合梁面板） |
| `FlangeEnd` | 构件面板 | 面板端部修切定义 |
| `PillarStatement` | 垂直支撑 | 甲板层间垂直支柱 |
| `PillarEnd` | 垂直支撑 | 支柱端部连接形式 |
| `HoleStatement` | 工艺开孔 | 人孔、轻型孔、管隧通过孔 |
| `NotchStatement` | 工艺切口 | 穿越切口、流水孔（Drain）、透气孔（Air） |
| `CutStatement` | 边界修整 | 倒角切除与端部大范围几何修剪 |
| `CompensationStatement` | 结构补强 | 开孔边缘补强环板（Doubling Plate） |
| `SwageStatement` | 特殊板构 | 波形舱壁折弯受力折肋（Swage） |
| `HNCStatement` | 复合特征 | Hole-Notch-Clip 三合一复合穿越孔切卡马 |
| `Clip` | 节点卡马 | 穿越型材腹板加劲密封夹板 |
| `TAPStatement` | 工艺穿越 | 工具孔、装配吊环与穿越附件（Tool/Attach/Penetration） |
| `ParallelCurveStatement` | 几何辅助 | 沿曲面/自由边偏移的平行参考轨迹线 |
| `LimitStatement` | 边界限制 | 板架与构件的边界限制条件 |
| `NumericalStatement` | 参数特征 | 参数化数字特征定义 |
| `PointStatement` | 几何点位 | 参数化空间点位声明 |
| `Point` | 几何点位 | 二维/三维坐标点辅助类 |
| `SeamStatement` | 分块套料 | 母板拼板缝，将板架细化为单板拼焊清单 |
| `BeadStatement` | 薄板防波 | 冲压防波加强筋/连续焊道加强 |
| `MarkingStatement` | 数控加工 | 切割机打标划线、装配位置标识、字码喷印 |
| `ExcessStatement` | 合拢装配 | 合拢缝加放余量（Green Margin，通常 50~100mm） |
| `ShrinkageStatement` | 焊接补偿 | 补偿焊缝冷却造成的板长与间距收缩 |
| `WeldStatement` | 装配焊接 | 声明平对接缝、角接缝的焊接参数 |
| `ComponentHelper` | 辅助导航 | 板架名称与构件分组逆向导航辅助类 |

### 关键工艺枚举类集合 (`En...`)
- `EnHoleType`: 开孔构型枚举（圆形、椭圆、腰鼓形、圆角矩形）
- `EnCutOutType`: 穿孔切口类型枚举
- `EnNotType`: 凹槽与流水孔类别枚举
- `EnDirectionType`: 偏转方位枚举
- `EnWatertightType`: 水密级别枚举

## Worked Example: 自动化为水密横舱壁添加流水与透气孔
1. **获取横舱壁**: 定位到舱壁 `PanelStatement` 及其底部的 `StiffenerStatement` 集合。
2. **计算孔位**:
   - 在每根型材靠近双层底顶部板处计算流水孔位置。
   - 在型材靠近上方甲板底部处计算透气孔位置。
3. **批量构建**:
   ```csharp
   foreach (var stiffener in stiffeners)
   {
       var notch = new NotchStatement();
       // 设定为标准 SCALLOP 构型并关联至当前筋条
   }
   ```
4. **编译验证**: 检查是否与母板接缝冲突，确认无误后提交更新。

## Key Takeaways
1. 制造特征语句（Hole, Notch, Compensation, Swage, Seam, Excess, Shrinkage）是让 3D 几何转变为实际造船下料图纸的不可或缺要素。
2. 对于波形舱壁，使用 `SwageStatement` 声明几何折弯，避免手工切割拼接虚拟骨材。
3. `CompensationStatement` 弥合了开孔后的结构刚度损耗，是三维出图送审的关键数据。
4. `Aveva.Marine.Planar.PML` 提供了双向兼容性，使老旧 PML 工具库无需全面重构即可复用强大的 Planar 现代语句引擎。

## Connects To
- **Ch 08**: [ch08-planar-fundamentals-and-panels.md](ch08-planar-fundamentals-and-panels.md)（所有开孔与特征均依附于 Panel）
- **Ch 09**: [ch09-planar-plates-stiffeners-brackets.md](ch09-planar-plates-stiffeners-brackets.md)（与 Plate、Stiffener 形成开孔避让与打断拓扑）
- **Ch 07**: [ch07-marine-welding-and-production.md](ch07-marine-welding-and-production.md)（板缝 SeamStatement 派生出装配焊缝 MarWeld）
- **Planar Ref**: [../references/planar-api-reference.md](../references/planar-api-reference.md)（查看全部 34 个 Planar Statement 类与 29 个枚举属性清单）
