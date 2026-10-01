# Patterns & Recipes: AVEVA Marine & Plant .NET Development

High-frequency architectural patterns and engineering recipes for secondary development in AVEVA Marine and Plant.

---

## 1. CAF 插件注册与命令解耦模式 (CAF Addin & Command Decoupling Pattern)

**When to use**: 为 AVEVA 宿主模块（Design, Outfitting, Draft）构建官方级功能入口、停靠窗体或工具栏按钮时。

**How**:
1. 创建实现 `IAddin` 的类，在 `Start(ServiceManager sm)` 中解析 `WindowManager` 和 `CommandManager`。
2. 继承 `Command`，指定全局唯一的命名空间键值（如 `Aveva.Custom.MyActionCommand`），在 `Execute()` 中控制窗体的 `Show()/Hide()` 或调用核心服务。
3. 在 `ModuleAddins.xml` 中注册插件程序集路径与类全名。
4. 在 `.uic` 文件中将按钮工具（ButtonTool）的 Key 关联至该命令。
5. 在 `Stop()` 中注销所有事件监听与 UI 句柄。

**Trade-offs**:
- *优势*: 遵循官方标准架构，与原生界面风格一致，生命周期由宿主完全托管，窗体具备自动停靠与记忆功能。
- *代价*: 需要配置 XML 文件和 UIC 静态资源，相比纯 PML 脚本调试启动周期稍长。

---

## 2. 数据库实体防卫式遍历与事务修改模式 (Defensive DbElement Traversal & Mutation Pattern)

**When to use**: 批量扫描空间层级树（Site -> Zone -> Structure/Equipment）、提取属性或修改构件参数。

**How**:
1. 获得 `DbElement` 后，首步必须执行 `if (!element.IsValid() || element.IsNull()) continue;` 防御空指针。
2. 查询属性优先使用 `DbAttributeInstance` 的静态常量，避免动态反射查找。
3. 修改属性或创建子项前，先通过 `element.Database.Writeable` 验证当前会话是否具有写锁。
4. 全局捕获 `PdmsException` 阻止因底层锁竞争或只读库引发崩溃。
5. 遍历子节点时若涉及结构修改（增删子节点），应先将 `Members()` 存入临时数组，再做修改。

**Trade-offs**:
- *优势*: 彻底消除 Dabacon 数据库损坏或非法指针导致的宿主崩溃（GPF），保障多人并发协同安全。
- *代价*: 增加了前置有效性校验代码量。

---

## 3. PMLNet 双向交互与跨语言通信模式 (Bidirectional PMLNet Bridge Pattern)

**When to use**: 现有项目基于庞大的 PML 表单或宏，但需要引入 C# 的高阶算法、数据库高速读写或现代化图表界面。

**How**:
1. 编写 C# 桥接类，标注 `[PMLNetCallable()]` 特性。
2. 提供标记的无参公共构造函数与严格签名的 `public void Assign(MyClass that)` 浅拷贝方法。
3. 对外暴露的方法只接收 `double`, `string`, `bool`, `ArrayList` 或 `DbElement`。
4. 声明 `public event PMLNetDelegate.PMLNetEventHandler OnNotify;` 用于反向通知 PML。
5. 在 PML 表单中使用 `container .myContainer pmlnetcontrol 'c' dock fill` 嵌入 C# 窗体。

**Trade-offs**:
- *优势*: 无缝盘活数十年的老旧 PML 资产，兼具 C# 现代化开发体验与执行性能。
- *代价*: 类型映射受限于 PML 规则（不支持 int、泛型和结构体），排查类型不匹配需查验 `PMLNetTrace.log`。

---

## 4. Marine 原生对象确定性释放模式 (Marine Native Resource Disposal Pattern)

**When to use**: 使用 `marAPI.dll` 中以 `Mar...` 开头的造船专用类型（`MarObject`, `MarDataBase`, `MarUtil`, `MarWeld`）。

**How**:
1. 牢记所有以 `Mar` 开头的类均继承自 `System.IDisposable`，内部包裹了 C/C++ 内存指针与通信句柄。
2. 任何局部使用的对象严格放在 `using (var obj = new MarXxx()) { ... }` 作用域内。
3. 跨方法生命周期的对象，由其拥有者类实现 `IDisposable`，并在 `Dispose(bool)` 中级联释放所有内部 `Mar...` 成员。
4. 对于大型列表（如 `MarStringlist`），遍历读取完毕后立即 `Dispose()`。

**Trade-offs**:
- *优势*: 防止 Marine 后台通信通道堵塞，杜绝长时间运行下的内存泄露。
- *代价*: 开发者需时刻保持资源释放意识，不能完全依赖 CLR 垃圾回收器。

---

## 5. 平面分段双向逆向与重构模式 (Planar Statement Round-Trip Pattern)

**When to use**: 造船工艺分析、分段拆分、构件快速复制或参数化设计脚本。

**How**:
1. 从 3D 视图或数据库拾取 `DbElement` 结构实体。
2. 构造 `PanelStatement panel = new PanelStatement(dbElement);`，API 会自动提取该板架的全部基准面、外轮廓与工艺属性。
3. 读取其属性（如 `panel.Locationstr`, `panel.isWatertight`）进行业务逻辑分析或参数重写。
4. 获取 `panel.Statement` 查看标准 Tribon 建模语法，或直接调用更新接口提交重构。

**Trade-offs**:
- *优势*: 将晦涩的几何图元转化为可读、可序列化、可版本控制的平面语句对象，开发效率极大提升。
- *代价*: 仅适用于平面板架（Planar Structures），对于复杂双曲度立体外板曲面需配合曲面建模专门接口。

---

## 6. 车间工艺与焊缝全要素提取管道模式 (Shop-Floor Weld & Fabrication Pipeline Pattern)

**When to use**: 建造工艺准备、自动统计全船/分段焊缝总长、评估工时工料、导出下料草图与胎架参数。

**How**:
1. 确定目标建造分段（Block），通过 `MarDataBase.ObjectListGet` 筛选该分段下全部结构件。
2. 调用装配相交分析生成 `MarWeldedJoint` 集合。
3. 循环解析每个接头的 `MarWeld`，提取焊脚、坡口形式与空间折线长度。
4. 若为曲面外板，配合 `MarPinProfiles` 调用 `GenerateSketch()` 提取胎架活络样箱立柱矩阵。
5. 将整理好的装配清单推送至 `GridControl` 校验并导出车间制造 Excel。

**Trade-offs**:
- *优势*: 真正实现“一处设计，全程打通”，设计模型直接指导数控车间下料与焊接机器人。
- *代价*: 复杂分段相交计算量较大，建议在后台采用进度条异步调度。

---

## 7. 空间几何变换与数据感知模式 (Spatial Geometry & Reactive DbEvents Pattern)

**When to use**: 在三维空间中进行精准测距、法向平移、高空吊装避障计算，或构建响应式模型变动监控看板。

**How**:
1. 读取构件三维绝对位置与朝向：`pos = elem.GetPosition(POS)`, `ori = elem.GetOrientation(ORI)`。
2. 使用 `Position.DistanceTo()`、`Direction.Cross()` 与 `pos.Offset(dir, dist)` 进行无损量纲向量几何计算，禁止手工正则分割文本坐标。
3. 订阅 `DbEvents.AttributeChangeEvent` 实时感知用户或后台对模型几何的修改，在事件处理器内部必须设立防重入标志位（reentrancy guard）防止级联写入风暴。
4. 若需派生企业自定义动态指标（如自适应计算分段总重与油漆面积），调用 `PseudoAttribute.Register(":NAME", ...)` 挂载 C# 委托。

**Trade-offs**:
- *优势*: 将三维几何操作从晦涩的文本解析升级为严格的欧氏空间向量运算，自动适应工程单位制切换；数据感知机制可实现毫秒级 UI 联动。
- *代价*: 需注意微内核单线程（STA）约束，几何计算与事件派发必须在主线程调度器上执行。

