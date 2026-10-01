# AVEVA Core & CAF .NET API Reference (`NCUG.pdf`)

本手册收录从 AVEVA 官方《.NET Customisation User Guide》（`NCUG.pdf`，共 112 页）中提取的通用应用程序框架（CAF）、Dabacon 核心数据库、几何数学库、单位量纲、官方数据表格控件（GridControl）、My Data 及原生文件浏览器（PMLFileBrowser）架构速查手册。

---

## 1. 通用应用程序框架 (Common Application Framework - CAF)

### 1.1 程序集: `Aveva.ApplicationFramework.dll`

#### `interface IAddin`
所有 AVEVA .NET 插件的主入口契约。
- `string Name { get; }`: 插件唯一名称。
- `string Description { get; }`: 插件描述信息。
- `void Start(ServiceManager serviceManager)`: 插件启动回调。在此处解析所需服务、创建窗体、注册命令。
- `void Stop()`: 插件卸载或模块切换回调。必须在此处注销命令、解除事件监听并释放非托管资源。

#### `class ServiceManager`
微内核服务定位器，负责发布与检索宿主核心服务。
- `object GetService(Type serviceType)`: 检索指定类型的服务实例（如 `WindowManager`, `CommandManager`）。
- `void AddService(Type serviceType, object serviceInstance)`: 注册自定义公共服务。

#### `class SettingsManager`
管理在不同工程会话之间持久化保存的插件配置项。
- `SettingsGroup GetSettingsGroup(string name)`: 获取或创建指定名称的配置组。

---

### 1.2 程序集: `Aveva.ApplicationFramework.Presentation.dll`

#### `class WindowManager`
负责宿主主窗体、MDI 视口及可停靠面板（DockedWindow）的管理。
- `DockedWindow CreateDockedWindow(string key, string caption, Control userControl, DockedPosition position)`: 创建停靠窗口。
- `FloatingWindow CreateFloatingWindow(string key, string caption, Control userControl)`: 创建独立浮动窗口。
- `Form MainForm { get; }`: 宿主顶层 Win32/WinForms 主窗口句柄。
- `Window ActiveWindow { get; }`: 当前处于活动焦点状态的窗口。
- `WindowCollection Windows { get; }`: 所有已注册窗口集合。

#### `class DockedWindow`
停靠窗口包装器。
- `bool SaveLayout { get; set; }`: 设置为 `true` 时，宿主自动持久化记录用户拖拽后的窗体停靠尺寸与停靠位置。
- `DockedPosition DockedPosition { get; set; }`: 停靠位置（`Left`, `Right`, `Top`, `Bottom`, `Floating`, `Tabbed`）。
- `void Show()`: 显示停靠窗口。
- `void Hide()`: 隐藏停靠窗口。
- `bool Visible { get; }`: 当前窗口可见性状态。
- `string Text { get; set; }`: 窗口标题文本。
- `void Float()`: 转换为浮动窗口。
- `void Dock()`: 重新停靠。
- `void Close()`: 销毁并从集合中移除。

#### `class CommandManager`
集中式命令注册中心。
- `CommandCollection Commands { get; }`: 命令集合，通过 `.Add(Command)` 注册自定义命令。
- `Command GetCommand(string key)`: 按键值查找已注册的命令对象。

#### `abstract class Command`
UI 交互命令基类，实现界面控件与业务逻辑的解耦。
- `string Key { get; set; }`: 命令的全局唯一键值，必须与 `.uic` 文件中的 Tool Key 严格一致。
- `bool Checked { get; set; }`: 命令的勾选状态（自动同步至绑定的菜单复选框与工具条切换按钮）。
- `bool Enabled { get; set; }`: 命令的可用状态（设置为 `false` 时所有绑定界面的按钮变灰禁用）。
- `abstract void Execute()`: 用户点击控件触发的核心执行逻辑。
- `event EventHandler CheckedChange`: 勾选状态变更事件。
- `event EventHandler EnabledChange`: 可用状态变更事件。

#### `class CommandBarManager`
管理宿主应用程序的菜单栏、工具栏与快捷上下文菜单。
- `void AddUICustomizationFile(string filename, string customizationName)`: 动态向系统载入自定义 `.uic` 界面文件。
- `ToolCollection RootTools { get; }`: 顶层菜单与工具项集合。

#### `class ResourceManager`
管理多语言本地化资源及内置图标库。
- `string GetString(string key)`: 获取本地化文本。
- `Image GetImage(string key)`: 从资源文件获取图片。
- `Icon GetIcon(string key)`: 获取系统图标。
- `Cursor GetCursor(string key)`: 获取自定义光标。

#### 1.2.1 UIC 界面自定义文件与工具类型集 (Command Tools in `.uic`)
在 XML 格式的 `.uic` 文件中，工具（Tool）节点对应于界面的各个按钮、菜单与输入项，必须通过 `Key` 属性与 C# 的 `Command.Key` 严格绑定：
- `ButtonTool`: 标准按钮工具，对应常规点击操作。
- `StateButtonTool`: 状态复选/切换按钮，双向绑定 `Command.Checked` 状态（用于控制面板显隐或模式切换）。
- `PopupMenuTool`: 弹出式多级子菜单或上下文菜单容器。
- `ComboBoxTool`: 下拉组合框工具，支持预设条目选择与动态填充。
- `TextBoxTool`: 单行文本输入框工具。
- `LabelTool`: 静态文本标签，用于显示只读说明或状态文本。
- `ProgressBarTool`: 进度条工具，用于显示耗时计算进度。
- `MDIChildWindowListTool`: 自动列出当前打开的 MDI 子视口窗口列表。

##### Property Grid 常用属性
- `Caption`: 控件显示文本（支持国际化键值）。
- `Key`: 全局唯一标识符。
- `Image`: 绑定图标资源键名。
- `Shortcut`: 快捷键绑定（如 `Ctrl+Shift+T`）。
- `Tooltip`: 鼠标悬停提示说明。
- `Visible` / `Enabled`: 初始可见与可用状态。
- `BeginGroup`: 是否在此项前插入视觉分隔线（Separator）。

#### 1.2.2 UIC 部署机制、环境变量与动态加载
- **模块配置入口**: 宿主模块根据 `<ModuleName>Customisation.xml`（如 `HullDesignCustomisation.xml`）按次序加载 UIC。
- **项目专属配置通配符 (`$1.uic`)**: 路径中使用 `$1` 可自动替换为当前 Project Code（例如 `SAM.uic`）。
- **环境重定向 `CAF_UIC_PATH`**: 若生产环境主程序目录为只读或位于网络共享盘，设置环境变量 `CAF_UIC_PATH` 可重定向 UIC 配置文件读取根目录。
- **动态编程加载**:
  ```csharp
  CommandBarManager cmdBarMgr = (CommandBarManager)serviceManager.GetService(typeof(CommandBarManager));
  cmdBarMgr.AddUICustomizationFile("MyAddinTools.uic", "MyAddinCustomisation");
  ```

---

### 1.3 插件性能分析与 CPU Profiling (`PdmsTrace` & `TraceEntry`)

在排查 Addin 初始化耗时或高频事件卡顿时，AVEVA 提供了官方原厂诊断类库：

```csharp
using Aveva.ApplicationFramework.Diagnostics;

// 1. 设置跟踪标志位 (TraceNumber 范围与过滤)
PdmsTrace.SetTraceFlag((TraceNumber)101, 1);

// 2. 利用 C# using 模式自动作用域测速（即使抛出异常也能安全 Dispose 析构）
using (TraceEntry tr = TraceEntry.Enter("MyAddinInitOperation", (TraceNumber)101))
{
    // 执行耗时业务逻辑...
}

// 3. 宿主专属 CPU 耗时剖析 (CPU Profiling)
PdmsTrace.StartCPUTrace();

// 批量执行高密度数据库操作或图元扫描...

PdmsTrace.StopCPUTrace(true); // 参数为 true 时向控制台或输出窗口打印 CPU 耗时报告
```

---

## 2. 数据库访问与实体操作 (`Aveva.Core.Database.dll`)

### 2.1 `class DbElement`
Dabacon 专有对象数据库实体的核心托管指针，遵循“值语义”（Value Semantics）。

#### 状态有效性防卫
- `bool IsValid()`: 实体是否有效（未被物理删除且所在数据库处于已挂载状态）。
- `bool IsNull()`: 是否为 Dabacon 空指针（`DbElement.Null`）。
- `static DbElement GetElement(string refNoOrName)`: 按模型层级名称（如 `"/EQUIP1"`）或参考号获取实体。
- `static DbElement GetElement()`: 获取当前工作元素（CE / Current Element）。

#### 树形层级导航
- `DbElement Owner { get; }`: 获取直接父级实体。
- `DbElement[] Members()`: 获取所有直接子成员数组。
- `DbElement[] Members(DbElementFilter filter)`: 使用过滤器按需获取子成员。
- `DbElement FirstChild() / DbElement Next() / DbElement Previous()`: 游标式快速遍历。

#### 强类型属性读取
- `string GetAsString(DbAttribute attr)`: 读取文本属性（`NAME`, `DESC`, `PURP` 等）。
- `double GetDouble(DbAttribute attr)`: 读取数值或标量属性。
- `bool GetBoolean(DbAttribute attr)`: 读取布尔属性。
- `DbElement GetElement(DbAttribute attr)`: 读取引用型属性（指向其他实体的指针，如 `SPREF`, `CATREF`）。
- `double[] GetDoubleArray(DbAttribute attr)`: 读取浮点数组。
- `string[] GetStringArray(DbAttribute attr)`: 读取文本数组。
- `DbElement[] GetElementArray(DbAttribute attr)`: 读取实体引用数组。

#### 属性与实体修改（必须在可写数据库与事务保护下执行）
- `void SetAttribute(DbAttribute attr, string value)`: 写入文本属性。
- `void SetAttribute(DbAttribute attr, double value)`: 写入数值属性。
- `void SetAttribute(DbAttribute attr, DbElement value)`: 写入实体引用。
- `void SetAttribute(DbAttribute attr, bool value)`: 写入布尔属性。
- `DbElement Create(int index, DbElementType type)`: 在当前实体下创建子元素（`index=1` 首位，`index=0` 追加末尾）。
- `void Delete()`: 物理删除当前实体及其所有子树。
- `DbElement Copy(int index, DbElement newOwner)`: 复制当前实体至新父节点下。

#### 数据库权限与并发锁定
- `Db Database { get; }`: 所属数据库实例。
- `Database.Writeable`: 当前数据库是否具有写入权限。
- `bool IsClaimed()`: 是否已被当前会话独占声明（Claim）。
- `void Claim()`: 声明当前图元所有权（多用户并发协同防冲突）。
- `void Unclaim()`: 释放图元所有权声明。

#### 历史会话比对
- `DbElementHistory[] ExtractExtract()`: 比对当前构件与指定历史 Session 之间的物理属性增删改差异。

---

### 2.2 数据库事件机制 (`class DbEvents`)
允许 .NET 插件实时感知底层 Dabacon 数据库的数据变更。

- `static event TransactionEventHandler TransactionEvent`: 事务提交或回滚事件。
  - `TransactionEventArgs.Type`: 包含 `Commit`, `Abort`。
- `static event AttributeChangeEventHandler AttributeChangeEvent`: 属性修改触发事件。
  - 提供发生变更的 `DbElement`、目标 `DbAttribute` 及新旧值。
- `static event ElementCreateEventHandler ElementCreateEvent`: 实体新建事件。
- `static event ElementDeleteEventHandler ElementDeleteEvent`: 实体删除事件。

---

### 2.3 自定义伪属性扩展机制 (`class PseudoAttribute`)
允许 C# 开发者向 Dabacon 注册自定义派生计算属性，支持在命令行输入 `q :MYATTR` 或 PML 脚本直接读取。

#### 核心注册流程
```csharp
// 1. 定义计算委托
private static object MyCustomWeightEvaluator(DbElement element)
{
    return 1250.5;
}

// 2. 注册伪属性
PseudoAttribute.Register(
    ":CALCWEIGHT",                     // 伪属性名（必须以冒号开头）
    DbElementTypeInstance.EQUIPMENT,   // 适用的实体类型
    DbAttributeType.Double,            // 返回的数据类型
    MyCustomWeightEvaluator            // 计算函数委托
);
```

---

### 2.4 Dabacon 表格查询 (`DbTable`, `DbColumn`, `DbCell`)
面向 Dabacon 内部结构化数据表（如元件库元数据、等级库映射表）：
- `DbTable`: 关系表句柄，通过 `DbTable.GetTable(name)` 检索。
- `int RowCount { get; }`: 表总行数。
- `DbColumn[] Columns { get; }`: 列定义。
- `DbCell GetCell(int row, int col)`: 单元格取值。

---

### 2.5 层级快速迭代器与过滤体系 (`DBElementCollection` & Filters)
`DBElementCollection` 是官方推荐的高性能模型树遍历集合类，内部优化了剪枝逻辑（例如查找所有管嘴 `NOZZLE` 时，自动跳过与设备无关的分支以避免全库盲目扫描）：

```csharp
// 查找指定父级节点下的所有喷嘴 (NOZZLE)
TypeFilter typeFilter = new TypeFilter(DbElementTypeInstance.NOZZLE);
DBElementCollection collection = new DBElementCollection(rootElement, typeFilter);

foreach (DbElement ele in collection)
{
    Console.WriteLine($"Found nozzle: {ele.GetAsString(DbAttributeInstance.NAME)}");
}
```

#### 官方标准过滤器族 (Filter Hierarchy)
| 过滤器类 | 构造与用途 | 说明 |
|---|---|---|
| `TypeFilter` | `new TypeFilter(DbElementType type)` | 仅匹配指定实体类型的图元 |
| `AttributeTrueFilter` | `new AttributeTrueFilter(DbAttribute attr)` | 仅匹配指定布尔属性为 `true` 的图元 |
| `AttributeFalseFilter` | `new AttributeFalseFilter(DbAttribute attr)` | 仅匹配指定布尔属性为 `false` 的图元 |
| `AttributeRefFilter` | `new AttributeRefFilter(DbAttribute attr, DbElement target)` | 仅匹配该引用属性指向指定 `target` 的图元 |
| `AndFilter` | `new AndFilter(filterA, filterB)` | 逻辑“与”复合过滤 |
| `OrFilter` | `new OrFilter(filterA, filterB)` | 逻辑“或”复合过滤 |
| `BelowFilter` | `new BelowFilter(baseFilter)` | 测试图元是否位于满足 `baseFilter` 条件的父节点下方 |

---

### 2.6 数据库表达式与规则引擎 (`DbExpression` & Rules)
Dabacon 支持存储 PML1 表达式并与模型属性动态联动。

#### 2.6.1 `class DbExpression`
- `static DbExpression Parse(string text)`: 将文本表达式编译为表达式对象（如 `(XLEN * 1000)`、`DIAM OF PREV + 2`）。
- **支持的数据结果类型**: `Double`, `DbElement`, `Bool`, `String`, `Position`, `Direction`, `Orientation`。

#### 2.6.2 在 `DbElement` 上评估表达式
```csharp
DbExpression expr = DbExpression.Parse("DIAM OF PREV + 2");
// 评估数值，并指定单位量纲 (DIST/BORE/NONE)，结果按 mm 统一返回
double val = element.EvaluateDouble(expr, DbAttributeUnit.DIST);

// 评估实体引用
DbElement targetElem = element.EvaluateElement(refExpr);

// 评估布尔条件
bool isOk = element.EvaluateBool(boolExpr);
```

#### 2.6.3 属性规则绑定与伪属性检查
- `element.SetRule(DbAttribute attr, DbRule rule)`: 为属性绑定动态/静态计算规则。
- `element.GetRule(DbAttribute attr)`: 获取已绑定的规则对象。
- `element.EvaluateRule(DbAttribute attr)`: 立即重新计算并更新规则结果。
- `element.VerifyRule(DbAttribute attr)`: 验证规则结果是否处于最新状态。

##### 规则相关伪属性表
| 伪属性名 | 类型 | 限定符 | 说明 |
|---|---|---|---|
| `RCOU` | `int` | - | 图元上绑定的规则总数 |
| `NRULEE` | `int` | - | 图元上存在规则不一致性/错误的数量 |
| `RULEER` | `string` | `int nth` | 第 n 个规则错误的详细文本信息 |
| `RULSET` | `DbAttribute[]` | - | 当前图元已设置规则的所有属性列表 |
| `RULEMOD` | `bool` | `DbAttribute` | 指定属性上的规则在当前会话中是否被修改 |
| `RULEMODC` | `bool` | `DbAttribute` | 指定属性上的规则自比对基准日期以来是否被修改 |
| `RULEMODLIST` | `DbAttribute[]` | `int session` | 自指定历史会话以来发生过规则变动的属性列表 |

---

### 2.7 历史会话比对与 MDB 全局管理 (`MDB` & Session History)

#### 2.7.1 会话差异比对伪属性表 (Session Comparison Pseudo-Attributes)
在无需遍历数据库的情况下，通过读取图元伪属性直接获取跨会话的物理变动：

| 伪属性名 | 类型 | 限定参数 | 说明 |
|---|---|---|---|
| `ATTMOD` | `bool` | `DbAttribute` | 该属性在当前会话是否已被修改 |
| `ATTMODC` | `bool` | `DbAttribute` | 该属性自比对基准日期后是否已被修改 |
| `ATTMODLIST` | `DbAttribute[]` | `int session` | 自指定 Session 以来被修改过的全部属性列表 |
| `ATTMODLISTC` | `DbAttribute[]` | - | 自比对日期以来被修改过的全部属性列表 |
| `ELECRE` | `bool` | `int session` | 该图元是否在指定 Session 之后新建 |
| `ELECREC` | `bool` | - | 该图元是否在比对日期之后新建 |
| `ELEDEL` | `bool` | `int session` | 该图元是否在指定 Session 之后被删除 |
| `ELEMOD` | `bool` | `int session` | 该图元是否在指定 Session 之后发生过修改 |
| `HIST` | `int[]` | `DbAttribute` | 记录该图元（或指定属性）被修改过的所有历史 Session 编号数组 |
| `LASTM` | `string` | `DbAttribute` | 最后一次修改该图元/属性的日期时间戳 |
| `MSESS` | `int` | `DbAttribute` | 最后一次修改该属性的会话编号 |
| `SESSNO` | `int` | - | 当前打开的活动会话编号 |
| `USERM` | `string` | `DbAttribute` | 执行最后一次修改的操作员用户名 |
| `SESCLA` | `int` | - | 当前图元被 Claim 独占的会话编号 |
| `SESSD` | `string` | `int session` | 指定 Session 的创建日期 |
| `SESSU` | `string` | `int session` | 创建指定 Session 的用户 |
| `SESSC` | `string` | `int session` | 指定 Session 提交时的备注说明 (Comment) |

#### 2.7.2 数据库与多库管理类 (`class MDB`)
`Aveva.Core.Database.MDB` 是管理多数据库会话的单例服务：
- `static MDB CurrentMDB { get; }`: 获取当前打开的多数据库上下文。
- `void SaveWork(string comment)`: 提交当前全部修改至数据库文件并生成新 Session。
- `void QuitWork()`: 放弃当前会话所有未保存的修改。
- `DB[] GetDBs()`: 获取当前 MDB 中包含的所有物理数据库对象。
- `DbElement GetElement(string name)`: 根据名称高速检索图元。
- `void Flush()` / `void Refresh()`: 子抽取库向主库刷新（Flush）或从主库拉取最新数据（Refresh）。
- `void ExtractClaim(DbElement ele)` / `void ExtractRelease(DbElement ele)`: 抽取库层级的构件签出与释放。
- `void ExtractDrop(DbElement ele)`: 放弃抽取库中的图元修改。

#### 2.7.3 物理 DB、MDB 与 Extract 全量系统/伪属性矩阵 (NCUG 4.5.1 & 4.5.2)
在 AVEVA 底层，物理数据库对象（`DB`）在系统库中均有对应的代表图元（System `DbElement`）。开发者可通过访问该图元获取完整的数据库状态、多用户冲突与抽取派生关系：

| 伪属性名 | 数据类型 | 限定参数 | 说明 |
|---|---|---|---|
| **`OKDROP`** | `bool` | - | 图元是否允许在抽取库中执行 Drop 放弃操作 |
| **`OKRLEX`** | `bool` | - | 图元是否允许在抽取库中执行 Extract Release 释放 |
| **`ACCEDB`** | `string` | - | 当前 DB 访问控制模式 (`"MULTIWRITE"`, `"UPDATE"`, `"READONLY"`) |
| **`CLAIM`** | `string` | - | 构件当前的 Claim 状态（隐式或显式独占） |
| **`CLCCNT`** | `int` | - | 当前数据库内部持有的 Claim 独占计数 |
| **`ISWORK`** | `bool` | - | 当前数据库是否为 Working Extract（工作抽取副本） |
| **`ISDBFR`** | `bool` | - | 当前数据库是否来源于外部/异构项目 (Foreign DB) |
| **`ISDRDB`** | `bool` | - | 当前数据库是否包含工程图纸 (Drawings DB) |
| **`LPROT`** | `bool` | - | 数据库是否处于受保护锁死状态 (Protected DB) |
| **`DBCNTL`** | `bool` | - | 图元是否归属于系统控制库 (Control DB) |
| **`DBAC`** | `string` | - | DB Access 访问级别：`MULTIWRITE` 或 `UPDATE` |
| **`DBCL`** | `string` | - | DB Claim 模式配置 |
| **`DBLC`** | `DbElement[]` | - | 属于当前 DB 的所有顶层定位图元（LOCs 列表） |
| **`DCLA`** | `string` | - | 数据库 Claim 策略字符串 |
| **`DACC`** | `string` | - | 物理数据库读写权限字符串 |
| **`EXTALS`** | `DbElement[]` | - | 当前抽取库的所有祖先抽取图元列表 (Extract Ancestors) |
| **`EXTCLS`** | `DbElement[]` | - | 当前抽取库的所有直属子抽取图元列表 (Extract Children) |
| **`EXTDES`** | `DbElement[]` | - | 当前抽取库的所有后代抽取图元列表 (Extract Descendants) |
| **`EXTFAM`** | `DbElement[]` | - | 当前抽取分支的完整家族成员列表 (Extract Family) |
| **`LINKSN`** | `int` | - | 父抽取库与当前库关联绑定的 Session 会话编号 |
| **`FILENAME`** | `string` | - | 物理数据库存储文件名（含扩展名） |
| **`FOREIGN`** | `string` | - | 外部数据库的源发项目代码 (Originating Project) |
| **`HCCNT`** | `int` | - | Header / Extract 抽取清单变动累计计数器 |
| **`NACCNT`** | `int` | - | 非追加式物理修改累计计数器 (Non-additive Changes Count) |
| **`NAMEDB`** | `string` | - | 物理数据库的系统逻辑名称 |
| **`NXTDBN`** | `int` | - | 下一个分配的数据库编号 (Next DB Number) |
| **`NXTEXN`** | `int` | - | 下一个分配的抽取分支编号 (Next Extract Number) |
| **`NXTFDB`** | `int` | - | 下一个分配的文件与数据库复合编号 |
| **`NXTFLN`** | `int` | - | 下一个分配的文件编号 (Next File Number) |
| **`SIZEDB`** | `int` | - | 物理数据库文件字节大小 |
| **`STPDBS`** | `DbElement[]` | - | 包含当前 DB 的快照戳印集合 (Stamps Containing DB) |
| **`STPSES`** | `int[]` | - | 至少被一个快照戳印锁定的所有历史 Session 列表 |
| **`STYPDB`** | `string` | - | 数据库子类型 (DB Sub Type) |
| **`TYPEDB`** | `string` | - | 数据库主类型（如 `"DESI"`, `"PWAY"`, `"CATA"`, `"DICT"`） |
| **`CSESS`** | `string` | `int session` | 指定历史 Session 提交时记录的说明文本 |
| **`DSESS`** | `string` | `int session` | 指定历史 Session 的生成日期时间字符串 |
| **`USESS`** | `string` | `int session` | 创建指定历史 Session 的操作员代码 |
| **`PSESS`** | `int` | `int session` | 指定历史 Session 的直接前序会话编号 |
| **`EXPIRY`** | `string` | - | 受保护数据库的有效截止期限 (Expiry Date) |

---

### 2.8 Dabacon 底层索引表与 Token 内存释放 (`NameTable`, `RefTable`, `IntTable`)

源自 `NCUG.pdf` 第 4.4 节。在超大型工程（数百万图元）中，Dabacon 内部通过专门的键值表（Tables）索引核心属性，直接遍历表比扫描层级树快几个数量级：

#### 2.8.1 表结构分类
1. **名称表 (`NameTable` / ntable)**:
   - 键：字符串（图元名称 `NAME`）。
   - 值：该图元的物理 `refno`（如 `123/456`）。用于瞬间根据名称获取图元句柄。
2. **引用表 (`RefTable` / ftable)**:
   - 键：被引用构件的 `refno`（如标准元件库 `SPREF` / `CATREF` 的 `refno`）。
   - 值：引用了该元件的图元 `refno`（同一个键可能出现成百上千次）。
   - **典型应用**：极速反查“全船哪些管件/结构引用了特定规格的标准肘板或阀门”。
3. **整型表 (`IntTable` / itable)**:
   - 键：整型属性值（如零件编号、状态码）。
   - 值：持有该状态属性的图元 `refno`。

#### 2.8.2 单库与跨库迭代器
- **单库迭代器**（仅作用于单个打开的物理 DB）：
  - `NameTable`: 单库名称表遍历。
  - `RefTable`: 单库引用表遍历。
  - `IntTable`: 单库整型表遍历。
- **跨库全局迭代器**（自动遍历当前 MDB 下所有打开的 DB，汇聚为统一视图）：
  - `MdbNameTable`: 跨所有打开数据库搜索名称匹配图元。
  - `MdbIntTable`: 跨所有打开数据库按整型属性搜索图元。

#### 2.8.3 核心避坑：Token 内存释放规范
> [!CAUTION]
> **Dabacon 搜索 Token 泄露陷阱**:
> 使用表遍历或底层查询接口时，若未显式结束迭代释放底层的底层 Token 句柄，PDMS / Marine 命令行将持续刷屏报警：
> ```text
> "xx dabacon search tokens - Expected none"
> ```
> 报警计数会随操作不断攀升且系统不会自动回收，直至关闭数据库！
> **防御准则**：凡使用表迭代器，必须显式调用其销毁方法，或在 `using` / `try...finally` 中确保遍历完成释放。

---

### 2.9 数据库全量生命周期事件 (`DbEvents`)

源自 `NCUG.pdf` 第 4.6 节。`DbEvents` 涵盖了从图元细粒度属性变动到整库级别的完整事件管道：

1. **图元细粒度变更总线 (`DbUserChanges`)**:
   - `AddChangeEventHandler(ChangeDelegate plug)`: 注册通用变更监听。
   - 触发时机：PML 宏执行完毕后、命令行执行完成时、窗体交互动作提交时。
   - `DbUserChanges` 提供 `CreatedElements()`、`DeletedElements()`、`ModifiedElements()` 及属性级变动差异列表。
2. **底层缓存提交事件 (`CommitPending`)**:
   - 在执行 `setmark`, `undo`, `redo`, `SaveWork`, `QuitWork`, `GetWork` 之前由系统触发，用于各子系统将尚未写入磁盘的内存脏数据强制同步。
3. **内存视图清理事件 (`ClearCache`)**:
   - 在临时切换历史 Session、执行 `GetWork`、`Undo`、`Redo` 或 `QuitWork` 后触发。
   - **性能铁律**：`ClearCache` 在单次批量操作中可能被触发数千次，注册此事件的处理程序必须保持毫秒级极速响应，严禁在此执行深层数据库 IO！
4. **本地视图变更 Pre / Post 事件**:
   - 影响当前客户端本地视图的操作（如 `GetWork`, `Undo`, `Redo`）分别有执行前（Pre）与执行后（Post）通知，用于刷新 3D 画布与模型树。
5. **物理数据库落盘变更 Pre / Post 事件**:
   - 影响服务器物理数据库文件的操作（如 `SaveWork`, `Refresh`, `Drop`, `Flush`）分别提供 Pre / Post 事件，向订阅方传递修改清单。
6. **独占与释放完成事件 (`Post claim / release`)**:
   - 构件被签出独占（Claim）或解除释放（Release）后触发，用于多用户协同状态同步。

---

## 3. 几何与空间数学体系 (`Aveva.Pdms.Geometry.dll` / `Aveva.Core.Geometry`)

在 AVEVA 三维二次开发中，所有空间位置（`POS`）与三维朝向（`ORI`）均依赖强类型几何类进行解析与矩阵运算。

### 3.1 `class Position`
三维空间绝对坐标点（通常单位为毫米 mm）。
- `double East / North / Up`: 空间三分量（对应全船坐标系的 Y, X, Z 或 X, Y, Z）。
- `double X / Y / Z`: 绝对笛卡尔坐标分量。
- `double DistanceTo(Position other)`: 计算两个三维点之间的空间欧氏距离。
- `Position Transform(Matrix transformMatrix)`: 应用变换矩阵生成新位置点。
- `Position Offset(Direction dir, double distance)`: 沿特定方向偏移距离。

### 3.2 `class Direction`
三维单位空间方向向量（模长恒为 1.0）。
- `double X / Y / Z`: 方向余弦分量。
- `static Direction North / South / East / West / Up / Down`: 标准基准方向常量。
- `double Angle(Direction other)`: 计算两方向之间的夹角弧度。
- `Direction Cross(Direction other)`: 向量叉乘，求公共法向量。
- `double Dot(Direction other)`: 向量点乘。

### 3.3 `class Orientation`
构件在空间中的三维旋转姿态（封装了坐标轴旋转矩阵与欧拉角）。
- `Direction YDir { get; }`: 构件局部 Y 轴在世界坐标系中的指向。
- `Direction ZDir { get; }`: 构件局部 Z 轴在世界坐标系中的指向。
- `Direction XDir { get; }`: 自动由 Y 与 Z 叉乘派生的局部 X 轴指向。
- `Orientation Invert()`: 逆变换姿态。

### 3.4 几何属性转换与桥接实战
```csharp
// 1. 从 DbElement 直接读取强类型 Position 与 Orientation
Position pos = element.GetPosition(DbAttributeInstance.POS);
Orientation ori = element.GetOrientation(DbAttributeInstance.ORI);

Console.WriteLine($"E: {pos.East}, N: {pos.North}, U: {pos.Up}");
Console.WriteLine($"Z Direction: {ori.ZDir.X}, {ori.ZDir.Y}, {ori.ZDir.Z}");

// 2. 变换后写回数据库
Position newPos = pos.Offset(Direction.Up, 500.0); // 向上提升 500mm
element.SetPosition(DbAttributeInstance.POS, newPos);
```

---

## 4. 单位制、物理量纲与自适应计算 (`Aveva.Core.Units` / `DbUnits`)

AVEVA 支持公制（Metric）、英制（Imperial）及特殊管径（Bore Units）混合存储。系统提供了带物理量纲约束的自适应数值封装体系：

### 4.1 核心类型体系与职责
| 核心类 | 命名空间 | 职责说明 |
|---|---|---|
| `DbUnits` | `Aveva.Core.Units` | 标准单位常量枚举（`DbUnits.MM`, `DbUnits.M`, `DbUnits.INCH`, `DbUnits.FINC`, `DbUnits.KG`, `DbUnits.LB`, `DbUnits.CELSIUS` 等） |
| `DbDimension` | `Aveva.Core.Units` | 基础物理量纲枚举（`DbDimension.DIST`, `DbDimension.MASS`, `DbDimension.TEMP`, `DbDimension.BORE` 等） |
| `DbDoubleDimension` | `Aveva.Core.Units` | 复合量纲描述符（支持 `"volt/m"` 或通过标准量纲枚举构造） |
| `DbDoubleUnits` | `Aveva.Core.Units` | 物理单位包装类，维护量纲与具体单位之间的绑定与换算率 |
| `DbDouble` | `Aveva.Core.Units` | 核心自适应实数对象，封装了数值、量纲与单位，重载了算术与比较运算符 |
| `DbFormat` | `Aveva.Core.Units` | 实数格式化模板，控制输出精度、物理单位后缀及舍入模式 |

### 4.2 构造与单位换算 API 实战
```csharp
using Aveva.Core.Units;
using Aveva.Core.Database;

// 1. 显式构造带量纲实数
DbDouble length1 = DbDouble.Create("2500 mm");
DbDouble length2 = DbDouble.Create("2.5 m");

// 2. 单位换算
DbDoubleUnits inchUnit = DbDoubleUnits.GetUnits(DbUnits.INCH);
DbDouble lengthInInch = length1.ConvertUnits(inchUnit);

// 3. 管径公称通径自适应构造 (Bore)
DbFormat fbore = DbFormat.Create();
fbore.Dimension = DbDoubleDimension.GetDimension(DbDimension.DIST);
fbore.Units = DbDoubleUnits.GetUnits(DbUnits.FINC);
DbDouble bore = DbDouble.CreateBore("12", fbore); // 根据当前 BORE 单位制自适应解析为最近标准通径
```

### 4.3 运算符重载与异常防卫
`DbDouble` 深度重载了二元运算符：`+`, `-`, `*`, `/`, `==`, `!=`, `<`, `<=`, `>`, `>=`。
- **自动对齐换算**: 同一量纲的不同单位运算时，自动统一换算基准：
  ```csharp
  DbDouble mass1 = DbDouble.Create("1 kg");
  DbDouble mass2 = DbDouble.Create("2.2046 lb");
  DbDouble totalMass = mass1 + mass2; // 正确执行加法并自动对齐
  ```
- **量纲冲突异常捕获 (`PdmsException`)**: 若对不同物理量纲执行非法加减（如质量与长度相加），将抛出 `PdmsException`：
  ```csharp
  try
  {
      DbDouble err = DbDouble.Create("1 kg") + DbDouble.Create("100 mm");
  }
  catch (PdmsException ex)
  {
      // 捕获量纲冲突错误: Incompatible dimensions
      Console.WriteLine($"Unit mismatch error: {ex.Message}");
  }
  ```

### 4.4 格式化输出 (`DbFormat`)
```csharp
DbDouble temp = DbDouble.Create("0 celsius");

DbFormat tempFmt = DbFormat.Create();
tempFmt.Dimension = DbDoubleDimension.GetDimension(DbDimension.TEMP);
tempFmt.Units = DbDoubleUnits.GetUnits(DbUnits.CELSIUS);
tempFmt.Label = "°C";
tempFmt.Decimals = 1;

string formatted = temp.ToString(tempFmt); // 输出: "0.0°C"
```

---

## 5. 官方 C# 数据表格控件 (`GridControl`)

位于 `Aveva.ApplicationFramework.Presentation.dll`，专为 AVEVA 界面打造的高性能数据呈现与就地编辑表格控件（基于 Infragistics UltraGrid 深度封装）。

> [!IMPORTANT]
> **关于 Infragistics 商业授权原则**:
> - 仅在 Visual Studio 窗体可视化设计器（Designer）中拖拽放置 `GridControl` 时，才需要 Infragistics 商业开发授权。
> - 在 C# 代码中纯编程式初始化 `new NetGridControl()`，或在 PML 窗体中通过 `container` 容器加载，**完全不需要任何第三方 License**，可自由部署！

### 5.1 数据源绑定与导入
- `void BindToDataSource(object dataSource)`: 绑定 `DataTable`, `BindingList<T>` 等。
- `NetDataSource(string tableName, string excelOrCsvPath)`: 直接从 Excel (.xls) 或 CSV 文件创建表格数据源：
  ```csharp
  NetDataSource ds = new NetDataSource("PartsList", @"C:\Data\Pipes.xls");
  grid.BindToDataSource(ds);
  ```

### 5.2 核心操作与高级特性 API
- `void DoDabaconCellUpdate(ArrayList args)`: **核心数据库自动同步方法**。在 `BeforeCellUpdate` 事件中直接将事件参数传入此方法，即可自动同步修改底层 Dabacon 图元属性；若写入失败，`args[3]` 和 `args[4]` 将包含详细错误码。
- `void setNameColumnImage()`: 自动为 `"NAME"` 列的每行实体绘制 AVEVA 官方三维图元图标（如设备、弯头、板架等专用图标）。
- `void BulkEditableGrid(bool enable)`: 开启多单元格框选、上下填充（Fill Down/Fill Up）及多行复制粘贴支持。
- `void ColumnExcelFilter(bool enable)`: 开启列头 Excel 风格的漏斗形下拉过滤菜单。
- `void FixedHeaders(bool enable)` / `void FixedRows(bool enable)`: 滚动视口时冻结列头与首行。
- `void SaveGridToExcel(string file, string sheet)`: 无需安装 Office 即可导出完整格式化 Excel 工作簿。

### 5.3 AVEVA GridControl 全量 API 方法速查表 (NCUG 第 6.8 节)

下表包含 `NCUG.pdf` 第 6.8 节官方公开的全部 50+ 个方法及调用签名，按功能划分为五大控制域：

#### 5.3.1 表格全局配置与视觉属性 (Grid Setup & Appearance)
| 方法名与签名 | 返回类型 | 功能说明 |
|---|---|---|
| `allGridEvents(bool enable)` | `void` | 全局开启或屏蔽表格事件广播 |
| `AllowDropInGrid(bool enable)` | `void` | 允许/禁止外部元素拖拽进表格视口 |
| `BulkEditableGrid(bool enable)` | `void` | 开启多单元格框选、上下填充（Fill Down/Up）与多行剪贴板支持 |
| `ClearGrid()` | `void` | 清空表格中所有数据并重置列头定义 |
| `ClearGridData()` | `void` | 仅清空所有行数据，保留现有列头排布 |
| `EditableGrid(bool enable)` | `void` | 全局开启/关闭单元格就地编辑权限 |
| `ErrorIcon(bool enable)` | `void` | 校验失败时是否在单元格旁显示红色感叹号错误图标 |
| `FeedbackFailColor(string color)` | `void` | 设定单元格数据校验失败时的反馈背景色 |
| `FeedbackSuccessColor(string color)` | `void` | 设定单元格数据提交成功时的反馈背景色 |
| `FixedHeaders(bool enable)` | `void` | 垂直滚动时保持表头始终吸顶固定 |
| `FixedRows(bool enable)` | `void` | 滚动时冻结首行或指定置顶行 |
| `GridHeight()` / `GridHeight(double height)` | `double` / `void` | 查询或设置表格所有数据行的统一像素高度 |
| `HeaderSort(bool enable)` | `void` | 允许/禁止用户点击列头直接进行多列排序 |
| `HideGroupByBox(bool hide)` | `void` | 隐藏或显示顶部的拖拽分组容器栏（GroupBy Box） |
| `OutlookGroupStyle(bool enable)` | `void` | 开启 Outlook 样式的多级树形折叠分组呈现 |
| `PrintPreview()` | `void` | 弹出官方打印预览与报表打印对话框 |
| `ReadOnlyCellColor(string color)` | `void` | 设定所有只读单元格的默认底色 |
| `RefreshTable()` | `void` | 重新拉取底层 Dabacon 数据库数据刷新表格 |
| `RefreshVisibleRegion()` | `void` | 仅刷新当前屏幕可视视口内的行数据 |
| `resetCellFeedback()` | `void` | 重置并清除所有单元格的校验成功/失败高亮反馈 |
| `SaveGridToExcel(string path, string sheet)` | `void` | 将表格完整样式与数据导出至指定 Excel 文件工作表 |
| `SaveLayoutToXml(string path)` | `void` | 将当前列顺序、宽度、冻结与分组配置导出为 XML 文件 |
| `loadLayoutFromXml(string path)` | `void` | 从 XML 文件恢复保存的表格布局配置 |
| `setAlternateRowColor(string color)` | `void` | 设定奇偶交替行的背景反衬色（默认 RGB 251, 251, 255） |
| `setAlternateRowColor(double r, double g, double b)` | `void` | 使用 RGB 数值指定交替行反衬色 |
| `SingleRowSelection(bool enable)` | `void` | 强制限定为单行选择模式（禁止按 Ctrl/Shift 多选） |
| `SplitGrid(bool enable)` | `void` | 允许用户将表格水平拆分为双视口联动比对 |
| `SyntaxErrorColor(string color)` | `void` | 设定输入掩码语法校验未通过时的醒目高亮颜色 |
| `DisplayNulrefAs(string text)` | `void` | 数据库 `NULREF` 空引用时单元格显示的替代占位文本 |
| `DisplayUnsetAs(string text)` | `void` | 属性未赋值 (`UNSET`) 时单元格显示的替代占位文本 |

#### 5.3.2 行数据管理与状态控制 (Row Operations)
| 方法名与签名 | 返回类型 | 功能说明 |
|---|---|---|
| `addRow(ArrayList rowData)` | `void` | 向表格末尾追加单行数据 |
| `deleteRows(ArrayList rowTags)` | `void` | 根据行标识 Tag 批量删除指定行 |
| `deleteSelectedRows()` | `void` | 物理删除当前所有高亮选中的行 |
| `clearRowSelection()` | `void` | 清除当前表格的所有行高亮选择 |
| `SelectAllRows()` | `void` | 全选表格中的所有数据行 |
| `getNumberRows()` | `double` | 获取表格中的总数据行数 |
| `GetRow(string rowTag)` | `ArrayList` | 根据行 Tag 获取该行的所有单元格数据列表 |
| `GetRows()` | `ArrayList` | 获取全表格所有行的数据列表（二维集合） |
| `GetSelectedRows()` | `ArrayList` | 获取当前所有被选定行的单元格值集合 |
| `GetSelectedRowTags()` | `ArrayList` | 获取当前所有被选定行的唯一标识 Tag 列表 |
| `setSelectedRowTags(ArrayList tags)` | `void` | 通过代码显式高亮选中指定的行列表 |
| `GetFilteredInRows()` | `ArrayList` | 获取当前过滤筛选后保留在视口中的行集合 |
| `GetFilteredOutRows()` | `ArrayList` | 获取被过滤规则隐藏排除的行集合 |
| `MoveSelectedRowsUp()` | `void` | 将当前选中的行在表格中上移一行 |
| `MoveSelectedRowsDown()` | `void` | 将当前选中的行在表格中下移一行 |
| `RowAddDeleteGrid(bool enable)` | `void` | 开启表格底部交互式追加行与行删除快捷按钮 |
| `scrollSelectedRowToView(bool scroll)` | `void` | 滚动视口确保选中的目标行居中可见 |
| `SetRowColor(string rowTag, string color)` | `void` | 为指定行设置整行背景色（支持颜色名或 RGB） |
| `SetRowColor(string rowTag, double r, double g, double b)` | `void` | 按 RGB 数值指定整行背景色 |
| `setRowTooltip(string rowTag, string tooltip)` | `void` | 为指定行绑定鼠标悬停 Tooltip 提示 |

#### 5.3.3 列头排布、排序与筛选控制 (Column Operations)
| 方法名与签名 | 返回类型 | 功能说明 |
|---|---|---|
| `AutoFitColumns()` | `void` | 自动测量文字宽度并将全表格所有列宽自适应拉伸 |
| `ResizeAllColumns()` | `void` | 将所有列等宽铺满当前窗体可视宽度 |
| `GetNumberColumns()` | `double` | 获取表格中的总列数 |
| `GetColumn(string colTag)` | `ArrayList` | 获取指定列下的所有单元格数据列表 |
| `GetColumns()` | `ArrayList` | 获取表格全部列的唯一标识列表 |
| `GetTitles()` | `ArrayList` | 获取表格全部列的显示标题文本列表 |
| `GetColumnTitle(string colTag)` | `string` | 获取特定列的标题名称 |
| `GetColumnPosition(string colTag)` | `double` | 查询特定列当前的横向排布索引（从 0 开始） |
| `SetColumnPosition(string colTag, double pos)` | `void` | 显式重设特定列在表格中的横向次序位置 |
| `SetColumnWidth(string colTag, double width)` | `void` | 精确设定指定列的像素宽度 |
| `SetColumnVisibility(string colTag, bool visible)` | `void` | 显式显示或隐藏指定列 |
| `IsColumnVisible(string colTag)` | `bool` | 查询指定列当前是否处于可见状态 |
| `FixedHeaderOnColumns(string colTag, bool fixed)` | `void` | 将指定列锁定吸附（水平滚动时该列位置固定） |
| `ColumnExcelFilter(bool enable)` | `void` | 在所有列头开启 Excel 漏斗形多条件过滤下拉框 |
| `ResetColumnFilters()` | `void` | 清除所有列头上已应用的过滤筛选条件 |
| `ResetColumnProperties()` | `void` | 将全表格列宽、次序恢复为初始默认布局 |
| `SortColumnAscending(string colTag)` | `void` | 对指定列按升序排列 |
| `SortColumnsAscending(ArrayList colTags)` | `void` | 按多列权重优先级执行联合升序排序 |
| `SortedColumnCollection()` | `ArrayList` | 获取当前参与排序的排序列标识集合 |
| `ColumnsInGroupByBox()` | `bool` | 查询当前是否有列被拖入了分组容器中 |
| `setColumnColor(string colTag, string color)` | `void` | 设定整列的背景色 |
| `SetColumnTextAlignment(string colTag, string align)` | `void` | 设定整列文字对齐方式 (`"Left"`, `"Right"`, `"Center"`) |
| `setNameColumnImage()` | `void` | 扫描名为 `"NAME"` 的列并自动绘制 AVEVA 官方三维图元图标 |
| `ExtendLastColumn(bool enable)` | `void` | 自动将最后一列宽度延展填满表格右侧空白区 |
| `ColumnSummaries(bool enable)` | `void` | 在表格底部开启求和、均值、计数等聚合汇总行 |

#### 5.3.4 单元格微操与输入校验 (Cell Operations & Validation)
| 方法名与签名 | 返回类型 | 功能说明 |
|---|---|---|
| `GetCell(string rowTag, string colTag)` | `string` | 读取指定行、指定列单元格的显示文本 |
| `setCellValue(string rowTag, string colTag, string val)` | `void` | 动态修改指定单元格的数值或文本 |
| `setEditableCell(string rowTag, string colTag, bool edit)` | `void` | 单独对某个单元格开启或锁死编辑权限 |
| `SetCellColor(string rowTag, string colTag, string color)` | `void` | 设定单个单元格的背景颜色 |
| `SetCellColor(string rowTag, string colTag, double r, double g, double b)` | `void` | 按 RGB 数值指定单个单元格背景色 |
| `SetCellTextAlignment(string rowTag, string colTag, string align)` | `void` | 设定单个单元格文字对齐方式 |
| `CreateValueList(string name, ArrayList items)` | `void` | 创建下拉值列表，用于单元格下拉组合框选择 |

#### 5.3.5 数据库实时双向绑定机制 (Dabacon Two-way Sync)
- **`DoDabaconCellUpdate(ArrayList args)`**:
  - 在 `BeforeCellUpdate` 事件处理函数中直接将 `args` 传入此方法。
  - 系统自动解析 `args[0]`（行标识）、`args[1]`（属性名）、`args[2]`（新输入的文本），并就地更新底层 Dabacon 属性。
  - 若属性校验失败或无写入权限，系统会自动在 `args[3]` 和 `args[4]` 中填充底层错误码并触发回滚，无需手写繁琐的 `try...catch`。

---

## 6. 我的数据与构件篮子 (`Aveva.Core.MyData`)

会话级临时构件篮子，允许用户跨模块、跨功能归集构件并交由不同算法批处理。

### 6.1 C# API 方法
- `void AddCollection(string collectionName)`: 创建虚拟命名集合。
- `void AddElement(string collectionName, DbElement element)`: 向集合压入图元。
- `void AddArray(string collectionName, DbElement[] elements)`: 批量压入图元数组。
- `DbElement[] QueryElements(string collectionName)`: 查询集合内全部构件。
- `void RemoveElement(string collectionName, DbElement element)`: 移出特定构件。
- `void RemoveCollection(string collectionName)`: 删除整个集合。
- `void RemoveEverything()`: 清空全部集合。
- `void RenameCollection(string oldName, string newName)`: 重命名集合。

### 6.2 PML 调用实战
```pml
IMPORT 'MyDataAddin'
handle any
endhandle
USING NAMESPACE 'Aveva.Pdms.Presentation.MyDataAddin'
!!mydata = object pmlmydata()

-- 创建集合并加入构件
!!mydata.addCollection('WeldInspectionBatch')
!!mydata.addElementToCollection('/VESS1', 'WeldInspectionBatch')

-- 批量查询
!elements = !!mydata.elementsInCollection('WeldInspectionBatch')

-- 清理
!!mydata.removeAll()
```

---

## 7. PMLNet 调试诊断与日志追踪 (PMLNet Diagnostics)

在开发与部署 PMLNet 托管桥接库时，若遇到错误 `PML: Object definition for XXX could not be found`（错误代码 46,87），可在 `Design.exe.config` 中开启跟踪开关：

```xml
<configuration>
  <system.diagnostics>
    <switches>
      <!-- 设置值为 4 (Verbose) 记录完整的类型反射扫描与错误堆栈 -->
      <add name="PMLNetTraceSwitch" value="4" />
    </switches>
  </system.diagnostics>
  <appSettings>
    <add key="PMLNetTraceLog" value="C:\temp\PMLNetTrace.log" />
  </appSettings>
</configuration>
```

---

## 8. 原生标准文件浏览对话框 (`PMLFileBrowser`)

源自 `NCUG.pdf` 第 8 章，AVEVA 提供了原生标准 Windows 文件选择器封装，避免第三方控件弹出崩溃：

```pml
-- 1. 导入程序集与命名空间
import 'PMLFileBrowser'
using namespace 'Aveva.Pdms.Presentation'

-- 2. 实例化对象（构造参数支持 'OPEN' 或 'SAVE'，缺省默认为 'OPEN'）
!browser = object PMLFileBrowser('OPEN')

-- 3. 弹出对话框
-- 方法签名: !browser.show(directory, seed, title, exists, filter, index)
-- 参数说明:
--   directory (String) : 初始展示目录 (如 'C:\AVEVA_Data')
--   seed      (String) : 文件名输入框默认填充值 (如 'profile.txt')
--   title     (String) : 窗口标题栏文字 (如 '选择下料数据文件')
--   exists    (Boolean): 是否强校验所选文件必须已存在 (true/false)
--   filter    (String) : 文件类型过滤串 (如 'Text files (*.txt)|*.txt|All files (*.*)|*.*')
--   index     (Integer): 多类型过滤串中默认选中的过滤索引 (从 1 开始)

!browser.show('C:\Projects', 'plate_cut.txt', 'Select NC File', true, 'NC Files (*.nc;*.txt)|*.nc;*.txt|All files (*.*)|*.*', 1)

-- 4. 获取用户选定的完整路径
!selectedFile = !browser.file()

if (!selectedFile.unset() and not !selectedFile.empty()) then
    $P User selected: $!selectedFile
endif
```

---

## 9. 周边核心基础设施程序集 (NCUG 1.1.3 ~ 1.1.6)

除了核心的 `Aveva.ApplicationFramework.dll` 和 `Aveva.Pdms.Database.dll` 外，官方二次开发环境还提供了以下支撑组件：

### 9.1 共享交互服务 (`Aveva.Pdms.Shared.dll`)
- **`CurrentElement`**: 获取或设置当前主程序视图中选中的活动图元（相当于 PML 中的 `CE`）。
- **`SelectionChanged` 事件**: 监听用户在三维画布或构件浏览器中的选中目标变动，实现插件界面的联动数据刷新。
- **`Datal` (Drawlist Facilities)**: 查询与管理当前三维视口中正在显示的构件清单。

### 9.2 图形渲染与颜色系统 (`Aveva.Pdms.Graphics.dll`)
- **`DrawList`**: 三维构件绘制清单对象，支持动态向视口中 `Add(DbElement)` 或 `Remove(DbElement)`，控制特定构件的可见性。
- **`Colour`**: 构件三维着色引擎，可将指定图元设置为预设工程颜色或自定义 RGB 高亮色彩。

### 9.3 核心工具库 (`Aveva.Pdms.Utilities.dll`)
- **`Messaging`**: 统一宿主消息总线，向 AVEVA 状态栏或输出日志窗口写入格式化信息。
- **`Undo`**: 底层事务撤销服务。
- **`DbUnits`**: 统一的工程量纲与单位换算管道。

---

## 10. 官方 SDK 参考工程索引 (NCUG 1.2 `Samples.zip`)

AVEVA 在安装目录下的 `Samples.zip` 中提供了 5 个官方示例工程，构成了 .NET 插件开发的标准化工程模板：

| 示例工程目录 | 工程类型 | 演示核心机制 |
|---|---|---|
| **`AttributeBrowserAddin`** | C# CAF Addin | 演示最精简的 CAF 插件生命周期、`IAddin` 注册、停靠窗口创建与控制窗口显隐的 `Command` 实现 |
| **`ExamplesAddin`** | C# CAF Addin | 演示通过 UIC 在主菜单工具栏注入 `ComboBoxTool`，运行一系列图元创建与 Claim 独占示例 |
| **`NetGridExample`** | C# CAF Addin | 演示在标准 WinForms 窗体中承载 `GridControl`，绑定外部数据源并与 Dabacon 属性联动 |
| **`PMLNetExample`** | C# PMLNet 类库 | 演示符合 PMLNet 五大铁律的 C# 类编写规范、`Assign` 方法及向 PML 广播事件的 `PMLNetEventHandler` |
| **`PMLGridExample`** | PML 宏与表单 | 演示在原生 PML 表单中通过 `container ... pmlnetcontrol` 宿主 AVEVA C# Grid 控件的实战代码 |

