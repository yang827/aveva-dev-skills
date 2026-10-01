# Cheatsheet: AVEVA Marine & Plant .NET Developer Decision Guide

High-density decision rules, diagnostic heuristics, and rapid syntax references for daily development.

---

## 1. 核心架构决策树 (Architectural Decision Tree)

```text
需要为 AVEVA 增加功能？
├─ 是独立界面/工具面板/全局菜单？
│  └─ 选择 CAF Addin (`IAddin` + `WindowManager` + UIC)
│     ├─ 界面需嵌入丰富数据表格？ ──> 使用 AVEVA 官方 `GridControl`
│     └─ 界面需轻量原生弹窗？ ──> 使用 `MarUi.AnswerReq` / `ChoiceSelect`
├─ 是向现存庞大的 PML 脚本/表单注入 .NET 算法或控件？
│  └─ 选择 PMLNet (`[PMLNetCallable]` + `Assign()` + `pmlnetcontrol`)
├─ 是复用已有的 Python 造船工艺资产？
│  └─ 选择 Vitesse 引擎 (`MarPythonEngine.RunScript()`)
├─ 是进行船体结构（板架、骨材、开孔）参数化建模？
│  └─ 选择 Planar API (`PanelStatement`, `StiffenerStatement`, `HoleStatement`, `SwageStatement`)
└─ 是需要全船空间几何运算或模型变更实时感知？
   └─ 选择 Core 几何与事件总线 (`Position`, `Orientation`, `DbEvents`)
```

---

## 2. 核心决策规则 (Decision Rules: When X, Do Y, Because Z)

| 场景条件 (When X) | 推荐做法 (Do Y) | 核心原由 (Because Z) |
|---|---|---|
| 需要读取大量构件的预置系统属性 | 始终使用 `DbAttributeInstance.NAME` 等静态单例 | 避免动态通过字符串反射创建属性描述符造成 GC 压力与性能损耗 |
| 读取/修改空间三维坐标与姿态 | 使用 `GetPosition(POS)` 与 `GetOrientation(ORI)` | 避免手工字符串拆分解析，强类型自动适配当前激活的单位量纲（mm/inch） |
| 在插件中监听数据库变动 (`DbEvents`) | 事件回调内部必须设置防重入保护标志位 | 若在属性变更事件中调用 `SetAttribute`，无保护会引发无限递归死锁风暴 |
| 注册企业级自定义派生属性 (`PseudoAttribute`) | 属性名称必须显式以英文冒号开头（如 `:CALCWT`） | AVEVA 核心约定冒号前缀为用户自定义扩展域，否则无法通过 PML / 命令行匹配 |
| 需在后台线程执行重型统计计算 | 计算前将所需属性全部提取至平铺 DTO，再派发到线程 | AVEVA Dabacon 内核为单线程单元模型，跨线程访问 `DbElement` 会导致底层死锁或崩溃 |
| 声明 `PMLNetCallable` 类 | 必须提供公共无参构造函数和严格的 `Assign(that)` 方法 | 缺少这两者，PMLNetEngine 在加载时会静默忽略该类，PML 报错对象不存在 |
| 在 C# 中为 PML 暴露数值方法 | 签名参数和返回值必须严格使用 `double`，禁止用 `int` | PML 内部所有数字均以实数（Real）存储，声明为 `int` 会导致方法不可匹配 |
| 使用 `marAPI.dll` 中以 `Mar...` 开头的类 | 强制使用 `using (...)` 块包裹或显式调用 `.Dispose()` | 其底层直接持有非托管 C++ 内存指针与通信句柄，CLR 无法及时回收导致句柄耗尽 |
| 批量向数据库写入修改或新建实体 | 先行检查 `element.Database.Writeable == true` | 目标数据库只读或被并发用户锁定时直接写入会抛出 `PdmsException` 导致程序崩溃 |
| 表格控件就地编辑数据回写数据库 | 在 `BeforeCellUpdate` 中调用 `grid.DoDabaconCellUpdate(e.Args)` | 官方封装了事务校验与属性原子写入，避免手工解析单元格引发脏数据 |
| 引用与使用 AVEVA C# GridControl 表格 | 一律采用纯 C# 代码动态初始化或 PML 容器加载 | 纯代码与 PML 加载完全免 License；在 VS 窗体设计器拖拽则强制要求 Infragistics 商业开发授权 |
| 在 PML 脚本中打开文件选择对话框 | 使用 `Aveva.Pdms.Presentation.PMLFileBrowser` | 官方原生托管封装，支持过滤与默认值，避免直接调用 Win32 API 导致宿主线程锁死 |
| 排查插件启动耗时或事件卡顿 | 使用 `PdmsTrace.StartCPUTrace()` 与 `TraceEntry.Enter` | AVEVA 专属微内核剖析工具，准确统计时钟周期与 CPU 耗时 |
| 生产环境部署 UIC 配置文件 | 设置环境变量 `CAF_UIC_PATH` 并使用 `$1.uic` 通配符 | 避免修改主程序只读目录，且支持根据当前进入的项目自动加载对应界面的配置 |
| 在 PML 脚本中设定 Planar 结构分类参数 | 实例化 `Aveva.Marine.Planar.PML` 下的枚举并调用无参方法 | PML 不支持 C# 原生 enum，必须通过调用对应状态方法（如 `!side.Ps()`）设定值 |
| 为船体平面添加纵骨筋条 | 必须明确配置 `End1` 与 `End2` 的 `StiffenerEndConnection` | 缺少端部型切定义会导致零件下料预制检验阶段被数控排版系统判定为未封闭图元 |
| 散货船/油船水密横舱壁建模 | 优先使用 `SwageStatement` 声明几何波折参数 | 波形折边利用板材截面刚度自强，无需手工切割拼装虚拟骨材 |

---

## 3. 常见故障诊断与代码坏味道 (Tells & Smells)

- 👃 **Smell**: PML 报错 `(46,87) Object definition for XXX could not be found`
  - 🔍 **Check**: 检查 DLL 是否在 `%PDMSEXE%` 目录；检查类与方法是否标记 `[PMLNetCallable()]`；检查是否有公共无参构造函数；检查是否有 `public void Assign(XXX that)`；检查 `C:\temp\PMLNetTrace.log`。
- 👃 **Smell**: 宿主频繁闪退，错误日志指向内存越界或 Dabacon GPF
  - 🔍 **Check**: 排查是否在非 UI 线程（如 `Task.Run`、`BackgroundWorker`）中直接调用了 `DbElement.GetAsString()` 或 `SetAttribute()`。
- 👃 **Smell**: 插件窗体每次启动位置重置，无法保留停靠状态
  - 🔍 **Check**: 确认创建停靠窗体时是否设置了 `dockedWindow.SaveLayout = true`。
- 👃 **Smell**: 运行几天后 Marine 变慢或提示底层通讯管道断开
  - 🔍 **Check**: 检查是否循环创建了 `MarObject` / `MarDataBase` / `MarStringlist` 但未调用 `.Dispose()`。
- 👃 **Smell**: 表格横向滚动时关键的构件编号移出可视区域
  - 🔍 **Check**: 检查是否对标识列调用了 `grid.FixedHeaderOnColumns("Name")`。

---

## 4. 阈值与默认规范 (Thresholds & Defaults)

- **PMLNetTraceSwitch**: 调试模式设为 `4`（完整跟踪）；生产环境设为 `0` 或移除以提升启动速度。
- **UIC 文件编码**: 必须为带 BOM 或纯净的 `UTF-8`。
- **分段大合拢修割余量 (Green Margin)**: 默认通常为 `50mm` 至 `100mm`。
- **纵骨标准间距**: 商业商船甲板纵骨通常在 `600mm ~ 850mm` 模数区间。
- **PMLNet 异常代码段**: 官方约定 1000 为 PMLNet 专用模块号，用户子错误码从 `1000, 1` 起步。
- **波形舱壁折弯倾角 (Swage Angle)**: 散货船槽型波折角通常在 `45° ~ 60°` 区间。
