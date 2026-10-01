# Chapter 4: AVEVA C# Grid Control, My Data API & PML File Browser

## Core Idea
AVEVA 提供了官方封装的高性能数据表格控件（C# Grid Control）与“我的数据”（My Data）会话级元素归档管理系统；开发者不仅能在 C# Addin 中直接使用 Grid 绑定、筛选、编辑和导出工程数据，还可以将其注入 PML 表单，配合“My Data”实现跨模块、跨会话的构件收藏与批处理。

## Frameworks Introduced
- **AVEVA 表格数据集成架构 (AVEVA Grid Data Integration Architecture)**:
  - When to use: 需要在插件窗体或 PML 中展示、多维筛选、统计汇总大量结构件/设备属性列表，并支持导出 Excel、打印预览、冻结表头与行着色时。
  - How:
    1. 引入 `Aveva.ApplicationFramework.Presentation.dll`。
    2. 创建或嵌入 `GridControl` 实例。
    3. 绑定数据源（支持 `DataTable`、对象列表或强类型实体数组）。
    4. 配置列头、格式化掩码（Input Mask）及排序过滤规则。
    5. 关联右键 XML 弹出菜单与行选择事件。
    6. 利用 `SetRowColor`、`SetCellColor`、`FixedHeaderOnColumns` 增强视觉可读性。
- **My Data 临时数据聚合模式 (My Data Aggregation Pattern)**:
  - When to use: 跨工具流转用户选中的构件集合，或临时收集分析目标（如碰撞分析结果、待预制构件清单）。
  - How:
    1. 使用 My Data API 或 PML 包装器创建 Collection。
    2. 使用 `AddElement` / `AddArray` 注入 `DbElement` 引用。
    3. 支持查询、重命名及一键清空。

## Key Concepts
- **GridControl (AVEVA C# Grid Control)**: 基于 Infragistics 底层封装的官方表格控件，具备列筛选、分组汇总、多选、单元格就地编辑等能力。
- **FixedHeaderOnColumns**: 冻结指定列，在大量横向滚动字段中保持关键标识列固定显示。
- **XML Context Menu**: 通过加载独立 XML 菜单描述文件，为表格右键点击提供上下文菜单集成。
- **Input Mask (输入掩码)**: 表格编辑模式下的字符约束规则（如 `#` 代表数字，`A` 代表字母字符）。
- **My Data**: 宿主环境中的会话级实体篮子，允许用户或宏脚本将不同位置的 `DbElement` 聚合到以逻辑名称区分的集合（Collections）中。
- **PML File Browser**: 基于 .NET `OpenFileDialog` 与 `SaveFileDialog` 封装的非阻塞标准文件选择器组件。

## Mental Models
- **Grid as a Live Model Mirror**: Grid 不是离线报表，而是对 AVEVA 数据库当前状态的可视化镜像，可配合 DB 事件实现实时反向联动高亮。
- **My Data as a Virtual Basket**: 构件物理上依然存在于原有 Zone/Equipment 树结构下，My Data 仅建立弱引用的虚拟集合。

## Anti-patterns
- **直接操作 Infragistics 原生内部私有接口**: 应始终使用 AVEVA 公开的 `GridControl` 封装 API，避免在版本升级（如 12.1 到后续版本）时因底层第三方库版本变动导致接口断裂。
- **在每行单元格渲染时同步查询深层 DbElement 属性**: 表格数据源装载必须采用平铺数据契约或批量预加载，避免在界面渲染线程中产生 N+1 次 Dabacon 磁盘/网络 IO。
- **缺失输入掩码导致脏数据回填**: 在表格提供单元格编辑能力时，未指定 `InputMask` 会导致用户随意输入非法字符破坏 Dabacon 属性约束。

## Code Examples
```csharp
using System;
using System.Data;
using System.Drawing;
using System.Windows.Forms;
using Aveva.ApplicationFramework.Presentation;
using Aveva.Core.Database;

namespace Aveva.CustomMarine.Controls
{
    public class MarineEquipGridForm : Form
    {
        private GridControl _grid;
        private Button _btnExport;

        public MarineEquipGridForm()
        {
            InitializeComponent();
            LoadEquipmentData();
            ConfigureGridVisuals();
        }

        private void InitializeComponent()
        {
            this.Text = "Marine Equipment & Structural Plate Manager";
            this.Width = 900;
            this.Height = 550;

            // 1. 初始化 AVEVA 官方 GridControl
            _grid = new GridControl();
            _grid.Dock = DockStyle.Fill;
            _grid.AfterSelectChange += Grid_AfterSelectChange;

            _btnExport = new Button { Text = "Export to Excel", Dock = DockStyle.Bottom, Height = 36 };
            _btnExport.Click += (s, e) => ExportExcel();

            this.Controls.Add(_grid);
            this.Controls.Add(_btnExport);
        }

        private void LoadEquipmentData()
        {
            // 2. 构造数据表并填充数据
            DataTable dt = new DataTable("EquipmentTable");
            dt.Columns.Add("Key", typeof(string));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Status", typeof(string));
            dt.Columns.Add("Thickness", typeof(double));

            dt.Rows.Add("ROW_01", "/DECK-PL-01", "APPROVED", 18.5);
            dt.Rows.Add("ROW_02", "/BHD-PL-04", "WARNING", 12.0);
            dt.Rows.Add("ROW_03", "/SHELL-ST-09", "REJECTED", 22.0);

            // 3. 绑定数据源
            _grid.DataSource = dt;
        }

        private void ConfigureGridVisuals()
        {
            // 4. 冻结关键标识列 (Fixed Header)
            _grid.FixedHeaderOnColumns("Name");

            // 5. 设置输入掩码：限制状态列只能输入4位大写字母
            _grid.SetColumnMask("Status", "AAAA");

            // 6. 依据业务状态为特定行与单元格着色预警
            _grid.SetCellColor("ROW_02", "Status", "Yellow");
            _grid.SetRowColor("ROW_03", "LightPink");
            _grid.SetRowTooltip("ROW_03", "Thickness exceeds specification tolerance!");
        }

        private void Grid_AfterSelectChange(object sender, EventArgs e)
        {
            // 7. 获取用户选中的行
            int selectedCount = _grid.SelectedRows.Count;
            this.Text = $"Selected: {selectedCount} items";
        }

        private void ExportExcel()
        {
            SaveFileDialog sfd = new SaveFileDialog { Filter = "Excel Files (*.xls)|*.xls" };
            if (sfd.ShowDialog() == DialogResult.OK)
            {
                // 8. 调用内置 Excel 导出
                _grid.SaveGridToExcel(sfd.FileName, "InspectionReport", "AVEVA Marine QA Export");
                MessageBox.Show("Export finished successfully!");
            }
        }
    }
}
```

## Reference Tables

### GridControl 常用行、列、单元格控制 API
| 分类 | 方法 / 属性名 | 参数与签名 | 说明 |
|---|---|---|---|
| **行操作** | `GetRow` | `(string rowKey)` | 按键值检索指定数据行对象 |
| **行操作** | `ScrollRowIntoView` | `(string rowKey)` | 自动滚动视口保证目标行居中可视 |
| **行操作** | `SetRowColor` | `(string rowKey, string color)` | 设置整行背景颜色（支持颜色名或 RGB） |
| **行操作** | `SetRowTooltip` | `(string rowKey, string tooltip)` | 设置整行鼠标悬停浮动说明气泡 |
| **列操作** | `FixedHeaderOnColumns`| `(string colKey)` | 冻结列头，横向滚动时保持该列常驻可视 |
| **列操作** | `SetColumnPosition` | `(string colKey, double pos)` | 动态调整列显示排布次序 |
| **列操作** | `SetColumnWidth` | `(string colKey, double width)` | 显式设定列像素宽度 |
| **列操作** | `SetColumnTextAlignment` | `(string colKey, string align)` | 设置列对齐方式（`"Left"`, `"Center"`, `"Right"`） |
| **单元格** | `SetCellColor` | `(string row, string col, string color)` | 独立设置单个单元格背景色（如标黄预警） |
| **单元格** | `SetEditableCell` | `(string row, string col, bool editable)` | 锁定或开放单元格就地编辑权限 |
| **单元格** | `SetCellValue` | `(string row, string col, string val)` | 更新单元格显示数值 |
| **输入约束** | `SetColumnMask` | `(string colKey, string mask)` | 绑定输入掩码规则 |
| **输出持久化**| `SaveGridToExcel` | `(string path, string sheet, string header)` | 一键导出格式化 Excel 表格 |
| **输出持久化**| `SaveLayout / LoadLayout`| `(string xmlPath)` | 导入/导出用户偏好表格布局方案 |

### 输入掩码字符规则速查表 (Input Mask Characters)
| 掩码字符 | 输入规则限制 | 范例 | 典型造船业务场景 |
|---|---|---|---|
| `#` | 必须输入数字（0-9）或正负号 | `###-####` | 零件图号 / 托盘编号 |
| `0` | 必须输入数字（0-9） | `0000` | 4位定长分段序号 (如 0101) |
| `9` | 可选输入数字（0-9）或空格 | `999.99` | 板厚、型材间距毫米值 |
| `A` | 必须输入字母或数字（英数字） | `AAAA` | 钢级标识 (A36, DH36) |
| `a` | 可选输入字母或数字 | `aaaa` | 零件副标记 |
| `&` | 必须输入任意字符（含标点符号） | `&&&&` | 构件备注描述 |
| `?` | 必须输入纯字母（A-Z, a-z） | `????` | 船体分段代号 (BLCK) |
| `\` | 转义后导字符为字面常量 | `\P-#` | 输出固定前缀 `P-` |
| `/` | 日期分隔符（自动适配系统语言） | `##/##/####` | 检验交验日期 |
| `:` | 时间分隔符（自动适配系统语言） | `##:##:##` | 加工时间戳 |

### My Data PML 调用命令速查
| PML 语法范例 | 动作 |
|---|---|
| `using namespace 'Aveva.Core.MyData'` | 引入 My Data 命名空间 |
| `!mydata.addcollection('PanelBatch')` | 创建一个名为 `PanelBatch` 的逻辑集合 |
| `!mydata.addelement('PanelBatch', !dbRef)` | 向该集合压入一个构件实体 |
| `!list = !mydata.queryelements('PanelBatch')` | 查询该集合内存储的所有实体指针 |
| `!mydata.removeeverything()` | 清空用户所有 My Data 数据 |

## Worked Example: 在 PML 表单中集成 Grid 与右键菜单
1. **定义包含 Grid 的 PML 容器**:
   ```pml
   setup form !!pmlGridDemo dialog
     container .gridContainer pmlnetcontrol 'Grid' dock fill width 50 height 25
   exit
   ```
2. **初始化并挂载事件**:
   ```pml
   define method .pmlGridDemo()
     using namespace 'Aveva.ApplicationFramework.Presentation'
     !this.grid = object GridControl()
     !this.gridContainer.control = !this.grid.handle()
     !this.grid.addeventhandler('OnPopup', !this, 'handleRightClick')
   endmethod
   ```
3. **响应右键弹出自定义 PML 菜单**:
   ```pml
   define method .handleRightClick(!args is ARRAY)
     !this.gridContainer.popup = !this.customMenu
     !this.gridContainer.showPopup(!args[0], !args[1])
   endmethod
   ```

---

## 4. 数据库同步与高级特性

### 4.1 核心数据库就地同步 (`DoDabaconCellUpdate`)
当表格显示 Dabacon 图元属性且允许就地编辑时，使用 `DoDabaconCellUpdate` 自动实现双向数据持久化：
```csharp
private void grid_BeforeCellUpdate(object sender, BeforeCellUpdateEventArgs e)
{
    // 将事件参数直接传入，内部自动校验权限并写入数据库
    grid.DoDabaconCellUpdate(e.Args);
    
    // 若同步失败，获取错误代码并给出界面提示
    if (e.Args.Count > 4 && (bool)e.Args[3] == false)
    {
        MessageBox.Show($"Dabacon write failed: {e.Args[4]}");
    }
}
```

### 4.2 图元类型图标自动呈现 (`setNameColumnImage`)
调用 `grid.setNameColumnImage()`，宿主将根据每行实体的真实 Dabacon 类型（如 Equipment, Sub-Equipment, Nozzle, Planar Panel 等）在 `"NAME"` 列左侧自动渲染 AVEVA 官方三维模型树图标，与 Model Explorer 保持高度一致。

### 4.3 商业授权避坑指南 (Infragistics Licensing)
- **免授权环境**: 在 C# 代码中纯编程式初始化（`new NetGridControl()`）或在 PML 窗体中通过 `container` 容器加载，**完全不需要任何第三方开发 License**。
- **需要授权场景**: 仅当开发者在 Visual Studio 窗体设计器（WinForms Designer）中直接拖拽控件设计界面时，才需要 Infragistics 商业开发授权。因此推荐一律采用代码动态创建。

## Key Takeaways
1. AVEVA C# Grid Control 具备开箱即用的 Excel 导出与打印能力，无需额外安装 Microsoft Office 组件。
2. 数据绑定首选内存 `DataTable`，对大型结果集具有极佳的响应效率。
3. 利用 `FixedHeaderOnColumns` 与 `SetRowColor`/`SetCellColor` 可大幅改善复杂图纸列表的人机交互体验。
4. 使用 `DoDabaconCellUpdate` 可轻松实现表格与数据库底层图元属性的双向无缝同步。
5. 采用代码动态创建 GridControl 可彻底免除 Infragistics 设计时开发授权限制。
6. My Data 机制适合作为用户跨操作流转数据的“暂存篮”，与外部 C# 工具链交互十分便利。

## Connects To
- **Ch 01**: [ch01-architecture-and-caf-addin.md](ch01-architecture-and-caf-addin.md)（在 CAF 停靠窗体中容纳 GridControl）
- **Ch 02**: [ch02-database-access-and-elements.md](ch02-database-access-and-elements.md)（查询 `DbElement` 填充至 GridControl）
- **Ch 03**: [ch03-pmlnet-interop-and-controls.md](ch03-pmlnet-interop-and-controls.md)（通过 PMLNet 将 Grid 暴露至 PML 架构）
- **Core Ref**: [../references/core-api-reference.md](../references/core-api-reference.md)（查看 GridControl 与 MyData 完整 API 清单）
