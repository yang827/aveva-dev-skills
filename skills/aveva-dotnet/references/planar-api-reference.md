# AVEVA Marine Planar Statements API Reference (`Aveva.Marine.Planar.dll`)

本手册收录从 `netaveva.marine.planarapi.pdf`（共 539 页）中提取的全部 63 个 Planar Statement 语句类、PML 包装类与辅助类型。每个 Statement 均遵循 4 重构造函数模式（空构造、浅拷贝构造、从 DbElement 逆向提取构造、以及按 panelName/groupNo 实例化构造）。

---

## 1. 架构与命名空间分工 (Planar Architecture)

Planar API 在程序集 `Aveva.Marine.Planar.dll` 中划分了两大核心命名空间：
1. **`Aveva.Marine.Planar` (C# 核心空间)**:
   - 包含 34 个 Statement 语句类与辅助计算类（`PanelStatement`, `PlaneStatement`, `BoundaryStatement`, `PlateStatement`, `StiffenerStatement`, `BracketStatement`, `HoleStatement`, `ComponentHelper` 等）。
   - 专为 .NET 强类型环境设计，输入输出均采用托管强类型对象或基础数据类型。
2. **`Aveva.Marine.Planar.PML` (PML 互操作包装空间)**:
   - **29 个 PMLNet 枚举分类工厂类**：因 PML 不支持 C# 原生 `enum`，AVEVA 在此空间为每个枚举定义了同名类与无参方法工厂（如 `EnSide.Ps()`, `EnHoleType.Plate()`，详见 [planar-enums-reference.md](planar-enums-reference.md)）。
   - **9 个 PML 专用派生包装类**：为了适配 PML 解释器的参数传递，为以下类型提供了继承自基类的专用 PML 子类：
     - `BracketArm : Aveva.Marine.Planar.BracketArm`
     - `Clip : Aveva.Marine.Planar.Clip`
     - `FlangeEnd : Aveva.Marine.Planar.FlangeEnd`
     - `PillarEnd : Aveva.Marine.Planar.PillarEnd`
     - `Point : Aveva.Marine.Planar.Point`
     - `StiffenerEnd : Aveva.Marine.Planar.StiffenerEnd`
     - `StiffenerEndConnection : Aveva.Marine.Planar.StiffenerEndConnection`
     - `StiffenerEndType : Aveva.Marine.Planar.StiffenerEndType`
     - `StiffenerStatement : Aveva.Marine.Planar.StiffenerStatement`

---

## 2. Statement 底层语法标记对照表 (Schema Syntax Mapping)

当调用任意 Statement 对象的 `.Statement` 属性时，内部引擎会将其属性序列化为 AVEVA Marine 标准文本宏语法（Tribon / Marine Schema Syntax）。下表列出核心关键字映射关系，便于调试逆向提取结果或编写宏脚本生成器：

| 语法关键字 | 对应 Statement 类型与属性 | 说明与语法格式范例 |
|---|---|---|
| `PANEL` | `PanelStatement.Name` | 平面分段定义：`PANEL 'PANEL_NAME' POS ... ORI ...` |
| `PLANE` | `PlaneStatement.Plane` | 基准参考面定义：`PLANE 'PLANE_NAME' REF ...` |
| `BOUND` | `BoundaryStatement.Limit` | 外围边界修剪：`BOUND LIM ... INC ...` |
| `PLATE` | `PlateStatement` | 结构母板：`PLATE MAT 'STEEL_A' THI 18.5 ...` |
| `STIFF` | `StiffenerStatement` | 型材加筋：`STIFF PRO 'HP160x8' POS ... ORI ...` |
| `BKT` | `BracketStatement` | 连接肘板：`BKT MAT ... THI ... ARM1 ... ARM2 ...` |
| `FLG` | `FlangeStatement` | 自由边面板/折边：`FLG WID ... THI ...` |
| `CUT` / `NOT` | `CutStatement` / `NotchStatement` | 切口与型切：`CUT NOT 'NOTCH_TYPE' PAR ...` |
| `HOL` | `HoleStatement` | 工艺开孔：`HOL DIA 300 POS ...` |
| `COMP` | `CompensationStatement` | 开孔补强板：`COMP THI ... MAT ...` |
| `SWG` | `SwageStatement` | 舱壁压折/波形槽：`SWG WID ... DEP ...` |
| `SEAM` | `SeamStatement` | 板缝切分线：`SEAM POS ...` |
| `EXCESS` | `ExcessStatement` | 建造加放余量：`EXCESS VAL 50 ...` |
| `SHRINK` | `ShrinkageStatement` | 焊接收缩补偿：`SHRINK FACTOR ...` |
| `BEAD` | `BeadStatement` | 焊道指示线：`BEAD WID ...` |
| `HNC` | `HNCStatement` | 管穿孔与穿越件开孔：`HNC TYPE ...` |

---

## Class `BeadStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public BeadStatement();`
- `public BeadStatement(BeadStatement source); // 浅拷贝构造函数`
- `public BeadStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public BeadStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Angle` | Angle |
| `Laminate` | Laminate |
| `Limit` | Limit |
| `PositionNumber` | Position Number |
| `PositionNumberPS` | Position Number Portside |
| `PositionNumberSB` | Position Number Starboard |
| `Quality` | Quality |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |
| `Width` | Width |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `BoundaryStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public BoundaryStatement();`
- `public BoundaryStatement(BoundaryStatement source); // 浅拷贝构造函数`
- `public BoundaryStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public BoundaryStatement(string panelName); // 绑定至目标板架`


### Properties

| Property | Description |
|---|---|
| `limitCount` | Number of limits |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `appendLimit` | Append Limit (insert at the end) |
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `getLimit` | Get limit by limit number, starting at 1. |
| `GetType` | (inherited from Object) |
| `insertLimit` | Insert Limit |
| `setLimit` | Set Limit |
| `ToString` | (inherited from Object) |

---

## Class `BracketArm`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public BracketArm();`
- `public BracketArm(BracketArm source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `ComponentType` | Overloaded. Component Type |
| `Line1` | Overloaded. Line1 |
| `Line2` | Overloaded. Line2 |
| `LineString` | Line String |
| `Name` | Name |
| `ProfileNumber` | Overloaded. Bracket Profile Number |
| `Reflected` | Name |
| `Revert` | Overloaded. Revert |
| `Side` | Side |
| `TagCode` | Overloaded. Bracket Tag Code |
| `Type` | Overloaded. Type |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `References` | Overloaded. |
| `References` | (inherited from BracketArm) Overloaded. Get referenced elements |
| `ToString` | (inherited from Object) |

---

## Class `BracketStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public BracketStatement();`
- `public BracketStatement(BracketStatement source); // 浅拷贝构造函数`
- `public BracketStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public BracketStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `A` | A |
| `AOV` | AOV |
| `ARBDIRSTR` | ARBDIRSTR |
| `ArmA` | Get arm A property interface. |
| `ArmB` | Get arm B property interface. |
| `ArmC` | Get arm C property interface. |
| `Assembly1` | Assembly 1 |
| `Assembly1Arrangement` | Assembly 1 Arrangement |
| `Assembly2` | Assembly 2 |
| `Assembly2Arrangement` | Assembly 2 Arrangement |
| `Assembly3` | Assembly 3 |
| `Assembly3Arrangement` | Assembly 3 Arrangement |
| `Assembly4` | Assembly 4 |
| `Assembly4Arrangement` | Assembly 4 Arrangement |
| `AssemblyReference` | Assembly Ref |
| `AssemblyReferencePS` | Assembly Reference PS |
| `AssemblyReferenceSB` | Assembly Reference SB |
| `B` | B |
| `Bevel` | Bevel |
| `BEVELSIDE` | BEVELSIDE |
| `BNO` | BNO |
| `BNOSTR` | BNOSTR |
| `BOV` | BOV |
| `BRA_LOC` | Bracket Location |
| `BracketPanel` | Bracket Panel BRP in schema syntax. |
| `BracketPanelName` | Bracket Panel Name |
| `BracketType` | Bracket Type |
| `BraProfBrpAssArrBrpAss` | Bracket BraProfBrpAssArrBrpAss |
| `BraProfBrpPosNo` | Bracket BraProfBrpPosNo |
| `BraProfBrpPosNoPs` | Bracket BraProfBrpPosNoPs |
| `BraProfBrpPosNoSb` | Bracket BraProfBrpPosNoSb |
| `BraProfBrpPosStr` | Bracket Profile Brp Position String |
| `BraProfBrpPosStrPs` | Bracket Profile Brp Position String PortSide |
| `BraProfBrpPosStrSb` | Bracket Profile Brp Position String Starboard |
| `C` | C |
| `Colour` | Colour |
| `Comment` | Comment |
| `COR` | Notch arrangement |
| `D` | D |
| `Designation` | Designation |
| `Destination` | Destination |
| `Displaced` | Displaced |
| `Double` | Double |
| `E` | E |
| `Excess` | Excess |
| `F` | F |
| `FCNO` | Defines the bracket number(s) from where to copy |
| `the` | bracket(s) |
| `FUN` | FUN |
| `G` | G |
| `GenArr` | Bracket GenArr |
| `GeneralStrings` | General Strings |
| `Grinding` | Grinding |
| `H` | H |
| `HoleCoordU` | Hole Coordinates U |
| `HoleCoordV` | Hole Coordinates V |
| `HoleDesignation` | Hole Designation |
| `HoleIncl` | Hole Incl |
| `HOLEPLL` | HOLE PLL |
| `Instance` | Instance |
| `J` | J |
| `K` | K |
| `LAM1` | Laminate 1 |
| `LAM2` | Laminate 2 |
| `LIS` | LIS |
| `M1` | M1 |
| `MAT` | Bracket Plate Thickness |
| `Material` | Material, thickness of bracket plate. MAT ins |
| `schema` | syntax. |
| `Mirror` | Mirror MIR in schema syntax. |
| `MSide` | MSide |
| `Name` | Name NAM in schema syntax. |
| `Nbkt` | Nbkt |
| `NOAUTOBEV` | No Auto Bev |
| `NOSTR` | NOSTR |
| `Notch` | Notch NOT in schema syntax. |
| `NotchA` | Notch A NOA in schema syntax. |
| `NotchB` | Notch B NOB in schema syntax |
| `NotchC` | Notch C NOC in schema syntax |
| `Offset` | Offset |
| `PanelName` | Panel name |
| `Plane` | Plane String |
| `PlaneComp` | Bracket PlaneComp |
| `Position` | Position String |
| `PositionNo` | Position No |
| `PositionNoPS` | Position No PS |
| `PositionNoSB` | Position No SB |
| `POSSTR` | POSSTR |
| `POSSTR_PS` | POSSTR_PS |
| `POSSTR_SB` | POSSTR_SB |
| `ProfileA` | Profile A PRA in schema syntax. |
| `ProfileB` | Profile B PRB in schema syntax. |
| `ProfileC` | Profile C PRC in schema syntax. |
| `ProfileD` | Profile D PRD in schema syntax. |
| `ProfileE` | Profile E PRE in schema syntax. |
| `ProfileQuality` | Profile Quality PQUA in schema syntax. |
| `Psi` | Psi |
| `Qual` | Quality |
| `R` | R |
| `R1` | R1 |
| `R2` | R2 |
| `Reference` | Reference |
| `SIDE1` | Side1 |
| `SIDE2` | Side2 |
| `Statement` | Statement string from all statement properties. |
| `Store` | Store |
| `SubType` | Sub Type |
| `SurfaceTreatment` | Surface Treatment |
| `Syntax` | Syntax SYN in schema syntax. |
| `Tight` | Tight |
| `TOELA` | TOELA |
| `TOELB` | TOELB |
| `V1` | V1 |
| `V2` | V2 |
| `ValidSide` | Valid side |
| `Variant` | Variant |
| `Weld` | Weld |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetArbDir` | Arb Dir |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `SetArbDir` | Arb Dir |
| `ToString` | (inherited from Object) |

---

## Class `Clip`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public Clip();`
- `public Clip(Clip source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `Breadth` | Breadth |
| `Dimension` | Dimension |
| `GeneralPurposeStrings` | General Purpose Strings |
| `Gps` | (inherited from Clip) Gps |
| `HoleCoordU` | Hole Coord U |
| `HoleCoordV` | Hole Coord V |
| `HoleDesignation` | Hole Designation |
| `HoleIncl` | (inherited from Clip) HoleIncl |
| `HoleInclination` | Hole Inclination |
| `Id` | Id |
| `Length` | Length |
| `No` | (inherited from Clip) No |
| `NoStr` | NoStr |
| `Number` | Overloaded. Number |
| `Pos` | (inherited from Clip) Pos |
| `Position` | (inherited from Clip) Position String |
| `PositionPortside` | (inherited from Clip) Position Portside |
| `Positions` | Positions |
| `PositionsPortside` | Positions Portside |
| `PositionsStarboard` | Positions Starboard |
| `PositionStarboard` | (inherited from Clip) Position Starboard |
| `PositionString` | Position String |
| `PositionStringPortside` | Position String Portside |
| `PositionStringStarboard` | Position String Starboard |
| `PosPs` | (inherited from Clip) PosPs |
| `PosSb` | (inherited from Clip) PosSb |
| `Thick` | Thick |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `ColourType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public ColourType();`


### Methods

| Method | Description |
|---|---|
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Black` | Black |
| `Blue` | Blue |
| `Cyan` | Cyan |
| `Default` | Default |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Green` | Green |
| `Magenta` | Magenta |
| `Red` | Red |
| `ToString` | ToString |
| `White` | White |
| `Yellow` | Yellow |

---

## Class `CompensationStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public CompensationStatement();`
- `public CompensationStatement(CompensationStatement source); // 浅拷贝构造函数`
- `public CompensationStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public CompensationStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Corner` | Corner |
| `Length` | Length |
| `Limit` | Limit |
| `Size` | Size |
| `Statement` | Statement string from all statement properties. |
| `Type` | Type |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `ComponentHelper`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public ComponentHelper();`


### Methods

| Method | Signature | Description |
|---|---|---|
| `GetGroups` | `double[] GetGroups(DbElement planarPanelElement, enComponentType compType)` | 传入板架图元与构件类型枚举，返回该板架下包含的所有特征分组编号数组（Group Numbers） |
| `getPanelName` | `string getPanelName(DbElement element)` | 传入板架子构件图元，高速反查所属平面分段板架的系统名称（如 `/DECK-PL-01`） |
| `Equals` | `bool Equals(object obj)` | (inherited from Object) |
| `GetHashCode` | `int GetHashCode()` | (inherited from Object) |
| `GetType` | `Type GetType()` | (inherited from Object) |
| `ToString` | `string ToString()` | (inherited from Object) |

---

## Class `CoordinateSuffix`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public CoordinateSuffix();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `MAX` | MAX |
| `MIN` | MIN |
| `ONE` | ONE |
| `T` | T |
| `ToString` | String representation |
| `TWO` | TWO |

---

## Class `CutStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public CutStatement();`
- `public CutStatement(CutStatement source); // 浅拷贝构造函数`
- `public CutStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public CutStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `BCFlange` | BC Flange |
| `BClip` | B Clip |
| `BCShell` | BC Shell |
| `BCWeb` | BC Web |
| `BFlange` | B Flange |
| `BShell` | B Shell |
| `BWeb` | B Web |
| `Bvs` | Bvs |
| `ClipA` | Get Clip A property interface. |
| `ClipAsr` | Clip Asr |
| `ClipAsrPs` | Clip Asr Portside |
| `ClipAsrSb` | Clip Asr Starboard |
| `ClipB` | Get Clip B property interface. |
| `ClipC` | Get Clip C property interface. |
| `ClipCode` | Clip Code |
| `ClipColour` | Clip Colour |
| `ClipDestination` | Clip Destination |
| `ClipMat2Given` | Clip Mat 2 Given |
| `ClipQuality` | Clip Quality |
| `ClipSide` | Clip Side |
| `ClipSide2` | Clip Side2 |
| `ClipSurfaceTreatment` | Clip Surface Treatment |
| `Comment` | Comment |
| `CutBevel` | Cut Bevel |
| `CutBevSet` | Cut Bev Set |
| `CutCode` | Cut Code |
| `CutName` | Cut Name |
| `CutType` | CutType |
| `Excess` | Excess |
| `Excess2` | Excess2 |
| `Fun` | Fun |
| `Gen` | Gen |
| `GenStr` | GenStr |
| `Grinding` | Grinding |
| `IntCrossPanDir` | Int Cross Pan Dir |
| `IntCrossPanM1` | Int Cross Pan M1 |
| `IntCrossPanM2` | Int Cross Pan M2 |
| `IntCrossPanM3` | Int Cross Pan M3 |
| `IntCrossPanM4` | Int Cross Pan M4 |
| `IntCrossPanR1` | Int Cross Pan R1 |
| `IntCrossPanR2` | Int Cross Pan R2 |
| `IntProfCompNo` | Int Prof Comp No |
| `IntProfCompType` | Int Prof Comp Type |
| `IntProfRef` | Int Prof Ref |
| `IntProfTagCode` | Int Prof Tag Code |
| `Mat` | Mat |
| `NameGiven` | Name Given |
| `NCut` | NCut |
| `NIntPr` | NIntPr |
| `NoAutoBevClip` | No Auto Bev Clip |
| `NoAutoBevCut` | No Auto Bev Cut |
| `Panel` | Panel |
| `ProfType` | Prof Type |
| `Refl` | Refl |
| `Sbps` | Sbps |
| `Side` | Side |
| `Slope` | Slope |
| `Statement` | Statement string from all statement properties. |
| `WClip` | Welded Clip |
| `Weld` | Weld |
| `Width` | Width |
| `WProfile` | Welded Profile |
| `WShell` | W Shell |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `DoublePlateStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public DoublePlateStatement();`
- `public DoublePlateStatement(DoublePlateStatement source); // 浅拷贝构造函数`
- `public DoublePlateStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public DoublePlateStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `AssemblyReference` | Assembly Reference |
| `AssemblyReferencePortside` | Assembly Reference Portside |
| `AssemblyReferenceStarboard` | Assembly Reference Starboard |
| `AttPanel` | Panel name containing pillar |
| `BevelCode` | Bevel Code |
| `BevelSide` | Bevel Side |
| `Closed` | Closed |
| `Colour` | Colour |
| `Comment` | Comment |
| `Curve` | Curve |
| `Destination` | Destination |
| `DUOffset` | Offset in DU |
| `DVOffset` | Offset in DV |
| `Functional` | Functional |
| `GeneralPurposeString1` | General Purpose String 1 (AS1) |
| `GeneralPurposeString2` | General Purpose String 2 (AS2) |
| `GeneralPurposeString3` | General Purpose String 3 (AS3) |
| `GeneralPurposeString4` | General Purpose String 4 (AS4) |
| `GeneralString` | General String |
| `Grinding` | Grinding |
| `M1` | M1 |
| `M2` | M2 |
| `NOA` | Notch A |
| `NoAutoBevel` | NoAutoBevel |
| `NOB` | Notch B |
| `Number` | Number |
| `Offset` | Offset |
| `PillarNumber` | Pillar Number to connect the doubling to |
| `Position` | Position |
| `PositionArray` | Position Array |
| `PositionArrayPortside` | Position Array Portside |
| `PositionArrayStarboard` | Position Array Starboard |
| `PositionPortside` | Position Portside |
| `PositionStarboard` | Position Starboard |
| `Quality` | Quality |
| `ReferenceCompType` | Reference Comp Type |
| `ReferenceNumber` | Reference Number |
| `ReferencePanel` | Reference Panel |
| `ReferenceSeam` | Reference Seam |
| `Reflect` | Reflect |
| `RefType` | RefType |
| `ROTOffset` | Offset in rotation |
| `Set` | Set |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |
| `Surface` | Surface |
| `Thickness` | Thickness |
| `Valid` | Valid |
| `Weld` | Weld |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `EnCType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnCType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `CTypeAmbigous` | CTypeAmbigous |
| `CTypeThreePoints` | CTypeThreePoints |
| `CTypeX` | CTypeX |
| `CTypeY` | CTypeY |
| `CTypeZ` | CTypeZ |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | ToString |

---

## Class `EnCoordType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnCoordType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |
| `U` | U |
| `Undefined` | Undefined |
| `UV` | U V |
| `V` | V |
| `X` | X |
| `XY` | X Y |
| `XYZ` | X Y Z |
| `XZ` | X Z |
| `Y` | Y |
| `YZ` | Y Z |
| `Z` | Z |

---

## Class `EnCutOutType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnCutOutType();`


### Methods

| Method | Description |
|---|---|
| `Ambigous` | Ambiguous |
| `Assign` | Assign interface. |
| `CutInPlate` | CutInPlate |
| `CutInSti` | CutInSti |
| `CutIntCrossPan` | CutIntCrossPan |
| `CutoutTypeAuto` | Auto |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |

---

## Class `EnDirectionType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnDirectionType();`


### Methods

| Method | Description |
|---|---|
| `Aft` | Aft |
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Bot` | Bottom |
| `Both` | NotSet |
| `Equals` | (inherited from Object) |
| `For` | For |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `NotSet` | NotSet |
| `PS` | PortSide |
| `SB` | Starboard |
| `Top` | Top |
| `ToString` | ToString |

---

## Class `EnDistanceType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnDistanceType();`


### Methods

| Method | Description |
|---|---|
| `AlongLine` | AlongLine |
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `PerpToLimit` | PerpToLimit |
| `ToString` | String representation |

---

## Class `EnFlangeType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnFlangeType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `Folded` | Stiffener |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |
| `Welded` | Plate |

---

## Class `EnHNCType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnHNCType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Cutout` | Cutout |
| `CutoutRef` | CutoutRef |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Hole` | Hole |
| `HoleRef` | HoleRef |
| `Notch` | Notch |
| `NotchRef` | NotchRef |
| `ToString` | String representation |

---

## Class `EnHoleLocationType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnHoleLocationType();`


### Methods

| Method | Description |
|---|---|
| `AlongLimit` | AlongLimit |
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `AsStored` | AsStored |
| `Center` | Center |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `NotSet` | NotSet |
| `ToString` | String representation |

---

## Class `EnHoleRefType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnHoleRefType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Pillar` | Pillar on number |
| `Seam` | Seam on number |
| `ToString` | String representation |
| `Undefined` | Undefined |

---

## Class `EnHoleType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnHoleType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Plate` | Plate |
| `Stiffener` | Stiffener |
| `ToString` | String representation |

---

## Class `EnIncType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnIncType();`


### Methods

| Method | Description |
|---|---|
| `AlongLimit` | AlongLimit |
| `AlongLine` | AlongLine |
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |

---

## Class `EnLimitRefType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnLimitRefType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `BR` | Bracket on number |
| `Equals` | (inherited from Object) |
| `F` | Flange on number |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `HOL` | Hole on number |
| `L` | Longitudinal on number |
| `LIM` | Limit on number |
| `PI` | Pillar on number |
| `PIPE` | Pipe structure object |
| `S` | Stiffener |
| `SEA` | Seam on number |
| `Seam` | Seam |
| `SF` | Stiffener on frame position |
| `SL` | Stiffener on longitudinal position |
| `SLM` | Stiffener on longitudinal position negated |
| `ST` | Stiffener on user defined tag |
| `T` | Transversal on number |
| `ToString` | String representation |
| `Undefined` | Undefined |

---

## Class `EnLimitType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnLimitType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Curve` | Curve |
| `Equals` | (inherited from Object) |
| `Free` | Free |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `IntPan` | IntPan |
| `Line` | Line |
| `Plane` | Plane |
| `PlPan` | PlPan |
| `PrAlong` | PrAlong |
| `PrCross` | PrCross |
| `PrOverl` | PrOverl |
| `Surface` | Surface |
| `ToString` | String representation |

---

## Class `EnLocationType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnLocationType();`


### Methods

| Method | Description |
|---|---|
| `Arms` | Arms |
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `ExplPos` | Expl Pos |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Move` | Move |
| `Plane` | Plane |
| `ToString` | String representation |
| `Undefined` | Undefined |

---

## Class `EnMouldLineType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnMouldLineType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `MouAloCurve` | MouAloCurve |
| `MouAloLine` | MouAloLine |
| `MouAmbiguous` | MouAmbiguous |
| `MouConSti` | MouConSti |
| `MouEndPts` | MouEndPts |
| `MouNotSet` | MouNotSet |
| `MouPLLHole` | MouPLLHole |
| `MouPLLHoleTan` | MouPLLHoleTan |
| `MouPLLLim` | MouPLLLim |
| `MouPLLLimTan` | MouPLLLimTan |
| `ToString` | ToString |

---

## Class `EnNotLocationType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnNotLocationType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `LocAlongLimit` | LocAlongLimit |
| `LocAmbiguous` | LocAmbiguous |
| `LocAsStored` | LocAsStored |
| `LocAtCorner` | LocAtCorner |
| `LocAtLines` | LocAtLines |
| `LocAtSeam` | LocAtSeam |
| `LocAtSeamInt` | LocAtSeamInt |
| `LocByDistance` | LocByDistance |
| `LocCurve` | LocCurve |
| `LocForSeam` | LocForSeam |
| `LocNotSet` | LocNotSet |
| `ToString` | String representation |

---

## Class `EnNotType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnNotType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Plate` | Plate |
| `Stiffener` | Stiffener |
| `ToString` | String representation |

---

## Class `EnPilEndType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnPilEndType();`


### Methods

| Method | Description |
|---|---|
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `PilEnd1CPla` | PilEnd1CPla |
| `PilEndCurrPan` | PilEndCurrPan |
| `PilEndFla` | PilEndFla |
| `PilEndOtherPan` | PilEndOtherPan |
| `PilEndPadCurrPan` | PilEndPadCurrPan |
| `PilEndPadOtherPan` | PilEndPadOtherPan |
| `PilEndPla` | PilEndPla |
| `PilEndPt` | PilEndPt |
| `ToString` | ToString |

---

## Class `EnPilMouLineType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnPilMouLineType();`


### Methods

| Method | Description |
|---|---|
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `PilMouEndPt` | Pillar Mould End Point |
| `PilMouMouLine` | Pillar Mould Mould Line |
| `ToString` | ToString |

---

## Class `EnPointType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnPointType();`


### Methods

| Method | Description |
|---|---|
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `Corner` | Corner |
| `Curve` | Curve |
| `Equals` | (inherited from Object) |
| `ExplGiven` | Expl Given |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Interpol` | Interpol |
| `Intersect` | Intersect |
| `None` | None |
| `PipeCross` | Pipe Cross |
| `PrCross` | Pr Cross |
| `ProfEnd` | Prof End |
| `SeamEnd` | Seam End |
| `ToString` | ToString |

---

## Class `EnProfConType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnProfConType();`


### Methods

| Method | Description |
|---|---|
| `Along` | Along |
| `Assign` | Assign interface. |
| `Cross` | Cross |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Overlap` | Overlap |
| `ToString` | String representation |
| `Undefined` | Undefined |

---

## Class `EnRefType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnRefType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `RefAmbigous` | Ambiguous |
| `RefCurve` | Curve |
| `RefHole` | Hole |
| `RefNotch` | Notch |
| `RefPillarPad` | PillarPad |
| `ToString` | String representation |

---

## Class `EnReferencedType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnReferencedType();`


### Methods

| Method | Description |
|---|---|
| `Ambiguous` | Ambiguous |
| `Assign` | Assign interface. |
| `B` | B |
| `Bou` | Bou |
| `Bt` | Bt |
| `CPanel` | CPanel |
| `Curve` | Curve |
| `D` | D |
| `Equals` | (inherited from Object) |
| `ExtBr` | ExtBr |
| `ExtCurve` | ExtCurve |
| `ExtF` | ExtF |
| `ExtLim` | ExtLim |
| `ExtProf` | ExtProf |
| `ExtS` | ExtS |
| `FR` | FR |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `INT` | INT |
| `IntBr` | IntBr |
| `IntF` | IntF |
| `IntLim` | IntLim |
| `IntProf` | IntProf |
| `IntS` | IntS |
| `LFCurve` | LFCurve |
| `Long` | Long |
| `Name` | Name |
| `Panel` | Panel |
| `Pipe` | Pipe |
| `Plane` | Plane |
| `RSO` | RSO |
| `Seam` | Seam |
| `Surface` | Surface |
| `ToString` | String representation |
| `Trans` | Trans |
| `Undefined` | Undefined |
| `WL` | WL |

---

## Class `EnSide`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnSide();`


### Methods

| Method | Description |
|---|---|
| `Aft` | Aft |
| `Assign` | Assign interface. |
| `Bot` | Bot |
| `Equals` | (inherited from Object) |
| `For` | For |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `Ps` | Portside |
| `Sb` | Starboard |
| `Top` | Top |
| `ToString` | String representation |

---

## Class `EnValueType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnValueType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |
| `ValueAmbigous` | ValueAmbigous |
| `ValueEXP` | ValueEXP |
| `ValueT` | ValueT |
| `ValueT1` | ValueT1 |
| `ValueT2` | ValueT2 |
| `ValueU` | ValueU |
| `ValueV` | ValueV |
| `ValueVAL` | ValueVAL |
| `ValueX` | ValueX |
| `ValueY` | ValueY |
| `ValueZ` | ValueZ |

---

## Class `EnWatertightType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public EnWatertightType();`


### Methods

| Method | Description |
|---|---|
| `Assign` | Assign interface. |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `NotSet` | Not Set |
| `NotWatertight` | Not Watertight |
| `ToString` | String representation |
| `Watertight` | Watertight |

---

## Class `ExcessStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public ExcessStatement();`
- `public ExcessStatement(ExcessStatement source); // 浅拷贝构造函数`
- `public ExcessStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public ExcessStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Limit` | Excess Limit |
| `Param1` | Parameter 1 |
| `Param2` | Parameter 2 |
| `Param3` | Parameter 3 |
| `Param4` | Parameter 4 |
| `Param5` | Parameter 5 |
| `Param6` | Parameter 6 |
| `Parameters` | Parameters as a string |
| `SBPS` | Excess Limit |
| `Size` | Excess Size |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `FlangeEnd`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public FlangeEnd();`
- `public FlangeEnd(FlangeEnd source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `Excess` | (inherited from FlangeEnd) Excess |
| `FoldedAngle` | Folded Angle |
| `FoldedEndString` | FoldedEndString |
| `FoldedEndType` | Overloaded. Folded End Type |
| `TagCode` | (inherited from FlangeEnd) TagCode |
| `WeldedBevel` | Weld Bevel |
| `WeldedBevelSide` | Weld Bevel Side |
| `WeldedBevMES` | Weld BevMES |
| `WeldedBevVAR` | Weld BevVAR |
| `WeldedCompCNT` | Overloaded. Welded CompCNT |
| `WeldedCompNo` | Overloaded. Welded Comp No |
| `WeldedCompType` | Overloaded. Welded CompType |
| `WeldedCutConConn` | Overloaded. Welded CutConConn |
| `WeldedCutConConName` | Weld Cut Con Con Name |
| `WeldedCutConCut` | Overloaded. Welded CutConCut |
| `WeldedCutConCutName` | Weld Cut Con Cut Name |
| `WeldedCutConCutParString` | Weld Cut Con Cut Par String |
| `WeldedCutConUCutName` | Weld Cut Con U Cut Name |
| `WeldedEndSchemaString` | Weld End Schema String |
| `WeldedEndType` | Overloaded. Welded EndType |
| `WeldedExcess` | Excess |
| `WeldedLineString` | Weld Line String |
| `WeldedPan` | Weld Pan |
| `WeldedReflected` | Overloaded. Welded Reflected |
| `WeldedTagCode` | Welded Tag Code |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `FlangeStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public FlangeStatement();`
- `public FlangeStatement(FlangeStatement source); // 浅拷贝构造函数`
- `public FlangeStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public FlangeStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`
- `public FlangeStatement(enFlangeType flangeType); // 按折边枚举类型构造`


### Properties

| Property | Description |
|---|---|
| `End1` | End 1 definition |
| `End2` | End 2 definition |
| `FoldedComment` | Folded: Comment |
| `FoldedFlangeType` | Folded: Flange Type |
| `FoldedFunctional` | Folded: Functional |
| `FoldedHeight` | Folded: Height |
| `FoldedLimitNumber` | Folded: Limit No |
| `FoldedLineString` | Folded: Line |
| `FoldedSide` | Folded: Side |
| `GetFlangeType` | Get type of flange, i.e. welded or folded |
| `Statement` | Statement string from all statement properties. |
| `WeldedArr` | Welded ARR |
| `WeldedAss1` | Welded: Ass1 |
| `WeldedAss2` | Welded: Ass2 |
| `WeldedAss3` | Welded: Ass3 |
| `WeldedAss4` | Welded: Ass4 |
| `WeldedAssReference` | Welded: Ass Reference |
| `WeldedAssReferencePS` | Welded: Assembly Reference Portside |
| `WeldedAssReferenceSB` | Welded: Assembly Reference Starboard |
| `WeldedColour` | Welded: Colour |
| `WeldedComment` | Welded: Comment |
| `WeldedDestination` | Welded: Destination |
| `WeldedDimParStr` | Welded: DIMPARSTR |
| `WeldedFlangeSchemaString` | Welded: Flange Schema String |
| `WeldedFlangeType` | Welded Flange Type |
| `WeldedFunctional` | Welded: Functional |
| `WeldedGeneralString` | Welded: General String |
| `WeldedGrinding` | Welded: Grinding |
| `WeldedHoleNumber` | Welded: Hole No |
| `WeldedIncl` | Welded: Incl |
| `WeldedLaminate1` | Welded Laminate 1 |
| `WeldedLaminate2` | Welded: Laminate 2 |
| `WeldedLimitNo` | Welded: Limit No |
| `WeldedLineString` | Welded: Line |
| `WeldedLIS` | Welded: LIS |
| `WeldedNDimPar` | Welded: N Dim Par |
| `WeldedNumber` | Welded: Number |
| `WeldedPosition` | Welded Position |
| `WeldedPositionPS` | Welded: Position PS |
| `WeldedPositionSB` | Welded: Position SB |
| `WeldedPositionString` | Welded: Position String |
| `WeldedPositionStringPS` | Welded: Position StringPortside |
| `WeldedPositionStringSB` | Welded: Position String Starboard |
| `WeldedQuality` | Welded: Quality |
| `WeldedSHR` | Welded: SHR |
| `WeldedSup` | Welded: Sup |
| `WeldedSurface` | Welded: Surface |
| `WeldedType` | Welded: Type |
| `WeldedUDProfileParameter` | Welded: UD Profile Parameter (UPR) |
| `WeldedUnsym` | Welded: Unsym |
| `WeldedUPR` | Welded: UD Profile Name (UPR) |
| `WeldedValid` | Welded: Valid |
| `WeldedWeld` | Welded: Weld |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `HNCStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public HNCStatement();`
- `public HNCStatement(HNCStatement source); // 浅拷贝构造函数`
- `public HNCStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public HNCStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Comment` | Comment |
| `CurrProfCompNo` | Curr Prof Comp No |
| `CurrProfTagCode` | Curr Prof Tag Code |
| `CutType` | Cut Type |
| `HNCDesignation` | HNC Designation |
| `HNCType` | HNCType |
| `Incl` | Incl |
| `Line` | Line |
| `Lines` | Lines |
| `nCurr` | nCurr |
| `nLine` | nLine |
| `nRef` | nRef |
| `Number` | Number |
| `NumberHNC` | Number HNC |
| `Offset` | Offset |
| `ProfType` | Profile Type |
| `Reflect` | Reflect |
| `RefProfCompNo` | Ref Prof Comp No |
| `RefProfTagCode` | Ref Prof Tag Code |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `HoleStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public HoleStatement();`
- `public HoleStatement(HoleStatement source); // 浅拷贝构造函数`
- `public HoleStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public HoleStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Along` | Along |
| `Bevel` | Bevel |
| `Bridge` | Bridge |
| `BridgeRadius` | Bridge Radius |
| `BridgeWidth` | Bridge Width |
| `Bvs` | Bvs |
| `Colour` | Colour |
| `Comment` | Comment |
| `Cross` | Cross |
| `CurveName` | Curve Name |
| `DirStr` | DirStr |
| `Fictitious` | Fictitious |
| `GeneralStrings` | General Strings |
| `Grinding` | Grinding |
| `HoleDesign` | HoleDesign |
| `HoleLoc` | HoleLoc |
| `HoleType` | HoleType |
| `HolGps` | HolGps |
| `Hook` | Hook |
| `HookCount` | Hook Count |
| `HookDist` | Hook Distance |
| `HookEndType` | Hook End Type |
| `HookGap` | Hook Gap |
| `HookRadius` | Hook Radius |
| `Inclination` | Inclination |
| `LaminateCode` | Laminate Code |
| `LaminateWidth` | Laminate Width |
| `LimitNumber` | Limit Number |
| `LineStr` | LineStr |
| `Ln1DirStr` | Ln1DirStr |
| `Ln1Str` | Ln1Str |
| `M1` | M1 |
| `Managed` | Managed |
| `NoAutoBev` | NoAutoBev |
| `NoStr` | NoStr |
| `PlaCont` | PlaCont |
| `Pll` | Pll |
| `RefNo` | RefNo |
| `Rtype` | Rtype |
| `SetNo` | SetNo |
| `SPC` | Spigot plate definition (SPC) |
| `SpigotPlateSide` | Spigot plate side (SI2) |
| `SpigotPosition` | Spigot plate position |
| `Statement` | Statement string from all statement properties. |
| `Valid` | Valid |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `LimitStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public LimitStatement();`
- `public LimitStatement(LimitStatement source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `Compensation` | Component |
| `Connection` | Connection |
| `ContourNumber` | ContourNumber |
| `Correction` | Correction |
| `CorrectionSide` | CorrectionSide |
| `CppShort` | CppShort |
| `Curve` | Curve |
| `Flange` | Flange |
| `FlangeNumber` | FlangeNumber |
| `Free` | Free |
| `LengthAfter` | LengthAfter |
| `LengthBefore` | LengthBefore |
| `LimitNumber` | LimitNumber |
| `LimitType` | Limit type |
| `LineString` | Line string |
| `M1` | M1 |
| `M2` | M2 |
| `M3` | M3 |
| `M4` | M4 |
| `Number` | Number |
| `Panel` | Panel |
| `PanelSide` | PanelSide |
| `Plate` | Plate |
| `PlateIntLine` | PlateIntLine |
| `PlateName` | PlateName |
| `ProfileAttributeNumber` | ProfileAttributeNumber |
| `ProfileComponentNumber` | ProfileComponentNumber |
| `ProfileComponentType` | ProfileComponentType |
| `ProfileConnectionType` | ProfileConnectionType |
| `ProfilePanelName` | ProfilePanelName |
| `ProfileReference` | ProfileReference |
| `ProfileReflected` | ProfileReflected |
| `ProfileSide` | ProfileSide |
| `ProfileTagCode` | ProfileTagCode |
| `R` | R |
| `R1` | R1 |
| `R2` | R2 |
| `Reflected` | Reflected |
| `Statement` | Statement string from all statement properties. |
| `Surface` | Surface |
| `Symmetry` | Symmetry |
| `V1` | V1 |
| `V2` | V2 |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `MarkingStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public MarkingStatement();`
- `public MarkingStatement(MarkingStatement source); // 浅拷贝构造函数`
- `public MarkingStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public MarkingStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `FreeText` | Free Text |
| `Limit` | Limit |
| `Line` | Line |
| `M1` | M1 |
| `MarkingSide` | Marking Side |
| `MarkingType` | Marking Type |
| `Name` | Name |
| `No` | No |
| `Npr` | Npr |
| `Reference` | Reference |
| `Sbps` | Sbps |
| `Sea` | Sea |
| `Statement` | Statement string from all statement properties. |
| `TextColour` | Text Colour |
| `TextHeight` | Text Height |
| `Type` | Type |
| `WeldHeight` | Weld Height |
| `WeldWidth` | Weld Width |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetLn1` | Ln1 |
| `GetLn2` | Ln2 |
| `GetType` | (inherited from Object) |
| `SetLn1` | Ln1 |
| `SetLn2` | Ln2 |
| `ToString` | (inherited from Object) |

---

## Class `NotchStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public NotchStatement();`
- `public NotchStatement(NotchStatement source); // 浅拷贝构造函数`
- `public NotchStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public NotchStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `AdjacentPanel` | Name of the adjacent panel used as a reference |
| `Along` | Along |
| `Atseam2no` | Atseam2no |
| `Atseamno` | Atseamno |
| `Comment` | Comment |
| `CornerNumber` | Corner number |
| `Cornstr` | Cornstr |
| `Fictitious` | Fictitious |
| `Limit` | Limit number |
| `LimitString` | Limit String |
| `Linestr` | Line string |
| `Mirr` | Mirr |
| `Nnot` | Nnot |
| `NotchDesignation` | Notch Designation |
| `NotchType` | NotchType |
| `NotLoc` | NotLoc |
| `Notname` | Notch name |
| `ReferenceSeamName` | Name of the seam you are referring to |
| `Refl` | Refl |
| `Sbps` | Sbps |
| `Seam2Side` | Seam2 Side |
| `SeamDirection` | Seam Direction |
| `SeamId` | Seams Id |
| `Seamno` | Number of the seams for which notches should be |
| `made` |  |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `NumericalStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public NumericalStatement();`
- `public NumericalStatement(NumericalStatement source); // 浅拷贝构造函数`
- `public NumericalStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public NumericalStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Comment` | Comment |
| `Expression` | Expression |
| `NO` | NO |
| `NO_Type` | NO_Type |
| `Statement` | Statement string from all statement properties. |
| `Value` | Value |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PanelStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PanelStatement();`
- `public PanelStatement(PanelStatement source); // 浅拷贝构造函数`
- `public PanelStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public PanelStatement(string panelName); // 绑定至目标板架`


### Properties

| Property | Description |
|---|---|
| `Axis` | Axis |
| `Block` | Block |
| `Buildno` | Build No |
| `CType` | CType |
| `Dt` | Dt |
| `Functionalprop` | Functionalprop |
| `GeneralPurposeString1` | General Purpose String 1 |
| `GeneralPurposeString2` | General Purpose String 2 |
| `GeneralPurposeString3` | General Purpose String 3 |
| `GeneralPurposeString4` | General Purpose String 4 |
| `GeneralStrings` | GeneralStrings |
| `GMS` | GSD Marking Side |
| `Gt` | Gt |
| `IdentLine` | IdentLine |
| `isWatertight` | isWatertight |
| `List` | List |
| `LnName` | LnName |
| `LnNo` | LnNo |
| `LnRType` | LnRType |
| `Location` | Location |
| `Locationstr` | Location String |
| `MainKnucledPanel` | Main Knucled Panel |
| `Name` | Name |
| `Origin` | Origin |
| `Statement` | Statement string from all statement properties. |
| `Stored` | Stored |
| `Subpan` | Subpan |
| `Surftreat` | Surface Treatment |
| `TypeKeyW` | Type Key W |
| `UAxis` | UAxis |
| `Valid` | Valid |
| `VAxis` | VAxis |
| `Wt` | Wt |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `ParallelCurveStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public ParallelCurveStatement();`
- `public ParallelCurveStatement(ParallelCurveStatement source); // 浅拷贝构造函数`
- `public ParallelCurveStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public ParallelCurveStatement(string panelName); // 绑定至目标板架`


### Properties

| Property | Description |
|---|---|
| `colour` | Colour |
| `curveName` | Curve Name |
| `curveType` | curveType |
| `distance` | distance |
| `lineStr` | Line String |
| `lineType` | Line Type |
| `parallelCurveName` | Parallel Curve Name |
| `parts` | parts |
| `point1` | Point 1 |
| `point2` | Point 2 |
| `sPoint1` | sPoint1 |
| `sPoint2` | sPoint2 |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PillarEnd`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PillarEnd();`
- `public PillarEnd(PillarEnd source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `Bev` | Bevel |
| `CompCnt` | Overloaded. CompCnt |
| `CompNo` | Overloaded. CompNo |
| `CompType` | Overloaded. CompType |
| `Con` | Overloaded. Con |
| `ConName` | Con Name |
| `Cut` | Overloaded. Cut |
| `CutName` | Cut Name |
| `CutParStr` | Cut Parameter String |
| `EndType` | Overloaded. EndType |
| `Excess` | Excess |
| `Gap` | Gap |
| `MouEndSch` | (inherited from PillarEnd) Mould End Schema |
| `MouldEndSchema` | Mould End Schema |
| `Panel` | Panel |
| `PlaName` | PlaName |
| `Planes` | Overloaded. |
| `PlaneStr` | Plane String |
| `Points` | Overloaded. |
| `PtStr` | Pt Str |
| `Reflect` | Overloaded. Reflect |
| `TagCode` | Overloaded. TagCode |
| `UCutName` | U Cut Name |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PillarStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PillarStatement();`
- `public PillarStatement(PillarStatement source); // 浅拷贝构造函数`
- `public PillarStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public PillarStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Assembly1` | Assembly 1 |
| `Assembly2` | Assembly 2 |
| `Assembly3` | Assembly 3 |
| `Assembly4` | Assembly 4 |
| `AssemblyArray1` | Assembly 1 |
| `AssemblyArray2` | Assembly 2 |
| `AssemblyArray3` | Assembly 3 |
| `AssemblyArray4` | Assembly 4 |
| `AssemblyReference` | Assembly Ref |
| `AssemblyReferencePortside` | Assembly Ref PS |
| `AssemblyReferenceStarboard` | Assembly Ref SB |
| `Colour` | Colour |
| `Comment` | Comment |
| `Destination` | Destination |
| `DimPar` | Dimension Parameter |
| `End1` | End 1 definition |
| `End2` | End 2 definition |
| `Functional` | Functional |
| `Gen` | Gen |
| `GeneralString` | General String |
| `Laminate1` | Laminate 1 |
| `Laminate2` | Laminate 2 |
| `Line` | Line |
| `Lines` | Lines |
| `Lis` | Lis |
| `MouldLineSchema` | Mould Line Schema |
| `MouLineType` | MouLineType |
| `nDimPar` | nDimPar |
| `NoStr` | No String |
| `nPil` | nPil |
| `Number` | Number |
| `OrientationAngle` | Orientation Angle |
| `OrientationDirection` | Orientation Direction |
| `OriPtStr` | Orientation Pt String |
| `Position` | Position |
| `PositionPortside` | Position Portside |
| `Positions` | Positions |
| `PositionsPS` | Positions Portside |
| `PositionsSB` | Positions Starboard |
| `PositionStarboard` | Position Starboard |
| `Quality` | Quality |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |
| `SurfaceTreatment` | Surface treatment |
| `SymmetryCode` | Symmetry Code |
| `Type` | Type |
| `Valid` | Valid |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PlaneStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PlaneStatement();`
- `public PlaneStatement(PlaneStatement source); // 浅拷贝构造函数`
- `public PlaneStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public PlaneStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Coord` | Coord |
| `CType` | CType |
| `LineStr` | Line Str |
| `PlaneName` | Plane Name |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PlateStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PlateStatement();`
- `public PlateStatement(PlateStatement source); // 浅拷贝构造函数`
- `public PlateStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public PlateStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `AssemblyName1` | Assembly Name 1 |
| `AssemblyName2` | Assembly Name 2 |
| `AssemblyName3` | Assembly Name 3 |
| `AssemblyName4` | Assembly Name 4 |
| `AssemblyNames1` | Assembly Names 1 |
| `AssemblyNames2` | Assembly Names 2 |
| `AssemblyNames3` | Assembly Names 3 |
| `AssemblyNames4` | Assembly Names 4 |
| `AssemblyReference` | Assembly Reference |
| `AssemblyReferencePS` | Assembly Reference PS |
| `AssemblyReferenceSB` | Assembly Reference SB |
| `Colour` | Colour |
| `Comment` | Comment |
| `Destination` | Destination |
| `Functional` | Functional |
| `GeneralStrings` | General Strings |
| `GeneralStringTable` | GeneralStringTable |
| `Laminate1` | Laminate 1 |
| `Laminate2` | Laminate 2 |
| `Material` | Material |
| `MaterialSide` | Material Side |
| `MaterialString` | Material String |
| `NumberString` | Number String |
| `NumMaterials` | Num Materials |
| `NumPlates` | Num Plates |
| `PartsList` | Parts List |
| `PointString` | Point String |
| `Position` | Position |
| `PositionPS` | Position PS |
| `PositionSB` | Position SB |
| `PositionString` | Position String |
| `PositionStringPS` | Position String PS |
| `PositionStringSB` | Position String SB |
| `Quality` | Quality |
| `RawPlateName` | Raw Plate Name |
| `Statement` | Statement string from all statement properties. |
| `SurfaceTreatment` | Surface Treatment |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `Point`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public Point();`


### Properties

| Property | Description |
|---|---|
| `CType` | Overloaded. Coordinate type |
| `CTypeSuffix` | Overloaded. Coordinate suffix type |
| `X` | X property. |
| `Y` | Y property. |
| `Z` | Z property. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Overloaded. |
| `Assign` | (inherited from Point) Overloaded. Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `PointStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public PointStatement();`
- `public PointStatement(PointStatement source); // 浅拷贝构造函数`
- `public PointStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public PointStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `AloAlong` | Alo Along |
| `AloCurve` | Alo Curve |
| `AloFactor` | Alo Factor |
| `AloM2` | Alo M2 |
| `CorCorn` | Cor Corn |
| `CorM1` | Cor M1 |
| `CorM2` | Cor M2 |
| `CorPanName` | Cor PanName |
| `CorRefl` | Cor Refl |
| `CorSid` | Cor Sid |
| `CroCharPntDef` | Cro CharPntDef |
| `CroCompNo` | Cro CompNo |
| `CroCompType` | Cro CompType |
| `CroDir` | Cro Dir |
| `CroDis` | Cro Dis |
| `CroFla` | Cro Fla |
| `CroM1` | Cro M1 |
| `CroM2` | Cro M2 |
| `CroPanName` | Cro PanName |
| `CroPerp` | Cro Perp |
| `CroPla` | Cro Pla |
| `CroPlaStr` | Cro PlaStr |
| `CroRefl` | Cro Refl |
| `CroSid` | Cro Sid |
| `CroTagCode` | Cro TagCode |
| `DU` | DU |
| `DV` | DV |
| `DX` | DX |
| `DY` | DY |
| `DZ` | DZ |
| `EndEnd` | End End |
| `EndLines` | End Lines |
| `EndLineStr` | End LineStr |
| `EndM1` | End M1 |
| `EndM2` | End M2 |
| `EndProfNo` | End ProfNo |
| `EndProfType` | End ProfType |
| `ExplAng` | Expl Ang |
| `ExplCoordSys` | Expl CoordSys |
| `ExplM1` | Expl M1 |
| `ExplPts` | Expl Points |
| `ExplPtStr` | Expl PtStr |
| `ExplTstr` | Expl Tstr |
| `IntCur1CntNo` | Int Cur1 CntNo |
| `IntCur1CurName` | Int Cur1 CurName |
| `IntCur1CurType` | Int Cur1 CurType |
| `IntCur1LimNo` | Int Cur1 LimNo |
| `IntCur1LineStr` | Int Cur1 LineStr |
| `IntCur1LN1` | Int Cur1 LN1 |
| `IntCur1LN2` | Int Cur1 LN2 |
| `IntCur1NumCurve` | Int Cur1 NumCurve |
| `IntCur1PanName` | Int Cur1 PanName |
| `IntCur1Refl` | Int Cur1 Refl |
| `IntCur1Sid` | Int Cur1 Sid |
| `IntCur1SurName` | Int Cur1 SurName |
| `IntCur2CntNo` | Int Cur2 CntNo |
| `IntCur2CurName` | Int Cur2 CurName |
| `IntCur2CurType` | Int Cur2 CurType |
| `IntCur2LimNo` | Int Cur2 LimNo |
| `IntCur2LineStr` | Int Cur2 LineStr |
| `IntCur2LN1` | Int Cur2 LN1 |
| `IntCur2LN2` | Int Cur2 LN2 |
| `IntCur2NumCurve` | Int Cur2 NumCurve |
| `IntCur2PanName` | Int Cur2 PanName |
| `IntCur2Refl` | Int Cur2 Refl |
| `IntCur2Sid` | Int Cur2 Sid |
| `IntCur2SurName` | Int Cur2 SurName |
| `IntM1` | Int M1 |
| `IntM2` | Int M2 |
| `IntPerp` | Int Perp |
| `IpolFactor` | Ipol Factor |
| `IpolM1` | Ipol M1 |
| `IpolM2` | Ipol M2 |
| `IpolPoints1` | Ipol Points 1 |
| `IpolPoints2` | Ipol Points 2 |
| `IpolPt1Str` | Ipol Pt1Str |
| `IpolPt2Str` | Ipol Pt2Str |
| `MSide` | MSide |
| `NoArr` | NoArr |
| `NoStr` | NoStr |
| `NumberOfPoints` | NumberOfPoints |
| `PipePipeName` | Pipe PipeName |
| `PointType` | Point Type |
| `R3` | R3 |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `SeamStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public SeamStatement();`
- `public SeamStatement(SeamStatement source); // 浅拷贝构造函数`
- `public SeamStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public SeamStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Bevel` | Bevel |
| `Bvt` | Bvt |
| `Comment` | Comment |
| `Dist` | Dist |
| `DistStr` | Dist Str |
| `Excess` | Excess |
| `ExcessType` | Excess Type |
| `From` | From |
| `Grinding` | Grinding |
| `LBevel` | L Bevel |
| `LeftSide` | Left Side |
| `LExcess` | L Excess |
| `LExcessType` | L Excess Type |
| `LimNo` | Lim No |
| `Line` | Line |
| `No` | No |
| `NumSeams` | Num Seams |
| `Panels` | Panels |
| `Partition` | Partition |
| `RBevel` | R Bevel |
| `Reflect` | Reflect |
| `Revert` | Revert |
| `RExcess` | R Excess |
| `RExcessType` | R Excess Type |
| `SeamDir` | Seam Direction |
| `SeamNumber` | Seam Number |
| `SeamType` | Seam Type |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |
| `To` | To |
| `Use` | Use |
| `Weld` | Weld |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `ShrinkageStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public ShrinkageStatement();`
- `public ShrinkageStatement(ShrinkageStatement source); // 浅拷贝构造函数`
- `public ShrinkageStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public ShrinkageStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `CType` | CType |
| `LineStr` | Line String |
| `M1` | M1 |
| `M2` | M2 |
| `M3` | M3 |
| `M4` | M4 |
| `M5` | M5 |
| `M6` | M6 |
| `Statement` | Statement string from all statement properties. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `StiffenerEnd`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public StiffenerEnd();`
- `public StiffenerEnd(StiffenerEnd source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `Bev` | Bevel |
| `BevMes` | Bevel Mes |
| `BevSid` | Bevel Side |
| `BevVar` | Bevel Var |
| `CompNo` | Overloaded. CompNo |
| `Connection` | Overloaded. Connection object |
| `EndType` | Overloaded. EndType |
| `Excess` | Excess EXC in schema syntax. |
| `IsMaterialSide` | Is attached to material side of connecting stiffener. |
| `KnuckleHeight` | Knuckle height KNH in schema syntax. |
| `KnuckleLength` | Knuckle Length KNL in schema syntax. |
| `Line` | Line Str |
| `MouldlineEndDefinition` | Mouldline End Definition |
| `NoAutoBevel` | No Auto Bevel NABE in schema syntax. |
| `NoAutoBevelFlange` | No Auto Bevel Flange NABF in schema syntax. |
| `NoAutoBevelWeb` | No Auto Bevel Web NABW in schema syntax. |
| `Pan` | Pan A panel name in single quotes. |
| `Panel` | Panel A panel name in single quotes. |
| `PointDefinition` | Point definition An intersecting line definition |
| `Reflect` | Reflect REF in schema syntax. |
| `TagCode` | Overloaded. TagCode |
| `Weld` | Weld EWE in schema syntax. |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `StiffenerEndConnection`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public StiffenerEndConnection();`
- `public StiffenerEndConnection(StiffenerEndConnection source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `ConnectionCode` | Overloaded. Connection code |
| `EndcutCode` | Overloaded. Endcut code |
| `Param1` | Endcut Parameter 1 |
| `Param2` | Endcut Parameter 2 |
| `Param3` | Endcut Parameter 3 |
| `Param4` | Endcut Paramter 4 |
| `Param5` | Endcut Parameter 5 |
| `Param6` | Endcut Parameter 6 |
| `Parameters` | Endcut parameters |
| `UserDefinedCutName` | User defined endcut name. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Manadatory interface on all PML callable .Net |
| `classes.` |  |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `StiffenerEndType`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public StiffenerEndType();`
- `public StiffenerEndType(StiffenerEndType source); // 浅拷贝构造函数`


### Properties

| Property | Description |
|---|---|
| `kEndAmbiguous` | EndAmbiguous enum value |
| `kEndBkt` | EndBkt enum value |
| `kEndHole` | EndHole enum value |
| `kEndLine` | EndLine enum value |
| `kEndNotSet` | EndNotSet enum value |
| `kEndOutCont` | EndOutCont enum value |
| `kEndPanel` | EndPanel enum value |
| `kEndPrCross` | EndPrCross enum value |
| `kEndProf` | EndProf enum value |
| `kEndPt` | EndPt enum value |
| `kEndSeam` | EndSeam enum value |
| `kEndSurf` | EndSurf enum value |

### Methods

| Method | Description |
|---|---|
| `Assign` |  |
| `Equals` | (inherited from Object) |
| `FromString` | String representation |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | String representation |

---

## Class `StiffenerStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public StiffenerStatement();`
- `public StiffenerStatement(StiffenerStatement source); // 浅拷贝构造函数`
- `public StiffenerStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public StiffenerStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `AssemblyReference` | Assembly Reference AR in schema syntax. |
| `AssemblyReferencePortside` | Assembly Reference Portside ARP in schema syntax. |
| `AssemblyReferenceStarboard` | Assembly Reference Starboard ARS in schema |
| `syntax.` |  |
| `Case` | Overloaded. Case CAS in schema syntax. |
| `Colour` | Overloaded. Colour /// COL in schema syntax. |
| `Comment` | Comment COM in schema syntax. |
| `Curved` | Curved CUR in schema syntax. |
| `CurveName` | Curve Name CUR in schema syntax. |
| `CurveNumber` | Overloaded. Curve contour number CNO in schema |
| `syntax` |  |
| `Destination` | Destination DES in schema syntax. |
| `DirectionAngel` | Overloaded. Direction Angel T in schema syntax. |
| `Distance` | Distance M1 in schema syntax. |
| `End1` | Overloaded. End 1 definition |
| `End2` | Overloaded. End 2 definition |
| `FunctionalDescription` | Overloaded. Functional Description |
| `GeneralPurposeString1` | General Purpose String 1 AS1 in schema syntax. |
| `GeneralPurposeString2` | General Purpose String 2 AS2 in schema syntax. |
| `GeneralPurposeString3` | General Purpose String 3 AS3 in schema syntax. |
| `GeneralPurposeString4` | General Purpose String 4 AS4 in schema syntax. |
| `GeneralStrings` | Overloaded. General Purpose Stringa GS1-(1)0 in |
| `schema` | syntax. |
| `Grinding` | Grinding GRI in schema syntax. |
| `HoleNumber` | Overloaded. Hole Number CNO in schema syntax |
| `Inclination` | Inclination INC, first parameter, in schema syntax. |
| `Inclination2` | Inclination, second parameter INC, second |
| `parameter,` | in schema syntax. |
| `LimitNumber` | Overloaded. Limit Number LIM in schema syntax. |
| `LimitTangentLine` | Limit Tangent Line Line definition in schema string. |
| `Line` | Line Schema line definition e.g Y=3000,5000,9000 |
| `MaterialSide` | Overloaded. Material Side MSI in schema syntax |
| `No` | No No in schema syntax. |
| `No2` | Number of mirrored stiffeners NO2 in schema |
| `syntax.` |  |
| `NoAutoBevTrace` | No Auto Bevel Trace NABT in schema syntax. |
| `NoMark` | No Mark NOM in schema syntax. |
| `Number` | Overloaded. Number NUMB in schema syntax. |
| `Partition` | Partition M2 in schema syntax. |
| `PositionNumber` | Position Number POS in schema syntax |
| `PositionNumberPortside` | Position Number Portside PPOS in schema syntax. |
| `PositionNumberStarboard` | Position Number Starboard SPOS in schema syntax |
| `ProfileParameter1` | Profile Parameter 1 PRO, second value, in schema |
| `syntax.` |  |
| `ProfileParameter2` | Profile Parameter 2 PRO, third value, in schema |
| `syntax.` |  |
| `ProfileParameter3` | Profile Parameter 3 PRO, fourth value, in schema |
| `syntax.` |  |
| `ProfileParameter4` | Profile Parameter 4 PRO, fifth value, in schema |
| `syntax.` |  |
| `ProfileParameter5` | Profile Parameter 5 PRO, sixth value, in schema |
| `syntax.` |  |
| `ProfileParameter6` | Profile Parameter 6 PRO, seventh value, in schema |
| `syntax.` |  |
| `ProfileParameters` | Profile parameters as a string PRO, all but first |
| `value,` | in schema syntax. |
| `ProfileType` | Overloaded. Profile type PRO, first value, in schema |
| `syntax.` |  |
| `Quality` | Quality QUA in schema syntax |
| `ReflectedCurve` | ReflectedCurve REF in schema syntax. |
| `Revert` | Revert REV in schema syntax. |
| `Shrinkage` | Shrinkage SHR in schema syntax. |
| `Side` | Overloaded. Side SID in schema syntax. |
| `SideUp` | Overloaded. Side Up SUP in schema syntax. |
| `Statement` | Scheme statement string from all statement |
| `properties.` |  |
| `SurfaceTreatment` | Surface Treatment SUR in schema syntax. |
| `Tag` | Tag TAG in schema syntax. |
| `Temporary` | Temporary TEM in schema syntax |
| `TraceBevel` | Trace Bevel TBE in schema syntax. |
| `TraceBevelEMeasure` | Trace Bevel E-Measure TME in schema syntax. |
| `TraceBevelSide` | Trace Bevel Side TBS in schema syntax. |
| `TraceBevelVariant` | Trace Bevel Variant TBV in schema syntax. |
| `UnSym` | UnSym - unsymmetrically UNS in schema syntax. |
| `ValidSymmetricalSide` | Valid Symmetrical Side "","SB","PS" |
| `Weld` | Weld WEL in schema syntax. |

### Methods

| Method | Description |
|---|---|
| `Assign` | Overloaded. |
| `Assign` | (inherited from StiffenerStatement) Overloaded. Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `SwageStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public SwageStatement();`
- `public SwageStatement(SwageStatement source); // 浅拷贝构造函数`
- `public SwageStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public SwageStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Colour` | Colour |
| `Comment` | Comment |
| `Height` | Height |
| `Limit` | Limit |
| `Line` | Line |
| `LineStr` | Line String |
| `M1` | M1 |
| `M2` | M2 |
| `No` | No |
| `Noof` | Noof |
| `Side` | Side |
| `Statement` | Statement string from all statement properties. |
| `Type` | Type |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `TAPStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public TAPStatement();`
- `public TAPStatement(TAPStatement source); // 浅拷贝构造函数`
- `public TAPStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public TAPStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `Colour` | Colour |
| `Comment` | Comment |
| `Corner` | Corner |
| `Hole` | Hole |
| `Limit` | Limit |
| `Notch` | Notch |
| `Number` | Number |
| `Panel` | Panel |
| `Parallel` | Parallel |
| `Profile` | Profile |
| `Reflect` | Reflect |
| `Seam` | Seam |
| `Statement` | Statement string from all statement properties. |
| `TagCode` | Tag code |
| `Type` | Type |
| `Valid` | Valid |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

## Class `WeldStatement`

- **Assembly**: `Aveva.Marine.Planar.dll`
- **Namespace**: `Aveva.Marine.Planar`

### Constructors

- `public WeldStatement();`
- `public WeldStatement(WeldStatement source); // 浅拷贝构造函数`
- `public WeldStatement(DbElement element); // 从 3D 数据库图元逆向提取语句`
- `public WeldStatement(string panelName, double groupNo); // 绑定至目标板架与特征组`


### Properties

| Property | Description |
|---|---|
| `BevAutomatic` | Bevel Automatic |
| `BevelCode` | Bevel Code |
| `BevEqual` | Bevel Equal |
| `BVT` | BVT |
| `ContourNo` | Contour No |
| `EiDistance` | Ei Distance |
| `EiEqEndLimit` | Ei Eq End Limit |
| `EiIntWithSeam` | Ei Int With Seam |
| `EiLine` | Ei Line |
| `FirstBevAng` | First Bevel Angle |
| `Grinding` | Grinding |
| `KnuckedAnglePanel` | Knucked Angle Panel |
| `KnuckledAngle` | Knuckled Angle |
| `KnuckledAngleType` | Knuckled Angle Type |
| `Limit` | Limit |
| `PlateNo` | Plate No |
| `ReferenceSide` | Reference Side |
| `SecndBevAng` | Second Bevel Angle |
| `SetNo` | Set No |
| `SiDistance` | SiDistance |
| `SiEqStartLimit` | Si Eq Start Limit |
| `SiIntWithSeam` | Si Int With Seam |
| `SiLine` | Si Line |
| `Statement` | Statement string from all statement properties. |
| `WeldNeg` | Weld Neg |
| `WeldPos` | Weld Pos |

### Methods

| Method | Description |
|---|---|
| `Assign` | Assign (shallow copy interface) |
| `Equals` | (inherited from Object) |
| `GetHashCode` | (inherited from Object) |
| `GetType` | (inherited from Object) |
| `ToString` | (inherited from Object) |

---

