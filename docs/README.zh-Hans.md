[English](../README.md) | [한국어](README.ko.md) | 简体中文 | [日本語](README.ja.md) | [Español](README.es.md) | [Deutsch](README.de.md) | [Français](README.fr.md) | [tlhIngan Hol](README.tlh.md)

# PopPage

[![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-000000?logo=apple&logoColor=white)](#系统要求)
[![Swift 6](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](#系统要求)
[![Latest Release](https://img.shields.io/github/v/release/badugisoft/poppage?label=Release)](https://github.com/badugisoft/poppage/releases/latest)
[![Website](https://img.shields.io/badge/Website-GitHub%20Pages-2563EB)](https://badugisoft.github.io/poppage/)

一个基于 Swift 的轻量级 macOS 菜单栏应用，可将常用网站固定到菜单栏并在弹出窗口中快速打开和关闭。

[官方网站](https://badugisoft.github.io/poppage/) · [下载最新版本](https://github.com/badugisoft/poppage/releases/latest) · [界面截图](#界面截图) · [主要功能](#主要功能) · [快捷键](#键盘快捷键) · [更新日志](../CHANGELOG.md)

## 为什么做 PopPage？

市面上已经有许多类似且功能更丰富的 macOS 菜单栏浏览器应用，例如 **MenubarX**、**FloatBrowser** 和 **MenuBox**。PopPage 的初衷是打造一款**完全免费**、**轻量级**的原生应用，只专注于真正必需的核心功能（如按页面自定义图标、页面跳转策略、自定义 HTTP 请求头以及设置导出/导入），避免冗余负担。

本应用 **100% 使用 Antigravity 构建**。

## 界面截图

| 弹出窗口 | 页面设置 | 应用设置 |
| :---: | :---: | :---: |
| ![弹出窗口](images/screenshot-popover.png) | ![页面设置](images/screenshot-page-settings.png) | ![应用设置](images/screenshot-app-settings.png) |

## 下载与安装

1. 从 [GitHub Releases](https://github.com/badugisoft/poppage/releases/latest) 下载经过签名和公证的最新 `.dmg` 或 `.zip` 安装包。
2. 打开 `.dmg`（或解压 `.zip`），将 **PopPage.app** 拖入 `/Applications` 文件夹。
3. 从应用程序或聚焦搜索启动 **PopPage**。

## 主要功能

- **页面管理**：在管理窗口中添加、编辑、删除、排序以及启用/停用网站
- **菜单栏图标自定义**：自动获取网站 Favicon、使用自定义文本，或选择自定义图像（支持模板模式）
- **弹出窗口切换与焦点关闭**：点击菜单栏图标切换弹出窗口显示状态，可选在失去焦点时自动关闭
- **打开/关闭动画**：支持按页面单独开启或关闭弹出窗口动画
- **新窗口与页面跳转策略**：
  - 允许在默认外部浏览器中打开新窗口链接（如 `target="_blank"`）
  - 可配置页面跳转策略（`不跳转` / `在外部浏览器中打开` / `在弹出窗口中跳转`）
- **自定义 HTTP 请求头**：按页面添加、启用/停用和删除 HTTP/HTTPS 请求头（含 `User-Agent`）
- **弹出窗口大小与调整**：设置默认宽高，通过右下角拖拽手柄调整大小，并可选记住修改后的大小
- **缩放控制**：按页面设置默认缩放比例，并可选记住修改后的缩放比例
- **键盘快捷键**：按页面启用或停用弹出窗口快捷键，并在开关旁提供快捷键参考弹出提示
- **底部工具栏与覆盖模式**：控制后退/前进、重新加载和缩放按钮的显示，或将工具栏覆盖在网页上方并调节背景不透明度
- **自适应工具栏背景**：自动使底部工具栏颜色与网页背景保持一致
- **应用设置**：在管理窗口左下角“设置”标签页中配置登录时自动启动、应用内语言（`系统默认` / `English` / `한국어` / `简体中文` / `日本語` / `Español` / `Deutsch` / `Français` / `tlhIngan Hol`），以及以 JSON 格式导出/导入设置（包含页面、自定义图标和语言）
- **多语言支持**：支持英语（默认）、韩语、简体中文、日语、西班牙语、德语、法语和克林贡语

## 键盘快捷键

当页面开启**启用键盘快捷键**时，可在弹出窗口中使用以下快捷键：

| 快捷键 | 操作 |
| :---: | :--- |
| `⌘ +` | 放大 |
| `⌘ -` | 缩小 |
| `⌘ 0` | 重置缩放 |
| `⌘ [` | 后退 |
| `⌘ ]` | 前进 |
| `⌘ R` | 重新加载 |

## 系统要求

- macOS 14.0 及以上
- Xcode / Swift 6 工具链（仅从源码构建时需要）

## 从源码构建

```bash
# 查看所有可用目标
make help

# Debug / Release 构建
make build
make release

# 构建 .app 应用包 (build/PopPage.app)
make app

# 构建并启动
make run

# 安装到 /Applications（或 INSTALL_DIR=/自定义路径 make install）
make install
make uninstall

# 重新生成 AppIcon.icns 或检查 plist/strings 语法
make icon
make lint

# 清理构建产物
make clean
```

## 数据存储位置

- 页面配置：`~/Library/Application Support/PopPage/pages.json`
- 缓存的 Favicon 与自定义图像：`~/Library/Application Support/PopPage/icons/`
- 应用语言偏好：`~/Library/Preferences/com.badugisoft.poppage.plist`
