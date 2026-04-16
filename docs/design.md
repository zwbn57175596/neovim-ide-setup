# Neovim IDE 开发环境自动化安装设计

## 概述

基于现有 NormalNvim 配置增强，生成一个自动化安装脚本 `setup-neovim-ide.sh`，支持**全新安装**和**增量升级**两种场景。最终目标是获得一个功能齐全的 IDE 级开发环境。

## 目标环境

- **平台**: macOS (ARM64)
- **编辑器**: Neovim 0.12+ (基于 NormalNvim 发行版)
- **插件管理**: lazy.nvim
- **核心语言**: Java, Node.js, Python
- **AI 辅助**: Claude Code CLI + avante.nvim

## 设计原则

1. **幂等性**: 脚本可重复运行，已安装组件自动跳过
2. **非破坏性**: 升级场景下备份现有配置再覆盖
3. **模块化**: 按功能分区安装，失败不影响其他模块
4. **可审查**: 每步操作有日志输出，用户可明确知道做了什么

---

## 架构分层

```
┌─────────────────────────────────────────────────────┐
│                  安装脚本 (Bash)                      │
├────────────┬──────────────┬──────────┬──────────────┤
│ 系统依赖层  │ 语言运行时层  │ Neovim层 │ 插件配置层    │
│ (Homebrew) │ (Java/Node/  │ (Neovim  │ (lazy.nvim   │
│            │  Python)     │  安装)   │  插件)        │
├────────────┼──────────────┼──────────┼──────────────┤
│ 工具链层    │ LSP/DAP 层   │ AI 集成层│ 验证层        │
│ (ripgrep/  │ (Mason 自动  │ (avante  │ (健康检查)     │
│  fd/fzf)   │  安装)       │  +claude)│              │
└────────────┴──────────────┴──────────┴──────────────┘
```

---

## 模块详细设计

### 模块 1: 系统依赖层

通过 Homebrew 安装（已安装则跳过）：

| 工具 | 用途 |
|------|------|
| neovim | 编辑器核心 (>= 0.10) |
| ripgrep (rg) | telescope 内容搜索 |
| fd | telescope 文件搜索 |
| fzf | 模糊搜索 |
| lazygit | Git TUI 客户端 |
| yazi | 文件管理器 |
| tree-sitter | 语法解析 CLI |
| wget / curl | 下载工具 |
| cmake | 编译 telescope-fzf-native |
| luarocks | Lua 包管理 |

### 模块 2: 语言运行时层

| 运行时 | 安装方式 | 版本 |
|--------|----------|------|
| Java 17 (Zulu) | brew install --cask zulu@17 | 17.x |
| Node.js | brew install node | >= 18 |
| Python 3 | brew install python3 | >= 3.10 |
| yarn | npm install -g yarn | latest |

### 模块 3: Neovim 配置层

**全新安装流程：**
1. `git clone` NormalNvim 到 `~/.config/nvim`
2. 写入自定义增强配置

**增量升级流程：**
1. 检测 `~/.config/nvim` 是否存在
2. 备份到 `~/.config/nvim.bak.YYYYMMDD-HHMMSS`
3. 在现有配置上追加/合并增强配置

### 模块 4: 插件增强配置

新增插件配置文件 `~/.config/nvim/lua/plugins/5-ai-enhance.lua`：

#### 4.1 avante.nvim (Cursor-like AI 体验)

```lua
{
  "yetone/avante.nvim",
  event = "VeryLazy",
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "echasnovski/mini.icons",
  },
  opts = {
    provider = "claude",
    claude = {
      model = "claude-sonnet-4-20250514",
      max_tokens = 4096,
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
    },
    windows = {
      position = "right",
      width = 30,
    },
  },
}
```

#### 4.2 Claude Code 终端集成

新增快捷键到 `4-mappings.lua`（或在 5-ai-enhance.lua 中配置）：

```lua
-- Claude Code AI 快捷键
vim.keymap.set("n", "<leader>ac", function()
  vim.cmd("ToggleTerm direction=float")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("claude\n", "t", false)
  end, 200)
end, { desc = "Claude Code (float)" })

vim.keymap.set("n", "<leader>av", function()
  vim.cmd("ToggleTerm size=80 direction=vertical")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("claude\n", "t", false)
  end, 200)
end, { desc = "Claude Code (vertical)" })
```

#### 4.3 Java 重构增强快捷键

在 5-ai-enhance.lua 中为 Java 文件添加重构快捷键：

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function(args)
    local bufnr = args.buf
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
    end

    map("<leader>jo", function() require("java").runner.built_in.run_app({}) end, "Run App")
    map("<leader>js", function() require("java").runner.built_in.stop_app() end, "Stop App")
    map("<leader>jt", function() require("java").test.run_current_method() end, "Test Method")
    map("<leader>jT", function() require("java").test.run_current_class() end, "Test Class")
    map("<leader>jd", function() require("java").test.debug_current_method() end, "Debug Test Method")
    map("<leader>jp", function() require("java").profile.ui() end, "Profile")
  end,
})
```

#### 4.4 Mason 自动安装 LSP/DAP

在 mason-lspconfig 配置中添加 `ensure_installed`：

```lua
-- 在 3-dev-core.lua 的 mason-lspconfig opts 中添加:
opts = {
  ensure_installed = {
    "lua_ls",       -- Lua
    "ts_ls",        -- TypeScript/JavaScript
    "pyright",      -- Python
    -- jdtls 由 nvim-java 管理，不在此处安装
  },
}
```

在 mason-nvim-dap 中添加 ensure_installed（4-dev.lua 已有依赖）：

```lua
-- mason-nvim-dap 配置:
{
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    ensure_installed = {
      "python",     -- debugpy
      "js",         -- js-debug-adapter
      "codelldb",   -- C/C++/Rust
      "bash",       -- bash-debug-adapter
    },
  },
}
```

### 模块 5: AI 集成层

| 组件 | 功能 | 集成方式 |
|------|------|----------|
| avante.nvim | AI 聊天 + 代码建议 + diff 预览 | lazy.nvim 插件 |
| Claude Code CLI | 完整 AI agent 功能 | toggleterm 内嵌终端 |
| copilot.lua | 行内代码补全 | 已有，保持不变 |

### 模块 6: 健康检查验证

脚本最后运行验证：

```bash
nvim --headless -c "checkhealth" -c "qa" 2>&1 | tee /tmp/nvim-healthcheck.log
```

并检查关键项：
- Neovim 版本 >= 0.10
- Node.js / Python / Java 可用
- ripgrep / fd 可用
- lazy.nvim 插件已安装
- Mason LSP servers 已安装

---

## 安装脚本结构

```bash
#!/bin/bash
# setup-neovim-ide.sh

# ── 颜色和工具函数 ──
# log_info, log_warn, log_error, check_cmd, ensure_brew_pkg

# ── 模块 1: 系统依赖 ──
install_system_deps()

# ── 模块 2: 语言运行时 ──
install_language_runtimes()

# ── 模块 3: Neovim 配置 ──
setup_neovim_config()          # clone NormalNvim 或备份现有

# ── 模块 4: 插件增强 ──
write_ai_enhance_plugin()      # 写入 5-ai-enhance.lua
patch_mason_ensure_installed()  # 追加 mason 自动安装

# ── 模块 5: Neovim 首次启动 ──
run_initial_setup()            # headless 模式安装插件 + Mason packages

# ── 模块 6: 验证 ──
run_health_check()

# ── 入口 ──
main()
```

---

## 快捷键速查表

### AI 相关
| 快捷键 | 功能 |
|--------|------|
| `<leader>aa` | 打开 avante 聊天 |
| `<leader>ae` | avante 编辑选中代码 |
| `<leader>ac` | Claude Code (浮动终端) |
| `<leader>av` | Claude Code (垂直分屏) |

### Java 开发
| 快捷键 | 功能 |
|--------|------|
| `<leader>jo` | Run App |
| `<leader>js` | Stop App |
| `<leader>jt` | Test Current Method |
| `<leader>jT` | Test Current Class |
| `<leader>jd` | Debug Test Method |
| `<leader>jp` | Profile UI |
| `<leader>la` | Code Action (重构菜单) |
| `<leader>lr` | Rename Symbol |
| `<leader>lf` | Format Buffer |

### 调试 (通用，已有)
| 快捷键 | 功能 |
|--------|------|
| `<F5>` | Start/Continue |
| `<F9>` | Toggle Breakpoint |
| `<F10>` | Step Over |
| `<F11>` | Step Into |
| `<S-F11>` | Step Out |
| `<leader>du` | Toggle Debug UI |

---

## 不做的事情

- **不替换现有配置结构**: 保持 NormalNvim 的 1-base, 2-ui, 3-dev-core, 4-dev 分层
- **不清理现有 DAP 配置**: 保留 dap-config.lua 和 dap-java.lua
- **不迁移插件管理器**: 继续使用 lazy.nvim
- **不添加过多插件**: 只增加必要的 avante.nvim，其余能力通过配置增强实现
