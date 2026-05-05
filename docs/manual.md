# Neovim IDE 使用手册

> 基于 NormalNvim + AI 增强配置 | Leader 键 = `空格` | LocalLeader 键 = `,`

---

## 目录

1. [基础概念](#1-基础概念)
2. [启动与界面](#2-启动与界面)
3. [完整快捷键映射表](#3-完整快捷键映射表)
4. [文件与项目管理](#4-文件与项目管理)
5. [代码编辑](#5-代码编辑)
6. [LSP 智能功能](#6-lsp-智能功能)
7. [Java 开发专项](#7-java-开发专项)
8. [调试 (DAP)](#8-调试-dap)
9. [测试](#9-测试)
10. [AI 辅助编程](#10-ai-辅助编程)
11. [Git 集成](#11-git-集成)
12. [终端](#12-终端)
13. [搜索与查找 (Telescope)](#13-搜索与查找-telescope)
14. [插件管理](#14-插件管理)
15. [UI 开关与切换](#15-ui-开关与切换)
16. [代码折叠](#16-代码折叠)
17. [会话管理](#17-会话管理)
18. [配置文件地图](#18-配置文件地图)
19. [常见问题](#19-常见问题)

---

## 1. 基础概念

### Leader 键

本配置使用 **空格键 (Space)** 作为 Leader 键。本文档中 `<leader>` 等同于按下空格键。

### 模式缩写

| 缩写 | 模式 | 进入方式 |
|------|------|---------|
| `n` | Normal | `Esc` |
| `i` | Insert | `i`, `a`, `o` 等 |
| `v` | Visual | `v`, `V` |
| `x` | Visual Block | `Ctrl+v` |
| `t` | Terminal | 进入终端缓冲区 |
| `c` | Command | `:` |

### 环境要求

| 组件 | 最低版本 | 用途 |
|------|---------|------|
| Neovim | 0.10+ | 编辑器核心 |
| Nerd Font | 任意 | 图标显示 (推荐 JetBrains Mono Nerd Font) |
| ripgrep | 最新 | 内容搜索 (Telescope) |
| fd | 最新 | 文件搜索 (Telescope) |
| Node.js | 18+ | LSP/插件依赖 |
| Python 3 | 3.10+ | Python LSP/DAP |
| Java 17 | Zulu 17 | Java 开发 |

---

## 2. 启动与界面

### 界面布局

```
┌──────────────────── Tabline (Buffer 标签栏) ────────────────────┐
│ [buf1.java] [buf2.py] [buf3.lua]                               │
├──────────────────── Winbar (面包屑导航) ────────────────────────┤
│ src > main > java > com > App.java  ▸ class App > method main  │
├───────┬─────────────────────────────────────────┬──────────────┤
│ Signs │                                         │              │
│ + Fold│         主编辑区域                        │  Aerial      │
│ + Num │                                         │  (符号大纲)   │
│       │                                         │              │
├───────┴─────────────────────────────────────────┴──────────────┤
│ StatusLine: [模式] [Git分支] [文件名] [诊断] ... [LSP] [位置]    │
└────────────────────────────────────────────────────────────────┘
```

### 启动页 (Alpha)

打开 Neovim 时自动显示，包含快捷按钮：

| 按键 | 功能 |
|------|------|
| `n` | 新建文件 |
| `e` | 最近文件 |
| `r` | Yazi 文件浏览器 |
| `s` | 会话列表 |
| `p` | 项目列表 |
| `q` | 退出 |

返回启动页: `<leader>h`

---

## 3. 完整快捷键映射表

> 提示: 在 Neovim 中按 `<leader>fk` 可以用 Telescope 搜索所有快捷键。
> 按住 `<leader>` 不放，which-key 会弹出所有可用映射。

### 3.1 基础操作

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>w` | n | 保存文件 |
| `<leader>W` | n | sudo 保存文件 |
| `<leader>n` | n | 新建文件 |
| `<leader>q` | n | 退出 (有确认) |
| `<C-s>` | n | 强制保存 |
| `<leader>/` | n | 注释/取消注释当前行 |
| `<leader>/` | x | 注释/取消注释选中区域 |
| `0` | n | 跳到行首非空字符 (等同 `^`) |
| `j` / `k` | n | 按显示行移动 (折行友好) |

### 3.2 剪贴板

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<C-y>` | n, x | 复制到系统剪贴板 |
| `<C-d>` | n, x | 复制到剪贴板并删除行 |
| `<C-p>` | n | 从系统剪贴板粘贴 |
| `c` / `C` | n, x | 修改文本 (不污染剪贴板) |
| `x` / `X` | n, x | 删除字符 (不污染剪贴板) |
| `p` | x | 粘贴 (不自动复制被替换内容) |

### 3.3 移动与选择

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gg` | n, x | 跳到文件开头第一个字符 |
| `G` | n, x | 跳到文件末尾最后一个字符 |
| `<C-a>` | n | 全选 |
| `<S-Down>` | n | 快速下移 7 行 |
| `<S-Up>` | n | 快速上移 7 行 |
| `<S-PageDown>` | n | 下翻 20% 文件 |
| `<S-PageUp>` | n | 上翻 20% 文件 |
| `<C-m>` / `Enter` | n, x | **Hop**: 跳转到可见文本任意单词 |

### 3.4 缩进

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<Tab>` | x | 增加缩进 (保持选中) |
| `<S-Tab>` | x | 减少缩进 (保持选中) |
| `>` | x | 增加缩进 (保持选中) |
| `<` | x | 减少缩进 (保持选中) |

### 3.5 窗口与分屏

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `\|` | n | 垂直分屏 |
| `\` | n | 水平分屏 |
| `<C-h>` | n | 移动到左窗口 |
| `<C-j>` | n | 移动到下窗口 |
| `<C-k>` | n | 移动到上窗口 |
| `<C-l>` | n | 移动到右窗口 |
| `<C-Up>` | n | 调整窗口大小 (上) |
| `<C-Down>` | n | 调整窗口大小 (下) |
| `<C-Left>` | n | 调整窗口大小 (左) |
| `<C-Right>` | n | 调整窗口大小 (右) |

### 3.6 Buffer (缓冲区) 管理

> `<leader>b` 打开 Buffer 菜单 (which-key)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `]b` | n | 下一个 buffer |
| `[b` | n | 上一个 buffer |
| `>b` | n | 将 buffer 标签右移 |
| `<b` | n | 将 buffer 标签左移 |
| `<leader>c` | n | 关闭当前 buffer 和窗口 |
| `<leader>C` | n | 关闭当前 buffer (保留窗口) |
| `<leader>bb` | n | 从标签栏选择 buffer |
| `<leader>bd` | n | 从标签栏删除 buffer |
| `<leader>bc` | n | 关闭所有其他 buffer |
| `<leader>bC` | n | 关闭全部 buffer |
| `<leader>bl` | n | 关闭左侧所有 buffer |
| `<leader>br` | n | 关闭右侧所有 buffer |
| `<leader>ba` | n | 保存所有 buffer |
| `<leader>bw` | n | 关闭窗口 |
| `<leader>bse` | n | 按扩展名排序 buffer |
| `<leader>bsr` | n | 按相对路径排序 buffer |
| `<leader>bsp` | n | 按完整路径排序 buffer |
| `<leader>bsi` | n | 按 buffer 号排序 |
| `<leader>bsm` | n | 按修改时间排序 buffer |
| `<leader>b\|` | n | 垂直分屏打开选中 buffer |
| `<leader>b\` | n | 水平分屏打开选中 buffer |

### 3.7 Tab (标签页)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `]t` | n | 下一个标签页 |
| `[t` | n | 上一个标签页 |

---

## 4. 文件与项目管理

### NeoTree (文件树)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>e` | n | 切换 NeoTree 文件树 |

NeoTree 内快捷键: `?` 查看帮助

### Yazi (文件浏览器)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>r` | n | 打开 Yazi 文件浏览器 |

### 项目导航

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>fp` | n | Telescope 项目列表 |

---

## 5. 代码编辑

### TreeSitter 文本对象

可以配合 `v` (选中), `d` (删除), `c` (修改), `y` (复制) 使用：

| 文本对象 | 含义 |
|---------|------|
| `af` / `if` | 函数外部 / 内部 |
| `ac` / `ic` | 类外部 / 内部 |
| `ak` / `ik` | 代码块外部 / 内部 |
| `aa` / `ia` | 参数外部 / 内部 |
| `a?` / `i?` | 条件语句外部 / 内部 |
| `al` / `il` | 循环外部 / 内部 |

示例: `vaf` 选中整个函数, `dif` 删除函数体, `cic` 修改类内部。

### TreeSitter 跳转

| 快捷键 | 功能 |
|--------|------|
| `]f` / `[f` | 下/上一个函数开头 |
| `]F` / `[F` | 下/上一个函数结尾 |
| `]k` / `[k` | 下/上一个代码块 |
| `]a` / `[a` | 下/上一个参数 |

### TreeSitter 交换

| 快捷键 | 功能 |
|--------|------|
| `>F` / `<F` | 与下/上一个函数交换 |
| `>A` / `<A` | 与下/上一个参数交换 |
| `>K` / `<K` | 与下/上一个代码块交换 |

### 自动补全 (nvim-cmp)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<Tab>` | i | 选择下一个补全项 / 展开 snippet |
| `<S-Tab>` | i | 选择上一个补全项 |
| `<CR>` | i | 确认补全 |
| `<C-Space>` | i | 手动触发补全 |
| `<C-e>` | i | 关闭补全菜单 |
| `<C-j>` / `<C-k>` | i | 上下选择补全项 |
| `<C-u>` / `<C-d>` | i | 滚动文档窗口 |
| `<PageUp>` / `<PageDown>` | i | 快速翻页选择 (8项) |

补全来源优先级: LSP > lazydev > Snippet > Copilot > Buffer > Path

### Snippets (代码片段)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>fs` | n | Telescope 搜索代码片段 |

已配置的语言片段: Java (javadoc), TypeScript (tsdoc), Python (pydoc), Lua (luadoc), Rust, C/C++, PHP, Kotlin, Ruby, Shell

---

## 6. LSP 智能功能

> `<leader>l` 打开 LSP 菜单 (which-key)

### 代码导航

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gd` | n | 跳转到定义 (Telescope) |
| `gD` | n | 跳转到声明 |
| `gI` | n | 跳转到实现 (Telescope) |
| `gT` | n | 跳转到类型定义 |
| `gr` | n | 查看所有引用 (Telescope) |
| `gh` | n | 悬浮帮助/文档 |
| `gH` | n | 函数签名帮助 |
| `gm` | n | 悬浮 man 文档 |
| `gs` | n | 搜索当前 buffer 符号 (Telescope) |
| `gS` | n | 搜索工作区符号 (Telescope) |

### 代码调用树

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gj` | n | 调用树 - 谁调用了此函数 (incoming calls) |
| `gJ` | n | 调用树 - 此函数调用了什么 (outgoing calls) |

### 诊断

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `gl` | n | 悬浮显示当前行诊断 |
| `[d` | n | 上一个诊断 |
| `]d` | n | 下一个诊断 |
| `<leader>ld` | n | 悬浮显示诊断详情 |
| `<leader>lD` | n | Telescope 查看所有诊断 |

### 代码操作与重构

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>la` | n, v | **代码操作** (重构菜单: 提取方法/变量/常量、整理导入等) |
| `<leader>lr` | n | **重命名符号** |
| `<leader>lf` | n, v | **格式化代码** |
| `<leader>ll` | n | 运行 CodeLens |
| `<leader>lR` | n | 查看引用 (Telescope) |
| `<leader>ls` | n | 搜索 buffer 内符号 (Telescope) |
| `<leader>lS` | n | 搜索工作区符号 (Telescope) |
| `<leader>lL` | n | 重启 LSP |
| `<leader>li` | n | LSP 信息 |
| `<leader>lI` | n | None-ls 信息 |

### LSP 已配置的语言服务

| 语言 | LSP Server | 来源 |
|------|-----------|------|
| Java | jdtls | nvim-java 管理 |
| TypeScript/JS | ts_ls | Mason 自动安装 |
| Python | pyright | Mason 自动安装 |
| Lua | lua_ls | Mason 自动安装 |

---

## 7. Java 开发专项

> `<leader>j` 打开 Java 菜单 (which-key)

### Java 快捷键

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>jo` | n | 运行 Java 应用 |
| `<leader>js` | n | 停止 Java 应用 |
| `<leader>jt` | n | 运行当前测试方法 |
| `<leader>jT` | n | 运行当前测试类 |
| `<leader>jd` | n | 调试当前测试方法 |
| `<leader>jp` | n | 性能分析 (Profile) |

### Java 重构 (通过 Code Action)

按 `<leader>la` 打开 Code Action 菜单，jdtls 提供以下重构能力：

- **Extract Variable** — 提取变量
- **Extract Method** — 提取方法
- **Extract Constant** — 提取常量
- **Inline Variable** — 内联变量
- **Organize Imports** — 整理导入
- **Generate toString/hashCode/equals** — 生成常用方法
- **Override/Implement Methods** — 覆盖/实现方法
- **Convert to static import** — 转为静态导入

### Java 项目要求

项目根目录需要以下标记文件之一：
`pom.xml`, `build.gradle`, `build.gradle.kts`, `settings.gradle`, `settings.gradle.kts`, `mvnw`, `gradlew`, `.git`

### Lombok 支持

nvim-java 的 jdtls 自动加载 Lombok agent，无需额外配置。

---

## 8. 调试 (DAP)

> `<leader>d` 打开调试菜单 (which-key)

### 调试控制 (F 键)

| 快捷键 | 功能 |
|--------|------|
| `<F5>` | 启动/继续调试 |
| `<S-F5>` | 终止调试 |
| `<C-F5>` | 重启调试 |
| `<F9>` | 切换断点 |
| `<S-F9>` | 条件断点 |
| `<F10>` | 单步跳过 (Step Over) |
| `<S-F10>` | 单步回退 (Step Back) |
| `<F11>` | 单步进入 (Step Into) |
| `<S-F11>` | 单步跳出 (Step Out) |

### 调试控制 (Leader 键)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>dc` | n | 启动/继续 |
| `<leader>dq` | n | 关闭调试会话 |
| `<leader>dQ` | n | 终止调试 |
| `<leader>dr` | n | 重启调试 |
| `<leader>dp` | n | 暂停 |
| `<leader>ds` | n | 运行到光标处 |
| `<leader>do` | n | Step Over |
| `<leader>db` | n | Step Into |
| `<leader>dO` | n | Step Out |

### 断点管理

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>db` | n | 切换断点 |
| `<leader>dB` | n | 清除所有断点 |
| `<leader>dC` | n | 条件断点 |

### 调试 UI

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>du` | n | 切换调试 UI 面板 |
| `<leader>dh` | n | 悬浮查看变量值 |
| `<leader>dE` | n, x | 计算表达式 |
| `<leader>dR` | n | 打开 REPL |

### DAP UI 布局

```
┌────────────────────────────────┬───────────────────────────┐
│ 主编辑区域                      │  Scopes    (变量)  35%   │
│                                │  Breakpoints (断点) 15%   │
│                                │  Stacks    (调用栈) 35%   │
│  代码 + 断点标记                 │  Watches   (监视)  15%   │
├────────────────────────────────┴───────────────────────────┤
│  REPL (交互) 50%  │  Console (输出) 50%                    │
└────────────────────────────────────────────────────────────┘
```

### 断点图标

| 图标 | 含义 |
|------|------|
| 🔴 | 普通断点 |
| 🟡 | 条件断点 |
| 📝 | 日志断点 |
| ❌ | 被拒绝的断点 |
| ▶️ | 当前停止行 |

### 已配置的调试器

| 语言 | 调试适配器 | 安装方式 |
|------|-----------|---------|
| Java | jdtls (内置) | nvim-java 自动管理 |
| Python | debugpy | Mason |
| JavaScript/TS | firefox-debug-adapter | Mason |
| C/C++/Rust | codelldb | Mason |
| Go | delve | Mason |
| Shell | bash-debug-adapter | Mason |
| Lua | one-small-step-for-vimkind | 插件 |
| Kotlin | kotlin-debug-adapter | Mason |
| C# | netcoredbg | Mason |
| Dart/Flutter | dart-debug-adapter | Mason |
| Elixir | elixir-ls-debugger | Mason |
| PHP | php-debug-adapter | Mason |

### Java 调试配置 (预设)

| 配置名 | 说明 |
|--------|------|
| Launch Current File | 调试当前文件 |
| Launch Main Class | 指定主类启动 |
| Launch with Arguments | 带参数启动 |
| Attach to Remote JVM (5005) | 附加到 5005 端口 |
| Attach (Custom Port) | 自定义端口附加 |
| Spring Boot | Spring Boot 项目 |
| Debug Test (JUnit) | JUnit 测试调试 |

### VSCode launch.json 支持

将 `.vscode/launch.json` 放在项目根目录，DAP 会自动加载其中的配置。

### 断点持久化

断点在退出 Neovim 时自动保存，下次打开自动恢复。存储位置: `~/.local/share/nvim/dap-breakpoints.json`

---

## 9. 测试

> `<leader>T` 打开测试菜单 (which-key)

### Neotest 快捷键

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>Tu` | n | 运行最近的测试 |
| `<leader>Ts` | n | 停止测试 |
| `<leader>Tf` | n | 运行当前文件所有测试 |
| `<leader>Td` | n | 在调试器中运行测试 |
| `<leader>Tt` | n | 切换测试摘要面板 |
| `<leader>TT` | n | 切换测试输出面板 |
| `<leader>Ta` | n | 运行所有 Node.js 测试 |
| `<leader>Te` | n | 运行 Node.js E2E 测试 |

### 代码覆盖率

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>Tc` | n | 查看覆盖率摘要 |
| `<leader>TC` | n | 切换覆盖率标记显示 |

覆盖率要求项目生成 `coverage/lcov.info` 文件。

### 支持的测试框架

Java (JUnit), JavaScript (Jest), Python (pytest), Rust, Go, Dart, .NET, Elixir, PHP (PHPUnit), Zig

---

## 10. AI 辅助编程

> `<leader>a` 打开 AI 菜单 (which-key)

### avante.nvim (类 Cursor AI)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>aa` | n | 打开 Avante AI 聊天侧边栏 |
| `<leader>ae` | v | AI 编辑选中代码 |
| `<leader>ar` | n | 刷新 Avante |

**使用方法:**
1. 设置环境变量: `export ANTHROPIC_API_KEY="sk-ant-..."`
2. 按 `<leader>aa` 打开侧边栏
3. 输入需求描述，AI 会给出代码建议
4. 建议以 diff 形式展示，可以一键接受或拒绝

### Claude Code (CLI Agent)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>ac` | n | 在浮动终端打开 Claude Code (85% 屏幕) |
| `<leader>av` | n | 在垂直分屏打开 Claude Code (40% 宽度) |

**使用方法:**
1. 确保已安装 `claude` CLI
2. 按 `<leader>ac` 启动浮动窗口
3. 在终端中与 Claude Code 交互
4. 按 `Esc` 切换到 Normal 模式浏览输出，按 `i` 回到输入
5. 再次按 `<leader>ac` 切换显示/隐藏

### Copilot (行内代码补全)

Copilot 已集成到 nvim-cmp 补全源中（优先级 600）。

首次使用需运行 `:Copilot auth` 登录 GitHub。

### Neural (ChatGPT)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>a` | n | (如未被覆盖) 打开 Neural/ChatGPT |

需设置 `OPENAI_API_KEY` 环境变量。

---

## 11. Git 集成

> `<leader>g` 打开 Git 菜单 (which-key)

### Git Hunk 操作 (gitsigns)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `]g` | n | 下一个 Git 变更块 |
| `[g` | n | 上一个 Git 变更块 |
| `<leader>gs` | n | Stage 当前变更块 |
| `<leader>gS` | n | Stage 整个文件 |
| `<leader>gu` | n | Unstage 当前变更块 |
| `<leader>gh` | n | 重置当前变更块 |
| `<leader>gr` | n | 重置整个文件 |
| `<leader>gp` | n | 预览当前变更块 |
| `<leader>gl` | n | 查看当前行 Git Blame |
| `<leader>gL` | n | 查看完整 Git Blame |
| `<leader>gd` | n | 查看 Git Diff |

### Git 全局操作

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>gg` | n | 打开 LazyGit (或 GitUI) |
| `<leader>gb` | n | Telescope 查看 Git 分支 |
| `<leader>gc` | n | Telescope 查看仓库 Git 提交 |
| `<leader>gC` | n | Telescope 查看当前文件 Git 提交 |
| `<leader>gt` | n | Telescope 查看 Git 状态 |
| `<leader>gP` | n | 在 GitHub 中打开 (fugitive) |

---

## 12. 终端

> `<leader>t` 打开终端菜单 (which-key)

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>tt` | n | 浮动终端 |
| `<leader>th` | n | 底部水平终端 |
| `<leader>tv` | n | 右侧垂直终端 |
| `<F7>` | n, t | 切换终端 |
| `<C-'>` | n, t | 切换终端 (需终端支持) |

### 终端内导航

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<C-h>` | t | 移动到左窗口 |
| `<C-j>` | t | 移动到下窗口 |
| `<C-k>` | t | 移动到上窗口 |
| `<C-l>` | t | 移动到右窗口 |

---

## 13. 搜索与查找 (Telescope)

> `<leader>f` 打开查找菜单 (which-key)

### 文件与内容搜索

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>ff` | n | **全局搜索** 项目文件内容 (含隐藏文件) |
| `<leader>fF` | n | 全局搜索文件内容 (不含隐藏文件) |
| `<leader>fw` | n | 搜索光标下的单词 |
| `<leader>f/` | n | 搜索当前 buffer 内容 |
| `<leader>fo` | n | 最近打开的文件 |
| `<leader>fB` | n | 打开的 Buffer 列表 |
| `<leader>fa` | n | 搜索 Neovim 配置文件 |

### 工具搜索

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>fh` | n | 搜索帮助文档 |
| `<leader>fk` | n | 搜索快捷键 |
| `<leader>fm` | n | 搜索 man 手册 |
| `<leader>fC` | n | 搜索命令 |
| `<leader>fv` | n | 搜索 Vim 寄存器 |
| `<leader>ft` | n | 搜索/切换主题 |
| `<leader>fn` | n | 搜索通知历史 |
| `<leader>f<CR>` | n | 恢复上次搜索 |

### 项目与替换

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>fp` | n | 搜索项目 (project.nvim) |
| `<leader>fr` | n | **全局搜索替换** (Spectre) |
| `<leader>fb` | n | 当前 buffer 搜索替换 (Spectre) |

### 其他

| 快捷键 | 模式 | 功能 |
|--------|------|------|
| `<leader>fs` | n | 搜索代码片段 (Snippets) |
| `<leader>fy` | n | 搜索复制历史 (Yank history) |
| `<leader>fq` | n | 搜索宏历史 |
| `<leader>fu` | n | 搜索撤销历史 (Undo tree) |
| `<leader>f'` | n | 搜索标记 (Marks) |

### Telescope 内操作

| 快捷键 | 功能 |
|--------|------|
| `<C-j>` / `<C-k>` | 上下移动选择 |
| `<CR>` | 确认选择 |
| `<Esc>` | 关闭 |
| `q` (Normal) | 关闭 |

---

## 14. 插件管理

> `<leader>p` 打开包管理菜单 (which-key)

### lazy.nvim

| 快捷键 / 命令 | 功能 |
|---------------|------|
| `<leader>pu` | 打开 Lazy 管理界面 |
| `<leader>pU` | 更新所有插件 |
| `:Lazy` | 打开 Lazy 管理界面 |
| `:Lazy sync` | 同步插件 (安装 + 更新 + 清理) |
| `:Lazy health` | 检查健康状态 |

### Mason (LSP/DAP 包管理器)

| 快捷键 / 命令 | 功能 |
|---------------|------|
| `<leader>pm` | 打开 Mason |
| `<leader>pM` | 更新所有 Mason 包 |
| `:Mason` | 打开 Mason 管理界面 |
| `:MasonInstall <name>` | 安装指定包 |
| `:MasonUpdate` | 更新 Mason 注册表 |
| `:MasonUpdateAll` | 更新所有已安装的包 |

### TreeSitter

| 快捷键 / 命令 | 功能 |
|---------------|------|
| `<leader>pt` | TreeSitter 安装信息 |
| `<leader>pT` | 更新 TreeSitter |
| `:TSInstall <lang>` | 安装语法解析器 |
| `:TSUpdate` | 更新所有解析器 |

### NormalNvim 发行版

| 快捷键 | 功能 |
|--------|------|
| `<leader>pD` | 更新发行版 |
| `<leader>pv` | 查看发行版版本 |
| `<leader>pc` | 查看更新日志 |

---

## 15. UI 开关与切换

> `<leader>u` 打开 UI 切换菜单 (which-key)
>
> 标注: `[g]` = 全局, `[w]` = 窗口级, `[b]` = Buffer 级

| 快捷键 | 功能 | 范围 |
|--------|------|------|
| `<leader>ua` | 切换自动括号补全 | [g] |
| `<leader>ub` | 切换深/浅色背景 | [g] |
| `<leader>uc` | 切换自动补全 | [g] |
| `<leader>uC` | 切换 CSS 颜色高亮 | [g] |
| `<leader>ud` | 切换 LSP 诊断 | [g] |
| `<leader>uf` | 切换自动格式化 (buffer) | [b] |
| `<leader>uF` | 切换自动格式化 (全局) | [g] |
| `<leader>ug` | 切换标记列 (signcolumn) | [w] |
| `<leader>uh` | 切换折叠列 (foldcolumn) | [w] |
| `<leader>uH` | 切换 LSP inlay hints | [b] |
| `<leader>ul` | 切换状态栏 | [*] |
| `<leader>uL` | 切换 CodeLens | [b] |
| `<leader>un` | 切换行号 | [w] |
| `<leader>uN` | 切换通知 | [g] |
| `<leader>uP` | 切换粘贴模式 | [g] |
| `<leader>up` | 切换 LSP 签名提示 | [g] |
| `<leader>us` | 切换拼写检查 | [w] |
| `<leader>uS` | 切换隐藏字符 (conceal) | [w] |
| `<leader>ut` | 切换标签栏 | [g] |
| `<leader>uT` | 设置缩进 (Tab 宽度) | [b] |
| `<leader>uu` | 切换 URL 下划线 | [g] |
| `<leader>uw` | 切换自动换行 | [w] |
| `<leader>uy` | 切换语法高亮 | [b] |
| `<leader>uz` | 切换 Zen Mode (沉浸模式) | [g] |
| `<leader>uA` | 切换动画效果 | [g] |

---

## 16. 代码折叠

使用 nvim-ufo 提供的增强折叠功能。

| 快捷键 | 功能 |
|--------|------|
| `zR` | 打开所有折叠 |
| `zM` | 关闭所有折叠 |
| `zr` | 减少折叠层级 |
| `zm` | 增加折叠层级 |
| `zp` | 预览折叠内容 |
| `zn` | 仅折叠注释 |
| `zN` | 仅折叠 region |

---

## 17. 会话管理

> `<leader>S` 打开会话菜单 (which-key)

| 快捷键 | 功能 |
|--------|------|
| `<leader>Sl` | 加载上次会话 |
| `<leader>Ss` | 保存当前会话 |
| `<leader>Sf` | 搜索会话 |
| `<leader>Sd` | 删除会话 |
| `<leader>S.` | 加载当前目录的会话 |

---

## 18. 配置文件地图

```
~/.config/nvim/
├── init.lua                          # 入口: 加载所有模块
├── lua/
│   ├── base/
│   │   ├── 1-options.lua             # Vim 选项 (leader键, 缩进, 主题等)
│   │   ├── 2-lazy.lua                # lazy.nvim 引导
│   │   ├── 3-autocmds.lua            # 自动命令
│   │   ├── 4-mappings.lua            # ★ 所有快捷键映射
│   │   ├── utils/
│   │   │   ├── init.lua              # 工具函数
│   │   │   └── ui.lua                # UI 切换函数
│   │   ├── icons/
│   │   │   ├── icons.lua             # Nerd Font 图标
│   │   │   └── fallback_icons.lua    # 无 Nerd Font 时的备选
│   │   └── health.lua                # :checkhealth 检查
│   ├── plugins/
│   │   ├── 1-base-behaviors.lua      # 基础行为插件 (文件树, 终端, 跳转等)
│   │   ├── 2-ui.lua                  # UI 插件 (主题, 状态栏, telescope等)
│   │   ├── 3-dev-core.lua            # 开发核心 (TreeSitter, LSP, 补全)
│   │   ├── 4-dev.lua                 # 开发工具 (Git, Debug, Test, AI)
│   │   └── 5-ai-enhance.lua          # ★ AI 增强 (avante, Claude Code, Java)
│   ├── dap-config.lua                # DAP 通用配置 (自定义)
│   ├── dap-java.lua                  # Java DAP 配置 (自定义)
│   └── dap-project.lua               # 项目级 DAP 配置
```

### 如何自定义

- **添加新插件**: 在 `plugins/` 下新建或编辑 Lua 文件，lazy.nvim 自动扫描
- **修改快捷键**: 编辑 `base/4-mappings.lua` 或在插件 config 中设置
- **修改选项**: 编辑 `base/1-options.lua`
- **切换主题**: `<leader>ft` 或修改 `1-options.lua` 中 `vim.g.default_colorscheme`

可用主题: `eldritch` (默认), `tokyonight`, `astrotheme`, `morta`

---

## 19. 常见问题

### 图标显示为方块/乱码

确保终端使用了 Nerd Font 字体。推荐 JetBrains Mono Nerd Font:
```bash
brew install --cask font-jetbrains-mono-nerd-font
```
然后在终端偏好设置中选择该字体。

### LSP 不工作

1. 运行 `:LspInfo` 检查当前 buffer 是否有 LSP 客户端
2. 运行 `:Mason` 确认对应语言服务已安装
3. 运行 `:LspRestart` 或 `<leader>lL` 重启 LSP
4. 运行 `:checkhealth` 查看整体健康状态

### Java LSP 启动慢

jdtls 首次启动需要索引项目，大项目可能需要几分钟。状态栏会显示进度。

### 调试器找不到

运行 `:Mason` 安装对应调试适配器，或在 `5-ai-enhance.lua` 的 `mason-nvim-dap` 的 `ensure_installed` 中添加。

### Avante 报错 API Key

设置环境变量:
```bash
export ANTHROPIC_API_KEY="sk-ant-api03-..."
```
添加到 `~/.zshrc` 使其持久化。

### 插件安装失败

```vim
:Lazy sync       " 重新同步所有插件
:Lazy clean      " 清理未使用的插件
:Lazy health     " 检查 lazy.nvim 健康
```

### 如何查看所有快捷键

1. 按住 `<Space>` 等待 which-key 弹出
2. `<leader>fk` 用 Telescope 搜索快捷键
3. 阅读本手册 :)
