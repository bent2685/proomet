<p align="center">
  <img src="icon_rounded.png" width="128" height="128" alt="proomet icon">
</p>

<h1 align="center">proomet</h1>

<p align="center">
  一款原生 macOS 提示词管理工具，为你的 AI 工作流而生。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS_26+-blue?logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.0-F05138?logo=swift&logoColor=white" alt="Swift">
  <img src="https://img.shields.io/badge/UI-SwiftUI-007AFF?logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/data-SwiftData-34C759" alt="SwiftData">
  <img src="https://img.shields.io/badge/version-v0.0.1--beta-orange" alt="Version">
</p>

<p align="center">
  <a href="README.md">English</a>
</p>

---

## 简介

**proomet** 是一款轻量的原生 macOS 应用，用于整理和管理 AI 提示词。它提供简洁的三栏界面，方便你创建、分类、标记提示词，并快速复制到剪贴板供任何大语言模型使用。

## 功能

- **三栏布局** — 侧边栏导航、提示词列表、Markdown 编辑器
- **分类与标签** — 按分类管理提示词，支持多标签筛选
- **Markdown 编辑器** — 语法高亮，支持变量占位符（`{{variable}}`）
- **一键复制** — 点击即可复制提示词到剪贴板，带 Toast 反馈
- **使用追踪** — 记录每条提示词的使用次数和最近使用时间
- **版本历史** — 内置提示词版本管理基础设施
- **标签编辑器** — 弹出式标签管理，自动建议已有标签
- **内联编辑** — 直接在侧边栏重命名和管理分类
- **SwiftData 持久化** — 使用 Apple 现代数据框架本地存储

## 截图

> 即将推出

## 系统要求

- macOS 26+
- Xcode 26+

## 构建

```bash
git clone https://github.com/bent2685/proomet.git
cd proomet
open proomet.xcodeproj
```

在 Xcode 中按 `Cmd + R` 编译运行。

## 许可证

保留所有权利。
