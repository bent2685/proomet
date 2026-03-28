# CLAUDE.md — Proomet 项目指南

## 技术栈

- **语言**: Swift 5.0
- **UI 框架**: SwiftUI（主框架）+ AppKit（NSTextView 编辑器）
- **数据持久化**: SwiftData（本地存储）
- **构建系统**: Xcode 原生项目（非 SPM）
- **无第三方依赖**

## 项目结构

```
proomet/
├── proometApp.swift          # App 入口，SwiftData 容器初始化，默认分类创建
├── ContentView.swift         # 根视图，NavigationSplitView 三栏布局
├── SidebarView.swift         # 侧边栏：全部、分类管理、标签筛选
├── PromptListView.swift      # Prompt 列表，CRUD 操作
├── PromptEditorView.swift    # 编辑器：标题、分类、标签、Markdown 内容
├── PromptRowView.swift       # 列表行组件
├── TagEditorView.swift       # 标签编辑器（含自定义 FlowLayout）
├── CategoryRow.swift         # 侧边栏分类行组件
├── MarkdownEditorView.swift  # NSViewRepresentable 包装 NSTextView
└── Models/
    ├── PromptItem.swift      # 核心 Prompt 模型
    ├── PromptCategory.swift  # 分类模型
    ├── PromptVersion.swift   # 版本历史模型（树状结构，支持分支/合并）
    └── SidebarSelection.swift # 侧边栏导航枚举
```

## 数据模型关系

- **PromptItem ↔ PromptCategory**: 多对一，分类删除时 prompt 的 category 置空（nullify）
- **PromptItem ↔ PromptVersion**: 一对多，prompt 删除时版本级联删除（cascade）
- **PromptVersion ↔ PromptVersion**: 树状结构，parentVersion/childVersions 实现版本分支

## 编码规范

### 命名

- 类型名 PascalCase，属性/方法 camelCase
- 所有视图以 `View` 结尾（`SidebarView`, `PromptEditorView`）
- SwiftData 模型以业务名命名（`PromptItem`, `PromptCategory`）

### SwiftUI 模式

- `@Query` 配合 SortDescriptor 进行响应式数据获取
- `@Environment(\.modelContext)` 进行数据修改
- `@Bindable` 绑定 SwiftData 模型到视图
- `@FocusState` 管理输入焦点
- `.onChange` 处理副作用

### 文件组织

- Models 放 `Models/` 目录
- 视图文件平铺在 `proomet/` 根目录
- 无 ViewModel 层，业务逻辑直接在 View 中通过 `@Environment` 操作

## 构建配置

- **并发模型**: `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`，`SWIFT_APPROACHABLE_CONCURRENCY = YES`
- **沙盒**: 已启用（ENABLE_APP_SANDBOX）
- **加固运行时**: 已启用（ENABLE_HARDENED_RUNTIME）
- **默认窗口尺寸**: 1000 x 680
- **Upcoming Feature**: `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES`

## 开发注意事项

### 必须遵守

1. **纯本地应用** — 不做远程同步、云存储。数据全部使用 SwiftData 本地持久化
2. **Apple 原生技术栈** — 不引入第三方依赖，优先使用系统框架
3. **中文 UI** — 当前界面文本为硬编码简体中文，添加新 UI 文本时保持一致
4. **SwiftData 模型修改要谨慎** — 修改 `@Model` 属性会影响数据迁移，新增属性必须提供默认值
5. **保持轻量** — 这是一个专注于 Prompt 管理的工具，不做 AI 搜索、Prompt 构建器等复杂功能
6. **默认分类不可删除** — `isDefault == true` 的分类受

## Git 提交规范

提交类型：`feat`、`chore`、`fix`、`docs`、`styles`、`refactor`

示例:

```
feat(tags): 简要的说明

- 新增 xxxx
- 新增 xxxx
- 修复 xxxx
```

**禁止在提交信息中携带任何作者信息**，包括但不限于 `Co-Authored-By`、`Signed-off-by` 等署名字段。

