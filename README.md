b7XrACQ*9pwX46HK# neovim-ide-setup

一键安装 Neovim IDE 开发环境（macOS ARM64 / Ubuntu Linux / Windows 11）。

基于 [NormalNvim](https://github.com/NormalNvim/NormalNvim) 发行版，集成 Java 全链路开发支持（LSP / DAP / 测试 / 热重载）和 AI 编程辅助（avante.nvim + Claude Code CLI）。

## 特性

- **幂等安装** — 可重复运行，已安装组件自动跳过
- **Java IDE** — jdtls + nvim-java，支持运行 / 调试 / 测试 / Profiling
- **AI 增强** — avante.nvim (Cursor 式 AI 交互) + Claude Code 终端集成
- **全工具链** — ripgrep / fd / fzf / lazygit / yazi / Nerd Font 一并安装
- **自动补丁** — 修复 aerial.nvim 和 nvim-treesitter 在 Neovim 0.12 的兼容问题

## 快速开始

### macOS ARM64 (Apple Silicon)

**前提：**
- 已安装 [Homebrew](https://brew.sh)
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）

无需 clone 仓库，直接运行：

```bash
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-mac.sh | bash
```

或 clone 后本地运行：

```bash
bash setup-neovim-ide-mac.sh
```

清理（完全卸载重装）：

```bash
bash cleanup-neovim-mac.sh
```

### Ubuntu Linux (x86_64 / ARM64)

**前提：**
- Ubuntu 22.04 LTS 或更高版本
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）
- 需要 `sudo` 权限（apt 操作）

无需 clone 仓库，直接运行：

```bash
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-ubuntu.sh | bash
```

或 clone 后本地运行：

```bash
bash setup-neovim-ide-ubuntu.sh
```

清理（完全卸载重装）：

```bash
bash cleanup-neovim-ubuntu.sh
```

### Windows 11

**前提：**
- PowerShell 5.1 或更高版本
- [Scoop](https://scoop.sh)（未安装时脚本将自动安装）
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）

无需 clone 仓库，直接运行（PowerShell）：

```powershell
irm https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-win.ps1 | iex
```

或 clone 后本地运行：

```powershell
.\setup-neovim-ide-win.ps1
```

清理（完全卸载重装）：

```powershell
.\cleanup-neovim-win.ps1
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
# macOS: export JAVA_HOME=$(/usr/libexec/java_home -v 17)
# Ubuntu: export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export ANTHROPIC_API_KEY='your-key-here'
```

将上述配置加入你的 shell 配置文件以持久化（macOS 用 `~/.zshrc`，Ubuntu 用 `~/.bashrc`）。
