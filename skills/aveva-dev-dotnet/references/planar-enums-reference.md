# AVEVA Marine Planar Enums & Classification Reference (`Aveva.Marine.Planar.PML`)

本手册系统收录源自 `netaveva.marine.planarapi.pdf`（第 351 ~ 539 页）的全部 **29 个 PMLNet 枚举分类与工厂类**。

---

## 1. PMLNet 枚举机制架构说明

在 AVEVA Marine Planar API 中，为了支持 PML 解释器对强类型枚举（Enumerations）的安全调用，系统在 `Aveva.Marine.Planar.PML` 命名空间下为每个分类概念构建了一个**托管包装类（PMLNet Proxy Class）**。

### 1.1 PML 调用规范
PML 无法直接使用 C# 的 `enum` 语法，必须通过对象实例化并调用对应的**无参状态方法**进行赋值：
```pml
-- 导入 Planar PML 命名空间
using namespace 'Aveva.Marine.Planar.PML'

-- 创建侧向方向枚举并设为左舷 (Portside)
!side = object EnSide()
!side.Ps()

-- 创建开孔构型枚举并设为板上开孔 (Plate)
!holeType = object EnHoleType()
!holeType.Plate()

-- 传递给 Planar 语句对象
!holeStatement.HoleType = !holeType
```

### 1.2 C# 托管调用规范
在 C# 中既可以直接调用此类对象，也可以通过方法链式初始化：
```csharp
using Aveva.Marine.Planar.PML;

EnSide side = new EnSide();
side.Ps(); // 设置为 Portside

EnHoleType holeType = new EnHoleType();
holeType.Plate(); // 设置为板图元开孔
```

---

## 2. 全部 29 个枚举与分类工厂类全集

### 2.1 基础与通用分类

#### `ColourType`
- **说明**: 几何特征与标注线条的颜色分类。
- **合法值/方法列表**:
  - `Black()`: 黑色
  - `Blue()`: 蓝色
  - `Cyan()`: 青色
  - `Default()`: 默认系统色
  - `Green()`: 绿色
  - `Magenta()`: 品红/洋红色
  - `Red()`: 红色
  - `White()`: 白色
  - `Yellow()`: 黄色
  - `Ambiguous()`: 未定/歧义颜色
- **通用方法**: `Assign(ColourType that)`, `ToString()`

#### `CoordinateSuffix`
- **说明**: 局部坐标或理论模线后缀类型。
- **合法值/方法列表**:
  - `MAX()`: 最大值边界
  - `MIN()`: 最小值边界
  - `ONE()`: 第一基准 (1)
  - `TWO()`: 第二基准 (2)
  - `T()`: 理论切线/厚度方向
- **通用方法**: `Assign(CoordinateSuffix that)`, `ToString()`

#### `EnCoordType`
- **说明**: 平面几何投影坐标轴向与基准面定义。
- **合法值/方法列表**:
  - `U()`: 局部 U 轴
  - `V()`: 局部 V 轴
  - `UV()`: 局部 UV 平面复合坐标
  - `X()`: 船体全局 X 轴（长向）
  - `Y()`: 船体全局 Y 轴（横向）
  - `Z()`: 船体全局 Z 轴（垂向）
  - `XY()`, `XZ()`, `YZ()`, `XYZ()`: 组合坐标系投影
  - `Undefined()`: 未定义坐标系
- **通用方法**: `Assign(EnCoordType that)`, `ToString()`

#### `EnDirectionType`
- **说明**: 船体三维相对航向与方位对齐定义。
- **合法值/方法列表**:
  - `For()`: 船首向 (Forward)
  - `Aft()`: 船尾向 (Aft)
  - `Top()`: 向上 (Top)
  - `Bot()`: 向下 (Bottom)
  - `SB()`: 右舷向 (Starboard)
  - `Both()`: 双向
  - `NotSet()`: 未设置
  - `Ambiguous()`: 歧义/未决朝向
- **通用方法**: `Assign(EnDirectionType that)`, `ToString()`

#### `EnSide`
- **说明**: 结构板架与型材的理论参考面（主尺度侧向）。
- **合法值/方法列表**:
  - `Ps()`: 左舷侧 (Portside)
  - `For()`: 船首侧 (Forward)
  - `Aft()`: 船尾侧 (Aft)
  - `Top()`: 顶部/顶面侧 (Top)
  - `Bot()`: 底部/底面侧 (Bottom)
- **通用方法**: `Assign(EnSide that)`, `ToString()`

#### `EnDistanceType`
- **说明**: 尺寸偏移与距离计算基准度量方式。
- **合法值/方法列表**:
  - `AlongLine()`: 沿基准直线度量
  - `PerpToLimit()`: 垂直于限制边界度量
  - `Ambiguous()`: 未决度量
- **通用方法**: `Assign(EnDistanceType that)`, `ToString()`

#### `EnValueType`
- **说明**: 参数化数值与位置解析格式定义。
- **合法值/方法列表**:
  - `ValueX()`, `ValueY()`, `ValueZ()`: 全局直角坐标值
  - `ValueU()`, `ValueV()`: 平面局部投影坐标值
  - `ValueT()`, `ValueT1()`, `ValueT2()`: 曲线插值归一化参数 [0, 1]
  - `ValueVAL()`: 显式绝对标量数值
  - `ValueEXP()`: 动态计算公式表达式 (Expression)
  - `ValueAmbigous()`: 无法解析的歧义值
- **通用方法**: `Assign(EnValueType that)`, `ToString()`

#### `EnWatertightType`
- **说明**: 舱壁、开孔与贯穿结构的密性等级定义。
- **合法值/方法列表**:
  - `Watertight()`: 水密 (Watertight)
  - `NotWatertight()`: 非水密 (Non-watertight)
  - `NotSet()`: 未定义密性
- **通用方法**: `Assign(EnWatertightType that)`, `ToString()`

---

### 2.2 几何点、线、面与轮廓分类

#### `EnPointType`
- **说明**: 平面空间几何拓扑点的定位类型。
- **合法值/方法列表**:
  - `Corner()`: 轮廓折角点
  - `Curve()`: 曲线控制/通过点
  - `ExplGiven()`: 显式给定三维坐标点
  - `Intersect()`: 两几何边界线相交生成的交点
  - `ProfEnd()`: 型材端点
  - `SeamEnd()`: 分段拼板缝端点
  - `PipeCross()`: 管系穿舱交点
  - `PrCross()`: 结构型材十字相交点
  - `None()`, `Ambiguous()`: 空点或未决点
- **通用方法**: `Assign(EnPointType that)`, `ToString()`

#### `EnCType`
- **说明**: 轮廓边界曲线的生成拟合算法。
- **合法值/方法列表**:
  - `CTypeX()`: 约束 X 坐标插值曲线
  - `CTypeY()`: 约束 Y 坐标插值曲线
  - `CTypeZ()`: 约束 Z 坐标插值曲线
  - `CTypeAmbigous()`: 自动判断或未定插值
- **通用方法**: `Assign(EnCType that)`, `ToString()`

#### `EnLocationType`
- **说明**: 板缝与结构要素的相对定位法则。
- **合法值/方法列表**:
  - `Arms()`: 基于肘板双臂跨距定位
  - `ExplPos()`: 显式指定三维绝对坐标
  - `Move()`: 相对偏移平移定位
  - `Plane()`: 基准平面投射定位
  - `Undefined()`: 未定义
- **通用方法**: `Assign(EnLocationType that)`, `ToString()`

#### `EnIncType`
- **说明**: 倾斜边界与型材的倾角计入模式。
- **合法值/方法列表**:
  - `AlongLimit()`: 沿边界限制法向投射倾角
  - `AlongLine()`: 沿参考线倾角
  - `Ambiguous()`: 歧义计算
- **通用方法**: `Assign(EnIncType that)`, `ToString()`

---

### 2.3 边界限制与参考分类

#### `EnLimitType`
- **说明**: 板架周边边界（Boundary）的几何截断形式。
- **合法值/方法列表**:
  - `Line()`: 空间理论直线截断
  - `Curve()`: 空间样条曲线截断
  - `Free()`: 自由无约束边缘 (Free edge)
  - `IntPan()`: 相交内部板架截断 (Intersecting panel)
  - `PlPan()`: 共面邻接板架截断
  - `Plane()`: 理论坐标基准面截断
  - `PrCross()`: 跨截面型材相交边界
  - `PrOverl()`: 型材搭接边缘
  - `Surface()`: 曲面外板曲率限制
- **通用方法**: `Assign(EnLimitType that)`, `ToString()`

#### `EnLimitRefType`
- **说明**: 边界限制所挂接的参考图元类型。
- **合法值/方法列表**:
  - `BR()`: 参考肘板 (Bracket)
  - `F()`: 参考面板 (Flange)
  - `L()`: 参考纵骨号 (Longitudinal)
  - `LIM()`: 参考通用限制线 (Limit)
  - `PI()`: 参考支柱 (Pillar)
  - `PIPE()`: 参考管系外轮廓
  - `S()`: 参考骨材 (Stiffener)
  - `SEA()` / `Seam()`: 参考拼板缝 (Seam)
  - `SF()`: 参考肋位肋骨框架号 (Frame position)
  - `SLM()`: 负向肋位骨材参考
  - `ST()`: 用户自定义 Tag 标签骨材
  - `T()`: 参考横向肋板 (Transversal)
  - `Undefined()`: 未定义参考
- **通用方法**: `Assign(EnLimitRefType that)`, `ToString()`

#### `EnReferencedType`
- **说明**: 结构建模关联引用的三维对象大类。
- **合法值/方法列表**:
  - `B()` / `Bou()`: 外部边界轮廓 (Boundary)
  - `Bt()`: 支托/肘板 (Bracket)
  - `CPanel()`: 曲面板 (Curved panel)
  - `Curve()`: 任意自由曲线
  - `D()`: 甲板面 (Deck)
  - `ExtBr()`, `ExtF()`, `ExtLim()`, `ExtProf()`, `ExtS()`: 外部引入的肘板、面板、限制线、型材、骨材
  - `FR()`: 船体肋位框架 (Frame)
  - `INT()`: 内部交线
  - `Long()`: 纵桁/纵骨
  - `Panel()`: 关联板架
  - `Pipe()`: 穿舱管线
  - `Plane()`: 理论平面
  - `Seam()`: 板缝
  - `Surface()`: 外板曲面
  - `Trans()`: 横向构件
  - `WL()`: 船体设计水线 (Waterline)
  - `Undefined()`, `Ambiguous()`: 未定义或未决
- **通用方法**: `Assign(EnReferencedType that)`, `ToString()`

#### `EnRefType`
- **说明**: 通用特征定位参考子类型。
- **合法值/方法列表**:
  - `RefHole()`: 关联孔洞中心
  - `RefNotch()`: 关联切口/流水孔
  - `RefPillarPad()`: 关联支柱加强垫板
  - `RefAmbigous()`: 歧义参考
- **通用方法**: `Assign(EnRefType that)`, `ToString()`

---

### 2.4 开孔、切口与 HNC 加工特征分类

#### `EnHoleType`
- **说明**: 穿舱孔/工艺开孔的主体图元宿主类型。
- **合法值/方法列表**:
  - `Plate()`: 开在板架/板图元上
  - `Stiffener()`: 开在型材/骨材腹板上
- **通用方法**: `Assign(EnHoleType that)`, `ToString()`

#### `EnHoleLocationType`
- **说明**: 开孔中心位置的定位基准方式。
- **合法值/方法列表**:
  - `Center()`: 局部区域绝对几何中心
  - `AlongLimit()`: 沿边界限制线偏移定位
  - `AsStored()`: 沿用数据库已存的原始几何坐标
  - `NotSet()`, `Ambiguous()`: 未设置或未决
- **通用方法**: `Assign(EnHoleLocationType that)`, `ToString()`

#### `EnHoleRefType`
- **说明**: 开孔基准所依赖的相邻构件类型。
- **合法值/方法列表**:
  - `Pillar()`: 依赖支柱中心线
  - `Seam()`: 依赖邻近拼板缝
  - `Undefined()`: 无关联构件
- **通用方法**: `Assign(EnHoleRefType that)`, `ToString()`

#### `EnCutOutType`
- **说明**: 骨材穿过板架或相交时的切口几何构型。
- **合法值/方法列表**:
  - `CutInPlate()`: 在主板上开出切口让骨材穿过
  - `CutInSti()`: 在骨材腹板上开出切口以避让构件
  - `CutIntCrossPan()`: 交叉相交板架处的贯通切口
  - `CutoutTypeAuto()`: 依据标准规则库自动判定切口形式
  - `Ambigous()`: 未决切口
- **通用方法**: `Assign(EnCutOutType that)`, `ToString()`

#### `EnHNCType`
- **说明**: HNC (Hull NC) 数控下料加工特征类型。
- **合法值/方法列表**:
  - `Hole()`: 标准数控切割孔
  - `HoleRef()`: 带依赖参考的切割孔
  - `Cutout()`: 构件边缘切口
  - `CutoutRef()`: 带依赖参考的边缘切口
  - `Notch()`: 排水/排气流水孔
  - `NotchRef()`: 带依赖参考的流水孔
- **通用方法**: `Assign(EnHNCType that)`, `ToString()`

#### `EnNotType`
- **说明**: 切口/缺口（Notch）的受体类型。
- **合法值/方法列表**:
  - `Plate()`: 开在板边缘
  - `Stiffener()`: 开在骨材端部/腹板
- **通用方法**: `Assign(EnNotType that)`, `ToString()`

#### `EnNotLocationType`
- **说明**: 切口（Notch）在结构边缘的布置定位准则。
- **合法值/方法列表**:
  - `LocAtCorner()`: 布置在板角折角拐点处
  - `LocAtLines()`: 布置在相交特征线交汇点
  - `LocAtSeam()`: 布置在拼板缝与边缘相交处
  - `LocAtSeamInt()`: 布置在两板缝相交点
  - `LocAlongLimit()`: 沿边界线指定间距布置
  - `LocByDistance()`: 沿几何线按绝对距离布置
  - `LocCurve()`: 沿样条曲线布置
  - `LocForSeam()`: 专为对接焊缝让位布置
  - `LocAsStored()`, `LocNotSet()`, `LocAmbiguous()`: 继承已存、未设或未决
- **通用方法**: `Assign(EnNotLocationType that)`, `ToString()`

---

### 2.5 骨材、面板与端部连接分类

#### `EnFlangeType`
- **说明**: 型材面板或折边类型。
- **合法值/方法列表**:
  - `Folded()`: 折边面板（由板直接弯折形成的折边）
  - `Welded()`: 焊接面板（由独立扁钢焊接而成的 T 型/L 型面板）
- **通用方法**: `Assign(EnFlangeType that)`, `ToString()`

#### `EnMouldLineType`
- **说明**: 骨材与板架的理论模线对齐基准（决定骨材偏向）。
- **合法值/方法列表**:
  - `MouAloLine()`: 沿理论直线对齐
  - `MouAloCurve()`: 沿理论三维曲线对齐
  - `MouEndPts()`: 由起止两端点连线决定模线
  - `MouConSti()`: 沿连续贯通骨材模线对齐
  - `MouPLLHole()`: 与孔洞轮廓平行对齐
  - `MouPLLHoleTan()`: 与孔洞切线平行对齐
  - `MouPLLLim()`: 与外边界限制线平行对齐
  - `MouPLLLimTan()`: 与外边界切线平行对齐
  - `MouNotSet()`, `MouAmbiguous()`: 未设或未决
- **通用方法**: `Assign(EnMouldLineType that)`, `ToString()`

#### `EnProfConType`
- **说明**: 型材与骨材交叉或相遇时的空间拓扑连接形式。
- **合法值/方法列表**:
  - `Along()`: 顺向顺接连接
  - `Cross()`: 十字贯通交叉
  - `Overlap()`: 端部搭接连接
  - `Undefined()`: 未定义
- **通用方法**: `Assign(EnProfConType that)`, `ToString()`

#### `StiffenerEndType`
- **说明**: 骨材端切标准库代号转换工具类。
- **核心方法**:
  - `FromString(string typeCode)`: 从标准库代号（如 `"SN1"`, `"CUT2"`）转换为强类型端切对象。
  - `ToString()`: 返回当前端切代码字符串。
  - `Assign(StiffenerEndType that)`: 浅拷贝。

#### `EnPilEndType`
- **说明**: 支柱（Pillar）端部约束与支承形式。
- **合法值/方法列表**:
  - `PilEndPla()`: 支柱端部直接顶在板上
  - `PilEndFla()`: 支柱端部连接在强骨材面板上
  - `PilEndPt()`: 支柱端部收敛于指定几何点
  - `PilEndCurrPan()`: 连接在当前板架
  - `PilEndOtherPan()`: 贯通连接至异向板架
  - `PilEnd1CPla()`: 带垫板连接至单层板
  - `PilEndPadCurrPan()`: 在当前板架加设专用加强垫板 (Pad)
  - `PilEndPadOtherPan()`: 在对面板架加设专用加强垫板 (Pad)
  - `Ambiguous()`: 未决形式
- **通用方法**: `Assign(EnPilEndType that)`, `ToString()`

#### `EnPilMouLineType`
- **说明**: 支柱（Pillar）理论轴线的定位形式。
- **合法值/方法列表**:
  - `PilMouEndPt()`: 由起止两个空间端点确定轴线
  - `PilMouMouLine()`: 依附于宿主构件理论线
  - `Ambiguous()`: 歧义轴线
- **通用方法**: `Assign(EnPilMouLineType that)`, `ToString()`
