# AVEVA Marine Core API Reference (`marAPI.dll`)

本手册收录从 `NETmarAPI.pdf`（共 1,171 页）中完整提取的全部 36 个托管核心类库、命名空间、属性（Properties）与方法（Methods）。所有类型均严格实现 `System.IDisposable` 并遵循非托管内存管理规范。

## Namespace: `Aveva.Marine.Production`

### Class `MarPinProfiles`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Production`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Production.MarPinProfiles` (implements `System.IDisposable`)
- **Description**: 曲面外板胎架活络样箱轮廓生成引擎，计算胎架高度矩阵与下料加工草图。

#### Constructors

- `public MarPinProfiles();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GenerateSketch` | `bool GenerateSketch(string profileName, ref string dwgName)` | GenerateSketch method |

---

## Namespace: `Aveva.Marine.Tools`

### Class `MarMiscTools`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Tools`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Tools.MarMiscTools` (implements `System.IDisposable`)
- **Description**: Marine 杂项工具服务类，提供底层辅助工具与资源生命周期接口。

#### Constructors

- `public MarMiscTools();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarMiscTools)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

## Namespace: `Aveva.Marine.UI`

### Class `MarButtonState`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.UI`
- **Inheritance**: `System.Object` -> `Aveva.Marine.UI.MarButtonState` (implements `System.IDisposable`)
- **Description**: 保存交互操作期间按钮状态（如锁定、激活、选项开关）的描述类。

#### Constructors

- `public MarButtonState();`
- `public MarButtonState(void* pPyButtonState); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `LockChecked` | `string LockChecked {get; set;}` | Lock button id to be checked (String): "U" - U lock checked "V" - V lock checked "" - |
| `LockEnabled` | `bool LockEnabled {get; set;}` | Lock buttons state (bool): false  disabled true  enabled |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `OptionsEnabled` | `bool OptionsEnabled {get; set;}` | Options button state (bool): false  disabled true  enabled |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarButtonState that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

#### Operators

| Operator | Signature | Description |
|---|---|---|
| `==` | `public static bool operator ==(MarButtonState left, MarButtonState right)` | 比较两个按钮状态是否一致 |
| `!=` | `public static bool operator !=(MarButtonState left, MarButtonState right)` | 比较两个按钮状态是否不同 |

---

### Class `MarStatPointPlanarReq`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.UI`
- **Inheritance**: `System.Object` -> `Aveva.Marine.UI.MarStatPointPlanarReq` (implements `System.IDisposable`)
- **Description**: 在定义 2D 平面点时（point2D_req）保存初始状态的提示参数类。

#### Constructors

- `public MarStatPointPlanarReq();`
- `public MarStatPointPlanarReq(void* pPyStat_point2D_req); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Cursor` | `Aveva.Marine.Drafting.MarCursorType Cursor {get; set;}` | Cursor type (MarCursorType) |
| `DefMode` | `string DefMode {get; set;}` | 2D point definition mode (String) |
| `HelpPoint` | `Aveva.Marine.Geometry.MarPointPlanar HelpPoint {get; set;}` | Definition of help point. This attribute is optional (MarPointPlanar) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Scale` | `double Scale {get; set;}` | Scale used in point selection. This attribute is optional (double) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarStatPointPlanarReq that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarStatPointReq`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.UI`
- **Inheritance**: `System.Object` -> `Aveva.Marine.UI.MarStatPointReq` (implements `System.IDisposable`)
- **Description**: 在定义 3D 空间点时（point3D_req）保存初始状态与参考模式的参数类。

#### Constructors

- `public MarStatPointReq();`
- `public MarStatPointReq(void* pPyStat_point3D_req); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Helpdef` | `int Helpdef {get; set;}` | Help point defined? (int): 0: No (default) 1: Yes |
| `HelpdefPML` | `double HelpdefPML {get; set;}` | Help point defined? (double): 0: No (default) 1: Yes |
| `Helppnt` | `Aveva.Marine.Geometry.MarPoint Helppnt {get; set;}` | The help point (if defined) (MarPoint) |
| `Initial2D` | `int Initial2D {get; set;}` | The initial way of defining a 2D point (used by Pick line) (int): = 1 Key in (2D) = 2 |
| `Initial2DPML` | `double Initial2DPML {get; set;}` | The initial way of defining a 2D point (used by Pick line) (double): = 1 Key in (2D) = 2 |
| `Initial3D` | `int Initial3D {get; set;}` | The initial way of defining the 3D point (int): = 1 Pick line (by indicating in a view) = 2 |
| `Initial3DPML` | `double Initial3DPML {get; set;}` | The initial way of defining the 3D point (double): = 1 Pick line (by indicating in a view) |
| `Lockstatic` | `int Lockstatic {get; set;}` | Initial lock protected? (int): 0: No (default) 1: Yes |
| `LockstaticPML` | `double LockstaticPML {get; set;}` | Initial lock protected? (double): 0: No (default) 1: Yes |
| `Locktype` | `int Locktype {get; set;}` | Type of lock (int): = 0 No lock (default) = 1 Lock plane = 2 Lock line |
| `LocktypePML` | `double LocktypePML {get; set;}` | Type of lock (double): = 0 No lock (default) = 1 Lock plane = 2 Lock line |
| `Lockvec` | `Aveva.Marine.Geometry.MarVector Lockvec {get; set;}` | A vector perpendicular to the plane parallel to the line (normalized) (if lock) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarStatPointReq that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarUi`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.UI`
- **Inheritance**: `System.Object` -> `Aveva.Marine.UI.MarUi` (implements `System.IDisposable`)
- **Description**: AVEVA Marine 原生界面自动化服务类，负责与宿主界面的原生交互（弹窗输入、颜色选择、窗口控制、Form 编译与控件管理）。

#### Constructors

- `public MarUi();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `LastError` | `string LastError {get; set;}` | LastError property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AnswerReq` | `int AnswerReq(string Title, string Question)` | The function presents a box with a question and lets the user give the answer |
| `AnswerReqPML` | `double AnswerReqPML(string Title, string Question)` | The function presents a box with a question and lets the user give the answer (PML |
| `AppWindowMaximize` | `void AppWindowMaximize()` | The function maximizes application window |
| `AppWindowMinimize` | `void AppWindowMinimize()` | The function minimizes application window |
| `AppWindowRefresh` | `void AppWindowRefresh()` | The function refreshes the application window |
| `AppWindowRestore` | `void AppWindowRestore()` | The function restores application window to its original size |
| `Assign` | `void Assign(MarUi that)` | Copies the current instance state into that (shallow copy interface) |
| `ChoiceSelect` *(Overloads: 6)* | `double ChoiceSelect(string,string,MarStringlist,ref double)` | ChoiceSelect method |
| `ColourSelect` | `int ColourSelect(string Title, MarColour Colour)` | The function presents a colour box and lets the user select a colour |
| `ColourSelectPML` | `double ColourSelectPML(string Title, MarColour Colour)` | The function presents a colour box and lets the user select a colour (PML Version) |
| `DimCreate` *(Overloads: 2)* | `void DimCreate(double)` | The function presents the userinterface for creating a dimension |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `FormCancel` *(Overloads: 2)* | `void FormCancel(double)` | The function cancels a form |
| `FormChangeabilitySet` *(Overloads: 2)* | `void FormChangeabilitySet(double,string,double)` | The function sets the changeability of a form |
| `FormCompile` | `int FormCompile(string Name)` | The function compiles a form |
| `FormCompilePML` | `double FormCompilePML(string Name)` | The function compiles a form (PML Version) |
| `FormEdit` *(Overloads: 2)* | `double FormEdit(double)` | The function makes it possible to edit a form |
| `FormEnumGet` *(Overloads: 2)* | `string FormEnumGet(double,string)` | The function gets the value of an enumerated field in the form |
| `FormEnumSet` *(Overloads: 2)* | `void FormEnumSet(double,string,string)` | The function sets an enumerated field in the form |
| `FormIntegerGet` *(Overloads: 2)* | `double FormIntegerGet(double,string)` | The function gets the value of an integer field in the form |
| `FormIntegerSet` *(Overloads: 2)* | `void FormIntegerSet(double,string,double)` | The function sets an integer field in the form |
| `FormRealGet` *(Overloads: 2)* | `double FormRealGet(double,string)` | The function gets the value of a real field in the form |
| `FormRealSet` *(Overloads: 2)* | `void FormRealSet(double,string,double)` | The function sets a real field in the form |
| `FormReferenceGet` | `int FormReferenceGet(string Name)` | The function gets a reference to a form |
| `FormReferenceGetPML` | `double FormReferenceGetPML(string Name)` | The function gets a reference to a form (PML Version) |
| `FormStringGet` *(Overloads: 2)* | `string FormStringGet(double,string)` | The function gets the value of a string field in the form |
| `FormStringSet` *(Overloads: 2)* | `void FormStringSet(double,string,string)` | The function sets a string field in the form |
| `FormToggleGet` *(Overloads: 2)* | `double FormToggleGet(double,string)` | The function gets the value of a toggle field in the form |
| `FormToggleSet` *(Overloads: 2)* | `void FormToggleSet(double,string,double)` | The function sets a toggle field in the form |
| `IntReq` *(Overloads: 5)* | `double IntReq(string,ref double)` | IntReq method |
| `IntReqArray` | `void IntReqArray()` | IntReqArray method |
| `LabelCreate` | `void LabelCreate()` | The function presents the Annotate->Label interface |
| `MessageConfirm` | `void MessageConfirm(string Message)` | The function presents a box with a message and lets the user confirm it |
| `MessageNoConfirm` | `void MessageNoConfirm(string Message)` | The function presents a message to the user without confirmation |
| `ModDimension` | `void ModDimension()` | The function presents the userinterface for modifying a dimension |
| `ModelInfo` | `int ModelInfo()` | The function displays information about user-indicated models. The function interacts |
| `ModelInfoPML` | `double ModelInfoPML()` | The function displays information about user-indicated models. The function interacts |
| `ModLabel` | `void ModLabel()` | The function presents the userinterface for modifying a label |
| `PointPlanarReq` *(Overloads: 3)* | `int PointPlanarReq(string,MarPointPlanar)` | The function presents a message to the user and lets him define a 2D point in the |
| `PointPlanarReqPML` *(Overloads: 3)* | `double PointPlanarReqPML(string,MarPointPlanar)` | The function presents a message to the user and lets him define a 2D point in the |
| `PointReq` *(Overloads: 2)* | `int PointReq(string,MarPoint)` | The function presents a message to the user and lets him define a 3D point in the |
| `PointReqPML` *(Overloads: 2)* | `double PointReqPML(string,MarPoint)` | The function presents a message to the user and lets him define a 3D point in the |
| `RealReq` *(Overloads: 3)* | `int RealReq(string,ref double)` | RealReq method |
| `RealReqArray` | `void RealReqArray()` | RealReqArray method |
| `RealReqPML` *(Overloads: 2)* | `double RealReqPML(string,ref double)` | The function presents a box with a message and lets the user key in a real (PML |
| `StringReq` *(Overloads: 3)* | `int StringReq(string,ref string)` | StringReq method |
| `StringReqArray` | `void StringReqArray()` | StringReqArray method |
| `StringReqPML` *(Overloads: 2)* | `double StringReqPML(string,ref string)` | The function presents a box with a message and lets the user key in a string (PML |
| `StringSelect` *(Overloads: 6)* | `double StringSelect(string,string,string,MarStringlist,ref double)` | StringSelect method |
| `SymbolSelect` *(Overloads: 6)* | `double SymbolSelect(string,MarSymbollist,ref double,ref double)` | SymbolSelect method |

---

## Namespace: `Aveva.Marine.Utility`

### Class `MarCommonProperties`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarCommonProperties` (implements `System.IDisposable`)
- **Description**: 构件通用属性管理类，用于读取和设置 Marine 图元别名（Alias）与类型编码（TypeCode）。

#### Constructors

- `public MarCommonProperties();`
- `public MarCommonProperties(void* pPyCommonProperties); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Alias1` | `string Alias1 {get; set;}` | Alias (String) |
| `Alias2` | `string Alias2 {get; set;}` | Alias (String) |
| `Alias3` | `string Alias3 {get; set;}` | Alias (String) |
| `Alias4` | `string Alias4 {get; set;}` | Alias (String) |
| `CostCode` | `string CostCode {get; set;}` | Cost code (String) |
| `Description` | `string Description {get; set;}` | Description (String) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `PlanningUnit` | `string PlanningUnit {get; set;}` | Planning unit (String) |
| `Remarks` | `string Remarks {get; set;}` | Remarks (String) |
| `TypeCode1` | `int TypeCode1 {get; set;}` | Type code (int) |
| `TypeCode1PML` | `double TypeCode1PML {get; set;}` | Type code (double) |
| `TypeCode2` | `int TypeCode2 {get; set;}` | Type code (int) |
| `TypeCode2PML` | `double TypeCode2PML {get; set;}` | Type code (double) |
| `TypeCode3` | `int TypeCode3 {get; set;}` | Type code (int) |
| `TypeCode3PML` | `double TypeCode3PML {get; set;}` | Type code (double) |
| `TypeCode4` | `int TypeCode4 {get; set;}` | Type code (int) |
| `TypeCode4PML` | `double TypeCode4PML {get; set;}` | Type code (double) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarCommonProperties that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetAlias` | `void GetAlias()` | To get alias |
| `GetAliasPML` | `Hashtable GetAliasPML()` | To get alias |
| `GetTypeCode` | `void GetTypeCode()` | To get type code |
| `GetTypeCodePML` | `Hashtable GetTypeCodePML()` | To get type code |
| `SetAlias` *(Overloads: 2)* | `void SetAlias(double,string)` | To set alias |
| `SetTypeCode` *(Overloads: 2)* | `void SetTypeCode(double,double)` | To set type code |

---

### Class `MarDataBase`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDataBase` (implements `System.IDisposable`)
- **Description**: 专门面向 Marine 结构模型的查询网关，提供 ObjectListGet 与 DwgListGet 构件/图纸检索方法。

#### Constructors

- `public MarDataBase();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `LastError` | `string LastError {get; set;}` | LastError property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarDataBase that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `DwgListGet` | `void DwgListGet()` | DwgListGet method |
| `DwgListGetPML` | `Hashtable DwgListGetPML(double dwgType, string dwgName)` | The function returns a collection of drawings that matches the given criteria |
| `ObjectListGet` | `void ObjectListGet()` | ObjectListGet method |
| `ObjectListGetPML` | `Hashtable ObjectListGetPML(MarObjectCriteria objectCriteria, string DataBankName)` | PML-compatible version of ObjectListGet |

---

### Class `MarDate`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDate` (implements `System.IDisposable`)
- **Description**: Marine 原生日期封装类，提供标准日期解析、设置与 PML 互操作。

#### Constructors

- `public MarDate();`
- `public MarDate(int year, int month, int day);`
- `public MarDate(double year, double month, double day);`
- `public MarDate(void* pPyDate); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Day` | `int Day {get; set;}` | Day (int) |
| `DayPML` | `double DayPML {get; set;}` | Day (double) |
| `Month` | `int Month {get; set;}` | Month (int) |
| `MonthPML` | `double MonthPML {get; set;}` | Month (double) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Year` | `int Year {get; set;}` | Year (int) |
| `YearPML` | `double YearPML {get; set;}` | Year (double) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarDate that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetDate` *(Overloads: 2)* | `void GetDate(ref double,ref double,ref double)` | Gets date |
| `SetDate` *(Overloads: 3)* | `void SetDate(MarDate)` | Sets date |

#### Operators

| Operator | Signature | Description |
|---|---|---|
| `==` | `public static bool operator ==(MarDate left, MarDate right)` | 比较两个日期是否完全一致 |
| `!=` | `public static bool operator !=(MarDate left, MarDate right)` | 比较两个日期是否不同 |

---

### Class `MarDateTime`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDateTime` (implements `System.IDisposable`)
- **Description**: Marine 原生日期与时间组合封装类，支持时序与版本时间戳比对。

#### Constructors

- `public MarDateTime();`
- `public MarDateTime(int year, int month, int day, int hour, int minute, int second, int hund);`
- `public MarDateTime(double year, double month, double day, double hour, double minute, double second, double hund);`
- `public MarDateTime(void* pPyDateTime); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarDateTime that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetDateTime` *(Overloads: 2)* | `void GetDateTime(ref double,ref double,ref double,ref double,ref double,ref doub Gets date public void GetDateTime(ref int,ref int,ref int,ref int,ref int,ref int,ref int)` | Gets date |
| `SetDateTime` *(Overloads: 3)* | `void SetDateTime(MarDateTime)` | Sets date |

#### Operators

| Operator | Signature | Description |
|---|---|---|
| `==` | `public static bool operator ==(MarDateTime left, MarDateTime right)` | 比较两个时间戳是否完全一致 |
| `!=` | `public static bool operator !=(MarDateTime left, MarDateTime right)` | 比较两个时间戳是否不同 |

---

### Class `MarInternalComm`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarInternalComm` (implements `System.IDisposable`)
- **Description**: Marine 内部通信中介层，提供二维轮廓求交分割、曲线取点、图层与字体操作。

#### Constructors

- `public MarInternalComm();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `LastError` | `string LastError {get; set;}` | LastError property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarInternalComm that)` | Copies the current instance state into that (shallow copy interface) |
| `ColourNamesGet` | `void ColourNamesGet()` | The function returns colour names |
| `ColourNamesGetPML` | `Hashtable ColourNamesGetPML()` | The function returns colour names |
| `CompBoxSet` *(Overloads: 2)* | `void CompBoxSet(MarSymbolicView)` | Component box set |
| `ContourSplit` *(Overloads: 2)* | `void ContourSplit()` | Gets intersection point of two contours |
| `CurvePointGet` *(Overloads: 2)* | `double CurvePointGet(double,double,string,MarPoint)` | The procedure takes a 3d point and contour from a curve and outputs a 3d point on |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `DivPointGet` *(Overloads: 4)* | `double DivPointGet(double,double,double,double,MarPoint)` | The procedure takes a 3d point and a contour and outputs a 3d point on the given |
| `FontNameGet` *(Overloads: 2)* | `string FontNameGet(double)` | The procedure takes a font id and returns its name |
| `IntersectionPointsGet` | `void IntersectionPointsGet()` | Gets intersection point of two contours |
| `IntersectionPointsGetPML` | `Hashtable IntersectionPointsGetPML(MarContourPlanar Contour1, MarContourPlanar Contour2)` | Gets intersection point of two contours |
| `LayerDescGet` *(Overloads: 2)* | `string LayerDescGet(double)` | The procedure takes a layer id and returns its description |
| `LengthCtocGet` *(Overloads: 2)* | `double LengthCtocGet(double,double,double,double)` | Returns nearest distance between two 2D-arc contours |
| `LengthPtopGet` *(Overloads: 2)* | `double LengthPtopGet(double,double,double,double,MarPoint,MarPoint)` | Calculate length on curve between two 3d points |
| `LinetypesGet` | `StringStringDictionary LinetypesGet()` | Get line types names as dictionary: system name - alias name |
| `PartnameSide` | `int PartnameSide(MarModel Model)` | Get side to use when creating part name |
| `PartnameSidePML` | `double PartnameSidePML(MarModel Model)` | Get side to use when creating part name |
| `TransfCombine2d` | `bool TransfCombine2d(MarTransformationPlanar Transf2d1, MarTransformationPlanar Transf2d2)` | Performs concatenation |
| `TransfDecompose2d` | `void TransfDecompose2d()` | Matrix decomposition |
| `TransfDecompose2dPML` | `Hashtable TransfDecompose2dPML(MarTransformationPlanar Transf2d)` | Matrix decomposition |
| `TransfInvert2d` | `bool TransfInvert2d(MarTransformationPlanar Transf2d)` | Performs inversion |
| `TransfReflect2d` | `bool TransfReflect2d(MarTransformationPlanar Transf2d, MarPointPlanar Point2d, MarVectorPlanar Vector2d)` | Performs reflection |
| `TransfRotate2d` | `bool TransfRotate2d(MarTransformationPlanar Transf2d, MarPointPlanar Point, double Angle)` | Performs rotation |
| `TransfScale2d` | `bool TransfScale2d(MarTransformationPlanar Transf2d, double Scale)` | Performs scaling |
| `TransfTranslate2d` | `bool TransfTranslate2d(MarTransformationPlanar Transf2d, MarVectorPlanar Vector2d)` | Performs translation |

---

### Class `MarNone`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarNone` (implements `System.IDisposable`)
- **Description**: Marine 专用空对象/无效值哨兵类，用于判断函数返回句柄是否有效或向特定函数传递缺省状态。

#### Constructors

- `public MarNone();`


*No public properties defined.*

*No public methods defined.*

---

### Class `MarObject`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarObject` (implements `System.IDisposable`)
- **Description**: AVEVA Marine 所有业务对象的通用基类，提供 Assign 浅拷贝与非托管指针清理逻辑。

#### Constructors

- `public MarObject();`
- `public MarObject(void* pPyObject); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `CodeOne` | `int CodeOne {get; set;}` | CodeOne property |
| `CodeOnePML` | `double CodeOnePML {get; set;}` | PML-compatible version of CodeOne |
| `CodeTwo` | `int CodeTwo {get; set;}` | CodeTwo property |
| `CodeTwoPML` | `double CodeTwoPML {get; set;}` | PML-compatible version of CodeTwo |
| `CreationDate` | `MarDateTime CreationDate {get; set;}` | CreationDate property |
| `Name` | `string Name {get; set;}` | Name property |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Size` | `int Size {get; set;}` | Size property |
| `SizePML` | `double SizePML {get; set;}` | PML-compatible version of Size |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarObject that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarObjectCriteria`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarObjectCriteria` (implements `System.IDisposable`)
- **Description**: 查询过滤器描述类，用于设定构件名匹配模式、类型过滤器和模型状态掩码。

#### Constructors

- `public MarObjectCriteria();`
- `public MarObjectCriteria(void* pPyObject); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarObjectCriteria that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetCodeOne` | `int GetCodeOne()` | GetCodeOne method |
| `GetCodeOnePML` | `double GetCodeOnePML()` | PML-compatible version of GetCodeOne |
| `GetCodeTwo` | `int GetCodeTwo()` | GetCodeTwo method |
| `GetCodeTwoPML` | `double GetCodeTwoPML()` | PML-compatible version of GetCodeTwo |
| `GetCreationDate` | `void GetCreationDate()` | GetCreationDate method |
| `GetCreationDatePML` | `Hashtable GetCreationDatePML()` | PML-compatible version of GetCreationDate |
| `GetName` | `string GetName()` | GetName method |
| `GetNamePML` | `string GetNamePML()` | PML-compatible version of GetName |
| `GetSize` | `void GetSize()` | GetSize method |
| `GetSizePML` | `Hashtable GetSizePML()` | PML-compatible version of GetSize |
| `SetCodeOne` *(Overloads: 1)* | `void SetCodeOne()` | SetCodeOne method |
| `SetCodeOnePML` *(Overloads: 1)* | `void SetCodeOnePML()` | PML-compatible version of SetCodeOne |
| `SetCodeTwo` *(Overloads: 1)* | `void SetCodeTwo()` | SetCodeTwo method |
| `SetCodeTwoPML` *(Overloads: 1)* | `void SetCodeTwoPML()` | PML-compatible version of SetCodeTwo |
| `SetCreationDate` *(Overloads: 2)* | `void SetCreationDate()` | SetCreationDate method |
| `SetCreationDatePML` *(Overloads: 2)* | `void SetCreationDatePML()` | PML-compatible version of SetCreationDate |
| `SetName` *(Overloads: 1)* | `void SetName()` | SetName method |
| `SetNamePML` *(Overloads: 1)* | `void SetNamePML()` | PML-compatible version of SetName |
| `SetSize` *(Overloads: 2)* | `void SetSize()` | SetSize method |
| `SetSizePML` *(Overloads: 2)* | `void SetSizePML()` | PML-compatible version of SetSize |

---

### Class `MarPythonEngine`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarPythonEngine` (implements `System.IDisposable`)
- **Description**: 运行在 Marine 进程内的 Python 执行引擎封装，提供执行脚本和初始化环境方法。

#### Constructors

- `public MarPythonEngine();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarPythonEngine that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `RunPythonScript` | `void RunPythonScript(string Name)` | Checks if frame positions exist |

---

### Class `MarPythonObject`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarPythonObject` (implements `System.IDisposable`)
- **Description**: Python 对象的托管包装，支持跨语言方法调用与属性动态读取。

#### Constructors

- `public MarPythonObject();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddArgument` *(Overloads: 4)* | `void AddArgument(MarPythonObject)` | AddArgument method |
| `BeginInvoke` | `void BeginInvoke(string module)` | Initiates a python call. Call this method before any call to InvokeMethod and |
| `CreatePythonObject` | `MarPythonObject CreatePythonObject(string cls)` | Creates an instance of a Python class |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetProperty` *(Overloads: 4)* | `void GetProperty(string,out MarPythonObject)` | GetProperty method |
| `InvokeMethod` *(Overloads: 5)* | `void InvokeMethod(string)` | Call a python method (see BeginInvoke) |
| `SetProperty` *(Overloads: 4)* | `void SetProperty(string,MarPythonObject)` | SetProperty method |

---

### Class `MarPythonObjectPML`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarPythonObjectPML` (implements `System.IDisposable`)
- **Description**: 专为 PML 设计的 Python 包装器，打通 Python 脚本与 PML 表单/宏的双向通信。

#### Constructors

- `public MarPythonObjectPML();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddDoubleArgument` | `void AddDoubleArgument(double arg)` | AddDoubleArgument method |
| `AddIntArgument` | `void AddIntArgument(double arg)` | AddIntArgument method |
| `AddObjectArgument` | `void AddObjectArgument(MarPythonObjectPML arg)` | AddObjectArgument method |
| `AddStringArgument` | `void AddStringArgument(string arg)` | AddStringArgument method |
| `Assign` | `void Assign(MarPythonObjectPML that)` | Copies the current instance state into that (shallow copy interface) |
| `BeginInvoke` | `void BeginInvoke(string module)` | BeginInvoke method |
| `CreatePythonObject` | `MarPythonObjectPML CreatePythonObject(string cls)` | CreatePythonObject method |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetDoubleProperty` | `double GetDoubleProperty(string propName)` | GetDoubleProperty method |
| `GetIntProperty` | `double GetIntProperty(string propName)` | GetIntProperty method |
| `GetObjectProperty` | `MarPythonObjectPML GetObjectProperty(string propName)` | GetObjectProperty method |
| `GetStringProperty` | `string GetStringProperty(string propName)` | GetStringProperty method |
| `InvokeDoubleMethod` | `double InvokeDoubleMethod(string function)` | InvokeDoubleMethod method |
| `InvokeIntMethod` | `double InvokeIntMethod(string function)` | InvokeIntMethod method |
| `InvokeMethod` | `void InvokeMethod(string function)` | InvokeMethod method |
| `InvokeObjectMethod` | `MarPythonObjectPML InvokeObjectMethod(string function)` | InvokeObjectMethod method |
| `InvokeStringMethod` | `string InvokeStringMethod(string function)` | InvokeStringMethod method |
| `SetDoubleProperty` | `void SetDoubleProperty(string propName, double value)` | SetDoubleProperty method |
| `SetIntProperty` | `void SetIntProperty(string propName, double value)` | SetIntProperty method |
| `SetObjectProperty` | `void SetObjectProperty(string propName, MarPythonObjectPML value)` | SetObjectProperty method |
| `SetStringProperty` | `void SetStringProperty(string propName, string value)` | SetStringProperty method |

---

### Class `MarPythonUtil`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarPythonUtil` (implements `System.IDisposable`)
- **Description**: Python 脚本辅助工具类，提供 Python 交互与环境转换支持。

#### Constructors

- `public MarPythonUtil();`
- `public MarPythonUtil(void* pPyPythonUtil); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AppendPythonPath` | `void AppendPythonPath(string path)` | Appends python path |
| `Assign` | `void Assign(MarPythonUtil that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarRunModeOptions`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarRunModeOptions` (implements `System.IDisposable`)
- **Description**: 运行时运行模式配置类，用于设定批处理（Batch）或交互式（Interactive）执行策略。

#### Constructors

- `public MarRunModeOptions();`
- `public MarRunModeOptions(void* pPyRunModeOptions); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `ConfirmGeneration` | `int ConfirmGeneration {get; set;}` | Confirm generation option (int) |
| `ConfirmGenerationPML` | `double ConfirmGenerationPML {get; set;}` | Confirm generation option (double) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `TraceOn` | `int TraceOn {get; set;}` | Trace on option (int) |
| `TraceOnPML` | `double TraceOnPML {get; set;}` | Trace on option (double) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarRunModeOptions that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarStringlist`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarStringlist` (implements `System.IDisposable`)
- **Description**: Marine 高性能字符串列表容器类，用于跨非托管边界传递批量文本数组。

#### Constructors

- `public MarStringlist();`
- `public MarStringlist(string inString);`
- `public MarStringlist(void* pPyStringlist); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddString` | `void AddString(string inString)` | Add a new string to the list |
| `Assign` | `void Assign(MarStringlist that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarTbBaseException`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarTbBaseException` (implements `System.IDisposable`)
- **Description**: Marine 底层异常基类，所有来自 Marine 原生核心的错误均继承自此类。

#### Constructors

- `public MarTbBaseException();`
- `public MarTbBaseException(void* pPyTbBaseException); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `strError` | `string strError {get; set;}` | strError property |
| `strFunctionName` | `string strFunctionName {get; set;}` | strFunctionName property |
| `strModuleName` | `string strModuleName {get; set;}` | strModuleName property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |

---

### Class `MarTime`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarTime` (implements `System.IDisposable`)
- **Description**: Marine 原生时间封装类，支持毫秒级时间参数设定与格式化。

#### Constructors

- `public MarTime();`
- `public MarTime(void* pPyTime); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Hour` | `int Hour {get; set;}` | hour (int) |
| `HourPML` | `double HourPML {get; set;}` | hour (double) |
| `Hundredths` | `int Hundredths {get; set;}` | hundredths of second (int) |
| `HundredthsPML` | `double HundredthsPML {get; set;}` | hundredths of second (double) |
| `Minute` | `int Minute {get; set;}` | minute (int) |
| `MinutePML` | `double MinutePML {get; set;}` | minute (double) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Second` | `int Second {get; set;}` | second (int) |
| `SecondPML` | `double SecondPML {get; set;}` | second (double) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarTime that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetTime` *(Overloads: 2)* | `void GetTime(ref double,ref double,ref double,ref double)` | To get time |
| `SetTime` *(Overloads: 3)* | `void SetTime(MarTime)` | To set time |

---

### Class `MarUtil`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarUtil` (implements `System.IDisposable`)
- **Description**: Marine 通用工具服务类，提供应用程序类型检测、宏命令动态注入、坐标系转换与撤销管理。

#### Constructors

- `public MarUtil();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `LastError` | `string LastError {get; set;}` | LastError property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddCommand` | `void AddCommand(string cmd)` | The function adds a command to be executed. |
| `All` | `int All()` | The function returns a value that is equal to user response ALL |
| `AllPML` | `double AllPML()` | The function returns a value that is equal to user response ALL (PML Version) |
| `AppBasicDesign` | `bool AppBasicDesign()` | The function checks if Basic Design is the current application |
| `AppCable` | `bool AppCable()` | The function checks if Cable Modelling is the current application |
| `AppCurvedHull` | `bool AppCurvedHull()` | The function checks if Curved Hull Modelling is the current application |
| `AppDiagram` | `bool AppDiagram()` | The function checks if Diagram is the current application |
| `AppDrafting` | `bool AppDrafting()` | The function checks if Drafting is the current application |
| `ApplicationNumber` | `int ApplicationNumber(string applicationName)` | The function returns application number. |
| `ApplicationNumberPML` | `double ApplicationNumberPML(string applicationName)` | The function returns application number. |
| `AppNesting` | `bool AppNesting()` | The function checks if Nesting is the current application |
| `AppPipe` | `bool AppPipe()` | The function checks if Pipe Modelling is the current application |
| `AppPlanarHull` | `bool AppPlanarHull()` | The function checks if Hull Modelling is the current application |
| `AppPlcm` | `bool AppPlcm()` | The function checks if Pipe Modelling is the current application |
| `AppStructure` | `bool AppStructure()` | The function checks if Structure is the current application |
| `AppVentilation` | `bool AppVentilation()` | The function checks if Pipe Modelling is the current application |
| `Assign` | `void Assign(MarUtil)` | Copies the current instance state into that (shallow copy interface) |
| `Cancel` | `int Cancel()` | The function returns a value that is equal to user response CANCEL |
| `CancelPML` | `double CancelPML()` | The function returns a value that is equal to user response CANCEL (PML Version) |
| `CleanWorkspace` | `void CleanWorkspace()` | The function cleans the workspace of all objects not reserved by the current |
| `CoordToPos` *(Overloads: 3)* | `double CoordToPos(double,double,ref double,ref double)` | Express a co-ordinate as a main axis position (FR or LP term) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `ExitFunction` | `int ExitFunction()` | The function returns a value that is equal to user response EXIT_FUNCTION |
| `ExitFunctionPML` | `double ExitFunctionPML()` | The function returns a value that is equal to user response EXIT_FUNCTION (PML |
| `ExitProgram` | `void ExitProgram()` | The function terminates the Marine program |
| `Failure` | `int Failure()` | The function returns error value |
| `FailurePML` | `double FailurePML()` | The function returns error value (PML Version) |
| `No` | `int No()` | The function returns a value that is equal to user response NO |
| `NoPML` | `double NoPML()` | The function returns a value that is equal to user response NO (PML Version) |
| `Ok` | `int Ok()` | The function returns a value that is equal to user response OK |
| `OkPML` | `double OkPML()` | The function returns a value that is equal to user response OK (PML Version) |
| `OperationComplete` | `int OperationComplete()` | The function returns a value that is equal to user response OPERATION COMPLETE |
| `OperationCompletePML` | `double OperationCompletePML()` | The function returns a value that is equal to user response OPERATION COMPLETE |
| `Options` | `int Options()` | The function returns a value that is equal to user response OPTIONS |
| `OptionsPML` | `double OptionsPML()` | The function returns a value that is equal to user response OPTIONS (PML Version) |
| `PosToCoord` *(Overloads: 3)* | `double PosToCoord(double,double,ref double)` | Translate a FR or LP position to a co-ordinate |
| `Quit` | `int Quit()` | The function returns a value that is equal to user response QUIT |
| `QuitPML` | `double QuitPML()` | The function returns a value that is equal to user response QUIT (PML Version) |
| `Reject` | `int Reject()` | The function returns a value that is equal to user response REJECT |
| `RejectPML` | `double RejectPML()` | The function returns a value that is equal to user response REJECT (PML Version) |
| `Success` | `int Success()` | The function returns success value |
| `SuccessPML` | `double SuccessPML()` | The function returns success value (PML Version) |
| `SwitchApplication` | `bool SwitchApplication(string applicationName)` | The function executes a command. |
| `TBEnvironmentGet` | `string TBEnvironmentGet(string Env)` | The function gets the value of a Marine environment variable |
| `TBEnvironmentSet` | `void TBEnvironmentSet(string Env, string Value)` | The function sets a Marine environment variable |
| `TraCoordPan` *(Overloads: 2)* | `bool TraCoordPan(MarPointPlanar,string,MarPoint)` | Get a co-ordinate in the panel co-ordinate system from an earlier made indication in |
| `TraCoordShip` *(Overloads: 2)* | `bool TraCoordShip(MarPointPlanar,string,MarPoint)` | Get a coordinate in the ship coordinate system, from an earlier made indication in the |
| `TriggerAbort` | `int TriggerAbort()` | Return this function from a trigger to abort the function that fired the trigger |
| `TriggerAbortPML` | `double TriggerAbortPML()` | Return this function from a trigger to abort the function that fired the trigger (PML |
| `TriggerOk` | `int TriggerOk()` | Return this function from a trigger to continue the function that fired the trigger |
| `TriggerOkPML` | `double TriggerOkPML()` | Return this function from a trigger to continue the function that fired the trigger (PML |
| `TriggerOverride` | `int TriggerOverride()` | Return this function from a trigger to override the function that fired the trigger |
| `TriggerOverridePML` | `double TriggerOverridePML()` | Return this function from a trigger to override the function that fired the trigger (PML |
| `ULock` | `int ULock()` | The function returns a value that is equal to user response U_LOCK |
| `ULockPML` | `double ULockPML()` | The function returns a value that is equal to user response U_LOCK (PML Version) |
| `Undo` | `int Undo()` | The function returns a value that is equal to user response UNDO |
| `UndoPML` | `double UndoPML()` | The function returns a value that is equal to user response UNDO (PML Version) |
| `Unlock` | `int Unlock()` | The function returns a value that is equal to user response UNLOCK |
| `UnlockPML` | `double UnlockPML()` | The function returns a value that is equal to user response UNLOCK (PML Version) |
| `VLock` | `int VLock()` | The function returns a value that is equal to user response V_LOCK |
| `VLockPML` | `double VLockPML()` | The function returns a value that is equal to user response V_LOCK (PML Version) |
| `Yes` | `int Yes()` | The function returns a value that is equal to user response YES |
| `YesPML` | `double YesPML()` | The function returns a value that is equal to user response YES (PML Version) |

---

### Class `MarVitesseException`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarVitesseException` (implements `System.IDisposable`)
- **Description**: 捕获 Python/Vitesse 脚本语法错误与运行时未处理异常的专用异常类。

#### Constructors

- `public MarVitesseException();`
- `public MarVitesseException(string error);`
- `public MarVitesseException(string error, string module, string function);`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `ErrorMessage` | `string ErrorMessage {get; set;}` | new public string ErrorMessage {get; set;} |
| `Function` | `string Function {get; set;}` | Function property |
| `Module` | `string Module {get; set;}` | Module property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarVitesseException that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `ToString` | `void ToString()` | ToString method |

---

### Class `Misc`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.Misc` (implements `System.IDisposable`)
- **Description**: Marine 内部控制类，提供项目登录、会话初始化、画布重绘与 UTF-8 编码转换。

#### Constructors

- `public Misc();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `DoCommand` | `int DoCommand(string command)` | For internal use |
| `FromUtf8` | `string FromUtf8(basic_string<char\,std::char_traits<char>\,std::allocator<char> >* in)` | FromUtf8 method |
| `GotFocus` | `int GotFocus(IntPtr hWnd)` | For internal use |
| `Init` | `int Init(int module)` | For internal use |
| `InitMessage` | `int InitMessage()` | For internal use |
| `IsAnsiOnly` | `bool IsAnsiOnly(basic_string<char\,std::char_traits<char>\,std::allocator<char> >* str)` | IsAnsiOnly method |
| `Login` *(Overloads: 4)* | `int Login(string,string,string,string,bool)` | Login and open project. This method initializes the Hull Design module. |
| `MouseDown` | `int MouseDown(IntPtr hWnd, int x, int y, int button, int modifiers)` | For internal use |
| `MouseMove` | `int MouseMove(IntPtr hWnd, int x, int y, int button, int modifiers)` | For internal use |
| `Redraw` | `int Redraw(IntPtr hWnd, IntPtr hDC)` | For internal use |
| `SetCanvas` | `int SetCanvas(IntPtr hWnd, int width, int height, int displayNo)` | For internal use |
| `SetMessageWindow` | `int SetMessageWindow(IntPtr hWnd)` | For internal use |
| `Terminate` | `int Terminate()` | Logoff and close project. |
| `ToUtf8` | `bool ToUtf8(string in, basic_string<char\,std::char_traits<char>\,std::allocator<char> >* out)` | ToUtf8 method |

---

## Namespace: `Aveva.Marine.Utility.MarDictionaries`

### Class `IntStringArrayDictionary`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility.MarDictionaries`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDictionaries.IntStringArrayDictionary` (implements `System.IDisposable`)
- **Description**: 键为 int、值为 string[] 的 Marine 专属强类型哈希字典类。

#### Constructors

- `public IntStringArrayDictionary();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Keys` | `System.Collections.ICollection Keys {get;}` | Gets an ICollection object containing the keys of the Dictionary object |
| `Values` | `System.Collections.ICollection Values {get;}` | Gets an ICollection object containing the values of the Dictionary object |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Add` | `void Add(int key, string[] value)` | Adds the specified key and value to the dictionary |
| `Contains` | `bool Contains(int key)` | Determines whether the Dictionary object contains an element with the specified key |
| `Remove` | `void Remove(int key)` | Removes the element with the specified key from the Dictionary object |

---

### Class `StringDoubleArrayDictionary`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility.MarDictionaries`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDictionaries.StringDoubleArrayDictionary` (implements `System.IDisposable`)
- **Description**: 键为 string、值为 double[] 的 Marine 专属强类型哈希字典类。

#### Constructors

- `public StringDoubleArrayDictionary();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Keys` | `System.Collections.ICollection Keys {get;}` | Gets an ICollection object containing the keys of the Dictionary object |
| `Values` | `System.Collections.ICollection Values {get;}` | Gets an ICollection object containing the values of the Dictionary object |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Add` | `void Add(string key, double[] value)` | Adds the specified key and value to the dictionary |
| `Contains` | `bool Contains(string key)` | Determines whether the Dictionary object contains an element with the specified key |
| `Remove` | `void Remove(string key)` | Removes the element with the specified key from the Dictionary object |

---

### Class `StringIntDictionary`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility.MarDictionaries`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDictionaries.StringIntDictionary` (implements `System.IDisposable`)
- **Description**: 键为 string、值为 int 的 Marine 专属强类型哈希字典类。

#### Constructors

- `public StringIntDictionary();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Keys` | `System.Collections.ICollection Keys {get;}` | Gets an ICollection object containing the keys of the Dictionary object |
| `Values` | `System.Collections.ICollection Values {get;}` | Gets an ICollection object containing the values of the Dictionary object |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Add` | `void Add(string key, int value)` | Adds the specified key and value to the dictionary |
| `Contains` | `bool Contains(string key)` | Determines whether the Dictionary object contains an element with the specified key |
| `Remove` | `void Remove(string key)` | Removes the element with the specified key from the Dictionary object |

---

### Class `StringStringArrayDictionary`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility.MarDictionaries`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDictionaries.StringStringArrayDictionary` (implements `System.IDisposable`)
- **Description**: 键为 string、值为 string[] 的 Marine 专属强类型哈希字典类。

#### Constructors

- `public StringStringArrayDictionary();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Keys` | `System.Collections.ICollection Keys {get;}` | Gets an ICollection object containing the keys of the Dictionary object |
| `Values` | `System.Collections.ICollection Values {get;}` | Gets an ICollection object containing the values of the Dictionary object |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Add` | `void Add(string key, string[] value)` | Adds the specified key and value to the dictionary |
| `Contains` | `bool Contains(string key)` | Determines whether the Dictionary object contains an element with the specified key |
| `Remove` | `void Remove(string key)` | Removes the element with the specified key from the Dictionary object |

---

### Class `StringStringDictionary`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Utility.MarDictionaries`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Utility.MarDictionaries.StringStringDictionary` (implements `System.IDisposable`)
- **Description**: 键为 string、值为 string 的 Marine 专属强类型哈希字典类，带 PML 哈希互操作接口。

#### Constructors

- `public StringStringDictionary();`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Item` | `object Item { get; set; }` | Indexer access to dictionary elements |
| `Keys` | `System.Collections.ICollection Keys {get;}` | Gets an ICollection object containing the keys of the Dictionary object |
| `Values` | `System.Collections.ICollection Values {get;}` | Gets an ICollection object containing the values of the Dictionary object |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Add` | `void Add(string key, string value)` | Adds the specified key and value to the dictionary |
| `Assign` | `void Assign(StringStringDictionary that)` | Copies the current instance state into that (shallow copy interface) |
| `Contains` | `bool Contains(string key)` | Determines whether the Dictionary object contains an element with the specified key |
| `GetItem` | `string GetItem(string key)` | Gets dictionary value by key |
| `KeysPML` | `Hashtable KeysPML()` | Get hashtable with keys (PML Version). To be used with the StringStringDictionary. |
| `Remove` | `void Remove(string key)` | Removes the element with the specified key from the Dictionary object |
| `SetItem` | `void SetItem(string key, string value)` | Sets dictionary value by key |
| `ValuesPML` | `Hashtable ValuesPML()` | Get hashtable with values (PML Version). To be used with the StringStringDictionary. |

---

## Namespace: `Aveva.Marine.Welding`

### Class `MarWeld`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Welding`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Welding.MarWeld` (implements `System.IDisposable`)
- **Description**: 单条焊缝的物理与工艺实体描述类，封装起止坐标、焊缝类型、焊脚尺寸、坡口与工艺方法。

#### Constructors

- `public MarWeld();`
- `public MarWeld(void* pPyWeld); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `ConnectionAngle` | `double ConnectionAngle {get; set;}` | Connection angle (double) |
| `EndSuspension` | `double EndSuspension {get; set;}` | End suspension (double) |
| `InclinationAngle` | `double InclinationAngle {get; set;}` | Inclination angle (double) |
| `Layers` | `int Layers {get; set;}` | Number of weld layers (int) |
| `LayersPML` | `double LayersPML {get; set;}` | Number of weld layers (double) |
| `LegLength` | `double LegLength {get; set;}` | Weld leg length (double) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Position` | `string Position {get; set;}` | Weld position (String) |
| `Process` | `string Process {get; set;}` | Process (String) |
| `RotationAngle` | `double RotationAngle {get; set;}` | Rotation angle (double) |
| `StandardProcess` | `string StandardProcess {get; set;}` | Standard process (String) |
| `StartSuspension` | `double StartSuspension {get; set;}` | Start suspension (double) |
| `TestProcedure` | `string TestProcedure {get; set;}` | Test procedure (String) |
| `TorchVector` | `Aveva.Marine.Geometry.MarVector TorchVector {get; set;}` | Torch vector (MarVector) |
| `WeldComment` | `string WeldComment {get; set;}` | Weld comment (String) |
| `WeldLength` | `double WeldLength {get; set;}` | Weld length (double) |
| `WeldName` | `string WeldName {get; set;}` | Weld name (String) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddArc` | `void AddArc(MarPoint pnt, MarVector vec)` | Add an arc segment to the contour |
| `AddLine` | `void AddLine(MarPoint pnt)` | Add a line (straight) segment to the contour |
| `Assign` | `void Assign(MarWeld that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetBevelCode` *(Overloads: 2)* | `double GetBevelCode(double)` | Get bevelcode for the given part |
| `GetNoSegments` | `int GetNoSegments()` | Get number of segments in the contour |
| `GetNoSegmentsPML` | `double GetNoSegmentsPML()` | Get number of segments in the contour (PML Version) |
| `GetQuality` *(Overloads: 2)* | `string GetQuality(double)` | Get quality for the given part |
| `GetThickness` *(Overloads: 2)* | `double GetThickness(double)` | Get thickness for the given part |
| `SetBevelCode` *(Overloads: 2)* | `void SetBevelCode(double,double)` | Set bevel code for the given part |
| `SetPoint` | `void SetPoint(MarPoint pnt)` | Set first point of contour |
| `SetQuality` *(Overloads: 2)* | `void SetQuality(double,string)` | Set quality for the given part |
| `SetThickness` *(Overloads: 2)* | `void SetThickness(double,double)` | Set thickness for the given part |
| `SetWeldName` *(Overloads: 2)* | `void SetWeldName(double,double)` | Orthogonal scalar projection of a vector on the line |

---

### Class `MarWeldedJoint`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Welding`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Welding.MarWeldedJoint` (implements `System.IDisposable`)
- **Description**: 焊接接头实体类，表达多构件之间的装配连接关系及由该连接派生的一组焊缝。

#### Constructors

- `public MarWeldedJoint();`
- `public MarWeldedJoint(void* pPyWeld); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `ConnectionLength` | `double ConnectionLength {get; set;}` | Connection length (double) |
| `JointComment` | `string JointComment {get; set;}` | Joint comment (String) |
| `JointLength` | `double JointLength {get; set;}` | Joint length (String) |
| `JointName` | `string JointName {get;}` | Welded joint name (String) |
| `ManualFlag` | `int ManualFlag {get; set;}` | Manual flag (int) |
| `ManualFlagPML` | `double ManualFlagPML {get; set;}` | Manual flag (double) |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `SuspensionLength` | `double SuspensionLength {get; set;}` | Suspension length (double) |
| `WeldType` | `string WeldType {get; set;}` | Weld type (String) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddWeld` | `void AddWeld(MarWeld inweld)` | Add weld to the welded joint |
| `Assign` | `void Assign(MarWeldedJoint that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetAssemblyName` *(Overloads: 2)* | `string GetAssemblyName(double)` | Get assembly name for the given part |
| `GetExtendedPartName` *(Overloads: 2)* | `string GetExtendedPartName(double)` | Get extended part name for the given part |
| `GetNumberWelds` | `int GetNumberWelds()` | Get the number of welds |
| `GetNumberWeldsPML` | `double GetNumberWeldsPML()` | Get the number of welds (PML Version) |
| `GetPartName` *(Overloads: 2)* | `string GetPartName(double)` | Get part name for the given part |
| `GetPartType` | `int GetPartType(int part)` | get type for the given part |
| `GetPartTypePML` | `double GetPartTypePML(double part)` | get type for the given part (PML Version) |
| `GetWeld` *(Overloads: 2)* | `MarWeld GetWeld(double)` | Get the given weld |
| `SetAssemblyName` *(Overloads: 2)* | `void SetAssemblyName(double,string)` | Set assembly name for the given part |
| `SetExtendedPartName` *(Overloads: 2)* | `void SetExtendedPartName(double,string)` | Set extended part name for the given part |
| `SetJointName` *(Overloads: 2)* | `void SetJointName(double)` | Set welded joint name |
| `SetPartName` *(Overloads: 2)* | `void SetPartName(double,string)` | Set part name for the given part |
| `SetPartType` | `void SetPartType(int part, int intype)` | Set extended part name for the given part |
| `SetPartTypePML` | `void SetPartTypePML(double part, double intype)` | Set extended part name for the given part (PML Version) |
| `SetWeld` *(Overloads: 2)* | `void SetWeld(double,MarWeld)` | Set the weld to the welded joint |

---

### Class `MarWeldMod`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Welding`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Welding.MarWeldMod` (implements `System.IDisposable`)
- **Description**: 焊缝工艺修改器，用于对自动生成的焊缝进行人工工艺修正与参数重算。

#### Constructors

- `public MarWeldMod();`


*No public properties defined.*

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Assign` | `void Assign(MarWeldMod that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `WeldCalculation` *(Overloads: 2)* | `bool WeldCalculation(string,double)` | Starts the weld detection for the given assembly, and optionally also for all its |
| `WeldDelete` | `bool WeldDelete(string PathName)` | Deletes the weld table object on data bank |
| `WeldPropertiesGet` | `bool WeldPropertiesGet(string PathName, MarWeldTable WeldTable)` | Returns the weld properties |
| `WeldPropertiesSet` | `bool WeldPropertiesSet(string PathName, MarWeldTable WeldTable)` | Updates an existing weld table |

---

### Class `MarWeldTable`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Welding`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Welding.MarWeldTable` (implements `System.IDisposable`)
- **Description**: 焊接工艺标准数据库表映射类，维护全船/分段焊缝总长、工时与工艺规程。

#### Constructors

- `public MarWeldTable();`
- `public MarWeldTable(void* pPyWeldTable); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `TotalConnectionLength` | `double TotalConnectionLength {get; set;}` | The total connection length (double) |
| `TotalSuspensionLength` | `double TotalSuspensionLength {get; set;}` | The total suspension length (double) |
| `TotalWeldLength` | `double TotalWeldLength {get; set;}` | The total weld length (double) |
| `WeldTableComment` | `string WeldTableComment {get; set;}` | The weld table comment (String) |
| `WeldTableName` | `string WeldTableName {get; set;}` | Weld table name (String) |
| `WeldTableStatus` | `string WeldTableStatus {get; set;}` | The weld table status (String) |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddWeldedJoint` | `void AddWeldedJoint(MarWeldedJoint inweldedjoint)` | Get the number of welded joints |
| `Assign` | `void Assign(MarWeldTable that)` | Copies the current instance state into that (shallow copy interface) |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `GetNumberWeldedJoints` | `int GetNumberWeldedJoints()` | Get the number of welded joints |
| `GetNumberWeldedJointsPML` | `double GetNumberWeldedJointsPML()` | Get the number of welded joints (PML Version) |
| `GetWeldedJoint` *(Overloads: 2)* | `MarWeldedJoint GetWeldedJoint(double)` | Get the given joint |
| `SetWeldedJoint` *(Overloads: 2)* | `void SetWeldedJoint(double,MarWeldedJoint)` | Set the given welded joint in the weld table |

---

## Namespace: `Aveva.Marine.Vitesse`

### Class `MarContour2D`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Vitesse`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Vitesse.MarContour2D` (implements `System.IDisposable`)
- **Description**: 二维平面轮廓几何线段集合，支持封闭性测试、面积计算、法向与包含判定。

#### Constructors

- `public MarContour2D();`
- `public MarContour2D(MarPoint2D startp);`
- `public MarContour2D(void* pPyContour2D); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Colour` | `Aveva.Marine.Drafting.MarColour Colour {get; set;}` | Colour property |
| `Detectable` | `int Detectable {get; set;}` | Detectable property |
| `Layer` | `Aveva.Marine.Drafting.MarLayer Layer {get; set;}` | Layer property |
| `LineType` | `Aveva.Marine.Drafting.MarLinetype LineType {get; set;}` | LineType property |
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `Visible` | `int Visible {get; set;}` | Visible property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `AddArc` | `void AddArc(MarPoint2D inpoint, double inamplitude)` | AddArc method |
| `AddLine` | `void AddLine(MarPoint2D inpoint)` | AddLine method |
| `Area` | `double Area()` | Area method |
| `Direction` | `int Direction()` | Direction method |
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `Distance` | `double Distance(MarPoint2D pnt)` | Distance method |
| `GetCenterPoint` | `MarPoint2D GetCenterPoint(MarPoint2D start, MarPoint2D end, double amp)` | GetCenterPoint method |
| `GetPointOnContour` | `int GetPointOnContour(MarPoint2D pnt)` | GetPointOnContour method |
| `IsClosed` | `int IsClosed()` | IsClosed method |
| `IsInside` | `int IsInside(MarPoint2D extPnt)` | IsInside method |
| `IsPoint` | `int IsPoint()` | IsPoint method |
| `IsPointOnContour` | `int IsPointOnContour(MarPoint2D pnt)` | IsPointOnContour method |
| `Length` | `double Length()` | Length method |
| `SetPoint` | `void SetPoint(MarPoint2D startp)` | SetPoint method |

#### Operators

| Operator | Signature | Description |
|---|---|---|
| `+` | `public static MarContour2D[] operator +(MarContour2D self, MarContour2D other)` | 计算两轮廓的合并并集 (Union) |
| `-` | `public static MarContour2D[] operator -(MarContour2D self, MarContour2D other)` | 计算两轮廓的裁剪差集 (Subtraction / Cutout) |
| `*` | `public static MarContour2D[] operator *(MarContour2D self, MarContour2D other)` | 计算两轮廓的重叠交集 (Intersection) |

---

### Class `MarPoint2D`

- **Assembly**: `marAPI.dll`
- **Namespace**: `Aveva.Marine.Vitesse`
- **Inheritance**: `System.Object` -> `Aveva.Marine.Vitesse.MarPoint2D` (implements `System.IDisposable`)
- **Description**: 二维平面点实体类，支持坐标设置、距离测量、中点计算与重载运算符。

#### Constructors

- `public MarPoint2D();`
- `public MarPoint2D(double x, double y);`
- `public MarPoint2D(void* pPyPoint2D); // 非托管指针桥接构造`


#### Properties

| Property | Signature | Description |
|---|---|---|
| `Object` | `System.Void* Object {get;}` | Internal unmanaged handle pointer |
| `X` | `double X {get; set;}` | X property |
| `Y` | `double Y {get; set;}` | Y property |

#### Methods

| Method | Signature | Description |
|---|---|---|
| `Dispose` | `void Dispose()` | Releases all unmanaged resources held by this instance |
| `DistanceToPoint` | `double DistanceToPoint(MarPoint2D p)` | DistanceToPoint method |
| `Move` | `void Move(double xmove, double ymove)` | Move method |
| `Round` | `void Round(int decimals)` | Round method |
| `SetCoordinates` | `void SetCoordinates(double x, double y)` | SetCoordinates method |
| `SetFromMidpoint` | `void SetFromMidpoint(MarPoint2D p1, MarPoint2D p2)` | SetFromMidpoint method |
| `SetFromPoint` | `void SetFromPoint(MarPoint2D p)` | SetFromPoint method |

---
