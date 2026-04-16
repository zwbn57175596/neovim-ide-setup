b7XrACQ*9pwX46HK# neovim-ide-setup

一键安装 Neovim IDE 开发环境（macOS ARM64）。

基于 [NormalNvim](https://github.com/NormalNvim/NormalNvim) 发行版，集成 Java 全链路开发支持（LSP / DAP / 测试 / 热重载）和 AI 编程辅助（avante.nvim + Claude Code CLI）。

## 特性

- **幂等安装** — 可重复运行，已安装组件自动跳过
- **Java IDE** — jdtls + nvim-java，支持运行 / 调试 / 测试 / Profiling
- **AI 增强** — avante.nvim (Cursor 式 AI 交互) + Claude Code 终端集成
- **全工具链** — ripgrep / fd / fzf / lazygit / yazi / Nerd Font 一并安装
- **自动补丁** — 修复 aerial.nvim 和 nvim-treesitter 在 Neovim 0.12 的兼容问题

## 快速开始

### 前提

- macOS ARM64 (Apple Silicon)
- 已安装 [Homebrew](https://brew.sh)
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）

### 安装

```bash
bash setup-neovim-ide.sh
```

### 清理（完全卸载重装）

```bash
bash cleanup-neovim.sh
```

## 快捷键速查

Leader 键 = `空格`

### AI

| 快捷键 | 功能 |
|--------|------|
| `<leader>ac` | Claude Code（浮动终端）|
| `<leader>av` | Claude Code（垂直分屏）|
| `<leader>aa` | avante 聊天 |
| `<leader>ae` | avante 编辑选中代码 |

### Java 开发

| 快捷键 | 功能 |
|--------|------|
| `<leader>jo` | Run App |
| `<leader>js` | Stop App |
| `<leader>jt` | Test Current Method |
| `<leader>jT` | Test Current Class |
| `<leader>jD` | Config DAP（调试前运行一次）|
| `<leader>jd` | Debug Test Method |
| `<leader>jp` | Profiler UI |

### 调试（通用）

| 快捷键 | 功能 |
|--------|------|
| `<F5>` | Start / Continue |
| `<F9>` | Toggle Breakpoint |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<S-F11>` | Step Out |

## 文档

- [设计文档](docs/design.md) — 架构分层与模块设计
- [使用手册](docs/manual.md) — 完整快捷键映射与使用说明

## 安装后配置

```bash
# Anthropic API Key（avante.nvim 使用）
export ANTHROPIC_API_KEY='your-key-here'

# 项目 JDK（nvim-java 会自动下载 JDTLS 所需 JDK，此处只影响项目编译）
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

将以上两行加入 `~/.zshrc` 以持久化。
