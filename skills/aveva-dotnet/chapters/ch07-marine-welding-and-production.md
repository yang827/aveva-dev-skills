# Chapter 7: Marine Welding & Production Automation

## Core Idea
`Aveva.Marine.Welding` 与 `Aveva.Marine.Production` 命名空间构成了从三维船体设计向车间加工制造（CAM/Production）转化的关键管道；`MarWeld` 与 `MarWeldedJoint` 实现了焊缝全要素（长度、坡口、焊角尺寸）的精确量化提取，而 `MarPinProfiles` 则支持曲面外板胎架活络样箱（Pin Jigs）与加工草图的自动化生成。

## Frameworks Introduced
- **焊缝量化与工艺追溯体系 (Weld Quantification & Traceability Framework)**:
  - When to use: 统计分段/总段焊缝总长、评估焊接工时、输出焊工焊接工艺规程（WPS）匹配表或导出自动化焊接机器人轨迹数据时。
  - How:
    1. 引入 `Aveva.Marine.Welding` 命名空间。
    2. 使用 `MarWeldedJoint` 分析两个相接构件（如底板与纵骨、舱壁与甲板）之间的装配连接。
    3. 获取具体 `MarWeld` 对象，读取几何长度、焊脚尺寸、坡口类型与材质参数。
    4. 结合 `MarWeldTable` 校验工厂标准工艺规程。
- **制造装配与胎架生成管道 (Fabrication Pin Jig & Sketch Pipeline)**:
  - When to use: 曲面分段拼板胎架（Pin Jig）高度矩阵计算，以及零件下料加工草图的程序化绘制。
  - How: 实例化 `MarPinProfiles`，针对目标曲面外板调用 `GenerateSketch()` 提取离散化活络柱高度与倾角。

## Key Concepts
- **MarWeld**: 单条焊缝的物理与工艺实体描述，封装了焊缝起止坐标、焊缝类型（对接焊、角焊、搭接焊）、焊脚厚度与焊接方法。
- **MarWeldedJoint**: 焊接接头实体，表达多构件之间的装配连接关系及由该连接派生的一组焊缝。
- **MarWeldMod**: 焊缝修改参数，用于对自动生成的焊缝进行人工工艺修正（如局部开止裂孔、调整开坡口方向）。
- **MarWeldTable**: 焊接工艺标准数据库表，映射母材、板厚到标准焊接参数（电流、焊道层数、间隙）。
- **MarPinProfiles**: 曲面外板活络样箱（Pin Bed / Pin Jig）轮廓生成引擎，用于计算胎架撑杆的理论高度。
- **GenerateSketch**: 生产辅助方法，自动生成零件的 2D 轮廓投影草图与加工制造标识。

## Mental Models
- **Joint is the Context, Weld is the Seam**: `MarWeldedJoint` 关注的是“谁和谁焊在一起”，而 `MarWeld` 关注的是“这条缝沿着哪条曲线跑、填了多少焊肉”。
- **Design Model to Shop-Floor Reality**: 设计人员创建的是几何边界，生产工程师关心的是下料加放（Shrinkage/Excess）与焊缝工时；本模块即是弥合这两者的数字化纽带。

## Anti-patterns
- **直接依据几何相交线粗暴估算焊缝**: 结构件可能存在坡口钝边、装配间隙或局部脱开，通过纯几何布尔线计算无法反映实际造船焊接量；应始终提取 `MarWeldedJoint` 获得合规的工程焊接对象。
- **忽略接头的 IDisposable 释放**: 在分段成千上万条焊缝扫描遍历时，每个 `MarWeld` 对象都要及时析构，避免造成严重的非托管堆内存暴涨。

## Code Examples
```csharp
using System;
using Aveva.Marine.Welding;
using Aveva.Marine.Production;

namespace Aveva.CustomMarine.Production
{
    public class WeldAndFabricationManager
    {
        /// <summary>
        /// 遍历并统计焊接接头的关键工艺参数
        /// </summary>
        public void InspectWeldedJoint(MarWeldedJoint joint)
        {
            if (joint == null) return;

            try
            {
                // 1. 查询接头基础属性
                Console.WriteLine("Inspecting MarWeldedJoint...");

                // 2. 模拟从接头提取焊缝细节
                using (MarWeld weld = new MarWeld())
                {
                    // 假设已将 weld 关联至当前 joint
                    // 读取焊缝长度、工件厚度与坡口类型
                    Console.WriteLine("Weld seam properties successfully queried.");
                }
            }
            finally
            {
                // 3. 必须释放接头包装
                joint.Dispose();
            }
        }

        /// <summary>
        /// 针对外板曲面生成生产胎架柱高度草图
        /// </summary>
        public void GeneratePinJigProfiles()
        {
            using (MarPinProfiles pinProfile = new MarPinProfiles())
            {
                // 4. 调用胎架草图生成引擎
                pinProfile.GenerateSketch();
                Console.WriteLine("Pin jig profiles and fabrication sketches generated successfully.");
            }
        }
    }
}
```
- **What it demonstrates**: `MarWeldedJoint` 和 `MarWeld` 的工艺参数探测，以及使用 `MarPinProfiles` 生成车间胎架与下料加工草图。

## Reference Tables

### `Aveva.Marine.Welding` 核心类型表
| 类型名称 | 核心职责 |
|---|---|
| `MarWeld` | 表达单条实体焊缝的工艺与几何特征 |
| `MarWeldedJoint` | 表达两个或多个造船构件之间的相交焊接节点 |
| `MarWeldMod` | 焊缝手工干预与修整参数 |
| `MarWeldTable` | 船厂焊接工艺规范查询库（WPS 标准匹配表） |

### `Aveva.Marine.Production` 核心类型表
| 类型名称 | 核心职责 |
|---|---|
| `MarPinProfiles` | 胎架活络柱高度计算与型线阵列成形引擎 |
| `GenerateSketch()` | 自动导出下料草图、零件加工图与坡口标注 |

## Worked Example: 自动化统计分段焊缝清单
1. **分段构件扫描**: 通过 `MarDataBase.ObjectListGet` 抓取某分段下的全部板件和型材。
2. **构建接头拓扑**: 调用焊接检测算法提取所有相邻构件的 `MarWeldedJoint` 集合。
3. **遍历汇总**:
   - 提取每个接头关联的 `MarWeld`。
   - 累加角焊缝（Fillet Weld）与对接焊缝（Butt Weld）的总米数。
   - 根据板厚档次计算等效碳钢焊丝消耗量。
4. **输出报表**: 结合第 4 章介绍的 `GridControl` 呈现给造船工法工程师，并导出 Excel。

## Key Takeaways
1. 焊缝信息是 AVEVA Marine 区分于普通通用 CAD 软件的核心造船特色属性，包含深层次工艺标准。
2. `MarWeldedJoint` 承载了零件之间的装配逻辑关系，是数字化车间装配顺序排产的数据底座。
3. `MarPinProfiles` 是曲面分段下料与拼装必不可少的专用计算工具，省去人工放样耗时。
4. 生产制造端 API 产生的数据体积庞大，一定要配合批量回收机制进行流式处理。

## Connects To
- **Ch 04**: [ch04-ui-controls-grid-mydata.md](ch04-ui-controls-grid-mydata.md)（在 GridControl 中展示焊缝明细表与导出 Excel）
- **Ch 05**: [ch05-marine-utility-and-objects.md](ch05-marine-utility-and-objects.md)（基于 Marine Utility 的实体基础）
- **Ch 09**: [ch09-planar-plates-stiffeners-brackets.md](ch09-planar-plates-stiffeners-brackets.md)（为板架与骨材赋予焊缝特征）
