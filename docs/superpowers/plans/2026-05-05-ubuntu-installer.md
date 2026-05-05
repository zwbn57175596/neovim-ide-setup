# Ubuntu Installer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 macOS 安装脚本改名加后缀、新建 Ubuntu 版安装和清理脚本，并同步更新文档。

**Architecture:** 与 macOS 版保持相同的 11 模块线性结构；用 `apt` + GitHub Releases 二进制替代 brew；Neovim 使用官方 tarball（自动检测 x86_64 / arm64）。

**Tech Stack:** Bash, apt, curl, GNU sed, git, unzip, fc-cache

---

## 文件变更总览

| 操作 | 路径 |
|------|------|
| git mv | `setup-neovim-ide.sh` → `setup-neovim-ide-mac.sh` |
| git mv | `cleanup-neovim.sh` → `cleanup-neovim-mac.sh` |
| 新建 | `setup-neovim-ide-ubuntu.sh` |
| 新建 | `cleanup-neovim-ubuntu.sh` |
| 修改 | `CLAUDE.md` — 文件表格 + 架构标题 + 验证命令 + Ubuntu 章节 |
| 修改 | `README.md` — 快速开始命令 + 新增 Ubuntu 章节 |

---

## Task 1: 重命名 macOS 脚本 + 更新文档

**Files:**
- Rename: `setup-neovim-ide.sh` → `setup-neovim-ide-mac.sh`
- Rename: `cleanup-neovim.sh` → `cleanup-neovim-mac.sh`
- Modify: `CLAUDE.md`
- Modify: `README.md`

- [ ] **Step 1: git mv 两个文件**

```bash
git mv setup-neovim-ide.sh setup-neovim-ide-mac.sh
git mv cleanup-neovim.sh cleanup-neovim-mac.sh
```

- [ ] **Step 2: 更新 CLAUDE.md 文件表格和架构标题**

将 `CLAUDE.md` 中的文件结构表格从：
```
setup-neovim-ide.sh        # Main installer - macOS ARM64 (idempotent, ~600 lines)
cleanup-neovim.sh          # Full uninstall - macOS (destructive, requires confirmation)
```
改为：
```
setup-neovim-ide-mac.sh    # Main installer - macOS ARM64 (idempotent, ~600 lines)
setup-neovim-ide-ubuntu.sh # Main installer - Ubuntu Linux (idempotent)
cleanup-neovim-mac.sh      # Full uninstall - macOS (destructive, requires confirmation)
cleanup-neovim-ubuntu.sh   # Full uninstall - Ubuntu (destructive, requires confirmation)
```

将 `## Architecture: setup-neovim-ide.sh` 改为 `## Architecture: setup-neovim-ide-mac.sh`

将验证命令从：
```bash
rtk bash -n setup-neovim-ide.sh
```
改为：
```bash
rtk bash -n setup-neovim-ide-mac.sh
rtk bash -n setup-neovim-ide-ubuntu.sh
```

将 `When refactoring, always run \`rtk bash -n\` ...` 下方的命令名称同步更新。

在 CLAUDE.md 末尾 `## Windows 11 Scripts` 段落之前，新增：

```markdown
## Ubuntu Scripts (setup-neovim-ide-ubuntu.sh / cleanup-neovim-ubuntu.sh)

- Mirror the macOS version's 11-module structure in Bash
- Use apt as package manager + GitHub Releases binaries for lazygit, yazi, Neovim
- Neovim installed via official tarball to `~/.local/bin/nvim` (auto-detects x86_64 / arm64)
- Font installed manually via curl + fc-cache (no brew cask)
- `sed -i` (GNU sed syntax, no empty-string argument)
- Same Lua content as macOS version (embedded inline)
- Same patches as macOS version
```

- [ ] **Step 3: 更新 README.md**

将 `## 快速开始` 下的前提和安装命令替换为分平台章节：

```markdown
## 快速开始

### macOS ARM64 (Apple Silicon)

**前提：**
- 已安装 [Homebrew](https://brew.sh)
- 已设置 `ANTHROPIC_API_KEY`

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
- 已设置 `ANTHROPIC_API_KEY`
- 需要 `sudo` 权限（apt 操作）

```bash
bash setup-neovim-ide-ubuntu.sh
```

清理（完全卸载重装）：

```bash
bash cleanup-neovim-ubuntu.sh
```
```

同时更新 `## 安装后配置` 中的 JAVA_HOME 示例，macOS 保留 `/usr/libexec/java_home`，Ubuntu 注释改为：
```bash
# Ubuntu: export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

- [ ] **Step 4: 语法检查**

```bash
rtk bash -n setup-neovim-ide-mac.sh
```

Expected: 无输出（无语法错误）

- [ ] **Step 5: Commit**

```bash
git add setup-neovim-ide-mac.sh cleanup-neovim-mac.sh CLAUDE.md README.md
git commit -m "feat: rename macOS scripts to -mac suffix, update docs"
```

---

## Task 2: 创建 setup-neovim-ide-ubuntu.sh — 骨架 + Module 1

**Files:**
- Create: `setup-neovim-ide-ubuntu.sh`

- [ ] **Step 1: 创建文件，写入骨架 + Module 1**

创建 `setup-neovim-ide-ubuntu.sh`，内容如下（Module 1 完整代码）：

```bash
#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
log_section() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}▶ $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error()   { echo -e "${RED}✗ $1${NC}"; }
log_info()    { echo -e "${CYAN}ℹ $1${NC}"; }

# Prereq checks
for cmd in curl git unzip sudo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: '$cmd' is required but not installed. Please install it first."
    exit 1
  fi
done

# Header
clear
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║   Neovim IDE Setup Script (Ubuntu Linux)      ║
║   With AI Enhancement & Java Support          ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
log_info "Platform: Ubuntu Linux ($(uname -m))"
log_info "This script is idempotent and safe to run multiple times"
log_info "sudo is required for apt operations"

# ==============================================================================
# Module 1: System Dependencies
# ==============================================================================
log_section "Module 1: Installing System Dependencies"

# Ensure ~/.local/bin exists and is on PATH
mkdir -p "$HOME/.local/bin"
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  log_warning "~/.local/bin is not on PATH. Adding to shell rc files..."
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  [ -f "$HOME/.zshrc" ] && echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  export PATH="$HOME/.local/bin:$PATH"
  log_success "PATH updated"
fi

log_info "Updating apt package index..."
sudo apt update -qq

# Core apt packages
for pkg in ripgrep fzf cmake luarocks wget curl unzip git; do
  if dpkg -l "$pkg" &> /dev/null 2>&1; then
    log_success "$pkg already installed"
  else
    log_info "Installing $pkg..."
    sudo apt install -y "$pkg"
    log_success "$pkg installed"
  fi
done

# fd-find (binary name is fdfind on Ubuntu)
if dpkg -l fd-find &> /dev/null 2>&1; then
  log_success "fd-find already installed"
else
  log_info "Installing fd-find..."
  sudo apt install -y fd-find
  log_success "fd-find installed"
fi
if [ ! -f "$HOME/.local/bin/fd" ]; then
  ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
  log_success "Created symlink: fd -> fdfind"
fi

# Neovim (official tarball — apt version is too old)
NVIM_BIN="$HOME/.local/bin/nvim"
if [ -f "$NVIM_BIN" ]; then
  log_success "Neovim already installed at $NVIM_BIN"
else
  log_info "Installing Neovim (latest release tarball)..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    NVIM_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    NVIM_ARCH="arm64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
  log_info "Downloading $NVIM_URL ..."
  curl -L "$NVIM_URL" -o /tmp/nvim-linux.tar.gz
  tar -xzf /tmp/nvim-linux.tar.gz -C /tmp/
  mv "/tmp/nvim-linux-${NVIM_ARCH}/bin/nvim" "$NVIM_BIN"
  chmod +x "$NVIM_BIN"
  rm -rf "/tmp/nvim-linux-${NVIM_ARCH}" /tmp/nvim-linux.tar.gz
  log_success "Neovim installed to $NVIM_BIN"
fi

# lazygit (GitHub Releases)
LAZYGIT_BIN="$HOME/.local/bin/lazygit"
if [ -f "$LAZYGIT_BIN" ]; then
  log_success "lazygit already installed"
else
  log_info "Installing lazygit..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    LG_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    LG_ARCH="arm64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  LG_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_Linux_${LG_ARCH}.tar.gz"
  curl -L "$LG_URL" -o /tmp/lazygit.tar.gz
  tar -xzf /tmp/lazygit.tar.gz -C /tmp/ lazygit
  mv /tmp/lazygit "$LAZYGIT_BIN"
  chmod +x "$LAZYGIT_BIN"
  rm /tmp/lazygit.tar.gz
  log_success "lazygit installed"
fi

# yazi (GitHub Releases)
YAZI_BIN="$HOME/.local/bin/yazi"
if [ -f "$YAZI_BIN" ]; then
  log_success "yazi already installed"
else
  log_info "Installing yazi..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    YZ_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    YZ_ARCH="aarch64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  YZ_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YZ_ARCH}-unknown-linux-gnu.zip"
  curl -L "$YZ_URL" -o /tmp/yazi.zip
  mkdir -p /tmp/yazi-extract
  unzip -o /tmp/yazi.zip -d /tmp/yazi-extract/
  mv "/tmp/yazi-extract/yazi-${YZ_ARCH}-unknown-linux-gnu/yazi" "$YAZI_BIN"
  chmod +x "$YAZI_BIN"
  rm -rf /tmp/yazi.zip /tmp/yazi-extract
  log_success "yazi installed"
fi
```

- [ ] **Step 2: 语法检查**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
```

Expected: 无输出

- [ ] **Step 3: Commit**

```bash
git add setup-neovim-ide-ubuntu.sh
git commit -m "feat(ubuntu): add script skeleton + Module 1 system deps"
```

---

## Task 3: Module 2 (Language Runtimes) + Module 3 (Nerd Font)

**Files:**
- Modify: `setup-neovim-ide-ubuntu.sh` (追加)

- [ ] **Step 1: 追加 Module 2 和 Module 3**

在 `setup-neovim-ide-ubuntu.sh` 末尾追加：

```bash

# ==============================================================================
# Module 2: Language Runtimes
# ==============================================================================
log_section "Module 2: Setting Up Language Runtimes"

# Java (project JDK — read from environment, not hardcoded)
log_info "Checking Java environment..."
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA_VER=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F'"' '/version/{print $2}')
  log_success "JAVA_HOME is set → $JAVA_HOME (Java $JAVA_VER)"
elif command -v java &> /dev/null; then
  JAVA_VER=$(java -version 2>&1 | awk -F'"' '/version/{print $2}')
  log_success "java found in PATH (Java $JAVA_VER) — JAVA_HOME not set"
  log_warning "Consider adding to ~/.bashrc: export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
else
  log_warning "No Java found in PATH or JAVA_HOME"
  log_warning "Install a JDK for your project and set JAVA_HOME."
  log_warning "Example (OpenJDK 17):  sudo apt install openjdk-17-jdk"
  log_warning "Then add to ~/.bashrc: export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
  log_info "Note: nvim-java will auto-download a separate JDK for JDTLS — no manual action needed."
fi

# Node.js (via NodeSource — Ubuntu apt ships outdated versions)
log_info "Setting up Node.js..."
if command -v node &> /dev/null; then
  log_success "Node.js already installed"
else
  log_info "Installing Node.js via NodeSource (LTS)..."
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
  log_success "Node.js installed"
fi

# tree-sitter-cli (requires npm, installed after Node above)
log_info "Setting up tree-sitter-cli..."
if command -v tree-sitter &> /dev/null; then
  log_success "tree-sitter-cli already installed"
else
  log_info "Installing tree-sitter-cli via npm..."
  npm install -g tree-sitter-cli
  log_success "tree-sitter-cli installed"
fi

# Python 3
log_info "Setting up Python 3..."
if command -v python3 &> /dev/null; then
  log_success "Python 3 already installed"
else
  log_info "Installing Python 3..."
  sudo apt install -y python3 python3-pip
  log_success "Python 3 installed"
fi

# Yarn
log_info "Setting up yarn..."
if command -v yarn &> /dev/null; then
  log_success "Yarn already installed"
else
  log_info "Installing yarn globally..."
  npm install -g yarn
  log_success "Yarn installed"
fi

# ==============================================================================
# Module 3: Nerd Font
# ==============================================================================
log_section "Module 3: Installing Nerd Font"

FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
if [ -d "$FONT_DIR" ] && ls "$FONT_DIR"/*.ttf &> /dev/null 2>&1; then
  log_success "JetBrainsMono Nerd Font already installed"
else
  log_info "Downloading JetBrainsMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
    -o /tmp/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR/"
  rm /tmp/JetBrainsMono.zip
  fc-cache -fv
  log_success "JetBrainsMono Nerd Font installed"
fi
```

- [ ] **Step 2: 语法检查**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
```

Expected: 无输出

- [ ] **Step 3: Commit**

```bash
git add setup-neovim-ide-ubuntu.sh
git commit -m "feat(ubuntu): add Module 2 language runtimes + Module 3 nerd font"
```

---

## Task 4: Module 4 (Neovim Config) + Module 5 (5-ai-enhance.lua)

**Files:**
- Modify: `setup-neovim-ide-ubuntu.sh` (追加)

- [ ] **Step 1: 追加 Module 4**

在 `setup-neovim-ide-ubuntu.sh` 末尾追加：

```bash

# ==============================================================================
# Module 4: Neovim Configuration
# ==============================================================================
log_section "Module 4: Setting Up Neovim Configuration"

NVIM_CONFIG_DIR="$HOME/.config/nvim"
BACKUP_TIMESTAMP=$(date +%Y%m%d-%H%M%S)

if [ -d "$NVIM_CONFIG_DIR" ]; then
  log_warning "Found existing Neovim config at $NVIM_CONFIG_DIR"
  BACKUP_DIR="$HOME/.config/nvim.bak.${BACKUP_TIMESTAMP}"
  log_info "Backing up to $BACKUP_DIR..."
  cp -r "$NVIM_CONFIG_DIR" "$BACKUP_DIR"
  log_success "Backup created at $BACKUP_DIR"
else
  log_info "Cloning NormalNvim configuration..."
  git clone https://github.com/NormalNvim/NormalNvim.git "$NVIM_CONFIG_DIR"
  log_success "NormalNvim cloned to $NVIM_CONFIG_DIR"
fi
```

- [ ] **Step 2: 追加 Module 5（完整 Lua heredoc）**

在 `setup-neovim-ide-ubuntu.sh` 末尾追加（内容与 macOS 版完全相同）：

```bash

# ==============================================================================
# Module 5: Write 5-ai-enhance.lua
# ==============================================================================
log_section "Module 5: Writing AI Enhancement Configuration"

PLUGINS_DIR="$NVIM_CONFIG_DIR/lua/plugins"
mkdir -p "$PLUGINS_DIR"

AI_ENHANCE_FILE="$PLUGINS_DIR/5-ai-enhance.lua"

log_info "Creating $AI_ENHANCE_FILE..."

cat > "$AI_ENHANCE_FILE" << 'LUAEOF'
-- AI & IDE Enhancement
local utils = require("base.utils")
local is_available = utils.is_available

return {

  -- FIX: vim-matchup treesitter broken on Neovim 0.12
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      matchup = {
        enable = false,
      },
    },
  },

  -- avante.nvim
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000,
          extra_request_body = {
            temperature = 0.7,
            max_tokens = 8192,
          },
        },
      },
      behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
      },
      windows = {
        position = "right",
        width = 35,
        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },
    },
  },

  -- mason-lspconfig ensure_installed
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "pyright",
      },
    },
  },

  -- mason-nvim-dap ensure_installed
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      ensure_installed = {
        "python",
        "js",
        "codelldb",
        "bash",
      },
    },
  },

  -- Keymaps (Claude Code + Java + which-key)
  {
    dir = vim.fn.stdpath("config"),
    name = "ai-enhance-keymaps",
    lazy = false,
    config = function()
      -- ── Keep DAP UI open after program exits ────────────────────────────
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(args)
          if args.data == "nvim-dap-ui" then
            vim.schedule(function()
              local ok, dap = pcall(require, "dap")
              if ok then
                dap.listeners.before.event_terminated["dapui_config"] = nil
                dap.listeners.before.event_exited["dapui_config"] = nil
              end
            end)
            return true
          end
        end,
      })

      -- ── Fix: jdtls not starting on first Java file open ───────────────
      vim.lsp.enable("jdtls")

      -- ── Auto-register Java DAP config when jdtls attaches ─────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        once = true,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "jdtls" then return true end
          local java_ok, java = pcall(require, "java")
          if not java_ok or not java.dap then return end
          local attempts = 0
          local function try_config_dap()
            attempts = attempts + 1
            local cmds = vim.tbl_get(client, "server_capabilities", "executeCommandProvider", "commands") or {}
            for _, cmd in ipairs(cmds) do
              if cmd == "vscode.java.resolveMainClass" then
                java.dap.config_dap()
                local vscode_ok, vscode = pcall(require, "dap.ext.vscode")
                if vscode_ok then vscode.load_launchjs(nil, { java = { "java" } }) end
                return
              end
            end
            if attempts < 20 then vim.defer_fn(try_config_dap, 500) end
          end
          try_config_dap()
        end,
      })

      -- Claude Code float terminal
      vim.keymap.set("n", "<leader>ac", function()
        if not is_available("toggleterm.nvim") then
          vim.notify("toggleterm.nvim not available", vim.log.levels.WARN)
          return
        end
        local Terminal = require("toggleterm.terminal").Terminal
        local claude_float = Terminal:new({
          cmd = "claude",
          direction = "float",
          float_opts = {
            border = "rounded",
            width = function() return math.floor(vim.o.columns * 0.85) end,
            height = function() return math.floor(vim.o.lines * 0.85) end,
          },
          on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
          end,
        })
        claude_float:toggle()
      end, { desc = "Claude Code (float)" })

      -- Claude Code vertical terminal
      vim.keymap.set("n", "<leader>av", function()
        if not is_available("toggleterm.nvim") then
          vim.notify("toggleterm.nvim not available", vim.log.levels.WARN)
          return
        end
        local Terminal = require("toggleterm.terminal").Terminal
        local claude_vsplit = Terminal:new({
          cmd = "claude",
          direction = "vertical",
          size = function() return math.floor(vim.o.columns * 0.4) end,
          on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<Esc>", "<C-\\><C-n>", { noremap = true })
          end,
        })
        claude_vsplit:toggle()
      end, { desc = "Claude Code (vertical)" })

      -- Java keymaps
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Java IDE keymaps",
        pattern = "java",
        callback = function(args)
          local bufnr = args.buf
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Java: " .. desc })
          end
          map("<leader>jo", function()
            local ok, java = pcall(require, "java")
            if ok and java.runner then java.runner.built_in.run_app({})
            else vim.notify("nvim-java runner not available", vim.log.levels.WARN) end
          end, "Run App")
          map("<leader>js", function()
            local ok, java = pcall(require, "java")
            if ok and java.runner then java.runner.built_in.stop_app()
            else vim.notify("nvim-java runner not available", vim.log.levels.WARN) end
          end, "Stop App")
          map("<leader>jt", function()
            local ok, java = pcall(require, "java")
            if ok and java.test then java.test.run_current_method()
            else vim.notify("nvim-java test not available", vim.log.levels.WARN) end
          end, "Test Method")
          map("<leader>jT", function()
            local ok, java = pcall(require, "java")
            if ok and java.test then java.test.run_current_class()
            else vim.notify("nvim-java test not available", vim.log.levels.WARN) end
          end, "Test Class")
          map("<leader>jD", function()
            local ok, java = pcall(require, "java")
            if not ok or not java.dap then
              vim.notify("nvim-java dap not available", vim.log.levels.WARN)
              return
            end
            local attempts = 0
            local function try_config_dap()
              attempts = attempts + 1
              local client = vim.lsp.get_clients({ name = "jdtls", bufnr = 0 })[1]
              if client then
                local cmds = vim.tbl_get(client, "server_capabilities", "executeCommandProvider", "commands") or {}
                for _, cmd in ipairs(cmds) do
                  if cmd == "vscode.java.resolveMainClass" then
                    java.dap.config_dap()
                    return
                  end
                end
              end
              if attempts >= 20 then
                vim.notify("Timed out waiting for java-debug extension (10s)", vim.log.levels.WARN)
                return
              end
              vim.defer_fn(try_config_dap, 500)
            end
            vim.notify("Waiting for java-debug extension...", vim.log.levels.INFO)
            try_config_dap()
          end, "Config DAP (debug app)")
          map("<leader>jd", function()
            local ok, java = pcall(require, "java")
            if ok and java.test then java.test.debug_current_method()
            else vim.notify("nvim-java test not available", vim.log.levels.WARN) end
          end, "Debug Test Method")
          map("<leader>jp", function()
            local ok, java = pcall(require, "java")
            if ok and java.profile then java.profile.ui()
            else vim.notify("nvim-java profile not available", vim.log.levels.WARN) end
          end, "Profile")
        end,
      })

      -- which-key groups
      vim.api.nvim_create_autocmd("User", {
        pattern = "BaseDefered",
        once = true,
        callback = function()
          local wk_ok, wk = pcall(require, "which-key")
          if wk_ok then
            wk.add({
              { "<leader>a", group = " AI" },
              { "<leader>j", group = " Java" },
            })
          end
        end,
      })
    end,
  },

}
LUAEOF

log_success "AI enhancement configuration written to $AI_ENHANCE_FILE"
```

- [ ] **Step 3: 语法检查**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
```

Expected: 无输出

- [ ] **Step 4: Commit**

```bash
git add setup-neovim-ide-ubuntu.sh
git commit -m "feat(ubuntu): add Module 4 neovim config + Module 5 ai-enhance lua"
```

---

## Task 5: Module 6 (Plugin Install) + Module 7 (Patches)

**Files:**
- Modify: `setup-neovim-ide-ubuntu.sh` (追加)

- [ ] **Step 1: 追加 Module 6 和 Module 7**

在 `setup-neovim-ide-ubuntu.sh` 末尾追加：

```bash

# ==============================================================================
# Module 6: First Launch - Install Plugins
# ==============================================================================
log_section "Module 6: Installing Lazy Plugins (Headless)"

log_info "Launching Neovim to install plugins (this may take a moment)..."
timeout 300 nvim --headless "+Lazy! sync" +qa 2>&1 | tail -10 || true
log_success "Plugin installation completed"

# ==============================================================================
# Module 7: Patch aerial.nvim and nvim-treesitter for Neovim 0.12 Compatibility
# ==============================================================================
log_section "Module 7: Patching for Neovim 0.12 Compatibility"

AERIAL_HELPERS="$HOME/.local/share/nvim/lazy/aerial.nvim/lua/aerial/backends/treesitter/helpers.lua"

if [ -f "$AERIAL_HELPERS" ]; then
  log_info "Patching aerial.nvim helpers.lua..."

  # Patch: node:start() -> node:range()
  sed -i 's/local row, col = start_node:start()/local row, col = start_node:range()/' "$AERIAL_HELPERS"
  log_success "Patched node:start() -> node:range()"

  # Patch: node:end_() -> node:range()
  sed -i 's/local end_row, end_col = end_node:end_()/local _, _, end_row, end_col = end_node:range()/' "$AERIAL_HELPERS"
  log_success "Patched node:end_() -> node:range()"
else
  log_warning "aerial.nvim not found at $AERIAL_HELPERS (may not be installed yet)"
fi

# Patch: nvim-treesitter query_predicates.lua for Neovim 0.12.1
QUERY_PREDICATES="$HOME/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua"
if [ -f "$QUERY_PREDICATES" ]; then
  if grep -q 'vim.treesitter.get_node_text(node, bufnr):lower()' "$QUERY_PREDICATES"; then
    log_info "Patching nvim-treesitter query_predicates.lua..."
    sed -i \
      's/local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()/local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)\n  if not ok or not text then return end\n  local injection_alias = text:lower()/' \
      "$QUERY_PREDICATES"
    log_success "Patched query_predicates.lua get_node_text nil guard"
  else
    log_info "query_predicates.lua already patched, skipping"
  fi
else
  log_warning "nvim-treesitter query_predicates.lua not found"
fi
```

- [ ] **Step 2: 语法检查**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
```

Expected: 无输出

- [ ] **Step 3: Commit**

```bash
git add setup-neovim-ide-ubuntu.sh
git commit -m "feat(ubuntu): add Module 6 plugin install + Module 7 patches"
```

---

## Task 6: Modules 8-11 (TreeSitter、Mason、Health、Summary)

**Files:**
- Modify: `setup-neovim-ide-ubuntu.sh` (追加)

- [ ] **Step 1: 追加 Modules 8-11**

在 `setup-neovim-ide-ubuntu.sh` 末尾追加：

```bash

# ==============================================================================
# Module 8: TreeSitter Parser Installation (Interactive)
# ==============================================================================
log_section "Module 8: TreeSitter Parser Installation"

echo -e "${CYAN}Please manually install TreeSitter parsers in Neovim:${NC}"
echo ""
echo -e "${YELLOW}Run this command in Neovim:${NC}"
echo -e "${BLUE}:TSInstall java javascript typescript python lua bash json yaml toml html css markdown${NC}"
echo ""
echo -e "${YELLOW}Or execute in terminal:${NC}"
echo -e "${BLUE}nvim -c \"TSInstall java javascript typescript python lua bash json yaml toml html css markdown\" -c qa${NC}"
echo ""
read -p "Press Enter after installing TreeSitter parsers... "

# ==============================================================================
# Module 9: Mason Installation
# ==============================================================================
log_section "Module 9: Installing Mason Tools"

log_info "Installing LSP servers and debug adapters via Mason..."
timeout 300 nvim --headless \
  -c "MasonInstall lua-language-server typescript-language-server pyright jdtls java-debug-adapter java-test debugpy js-debug-adapter codelldb bash-debug-adapter lombok-nightly spring-boot-tools" \
  -c "sleep 30" \
  -c "qa" 2>&1 | tail -5 || true

log_success "Mason installation completed"

# ==============================================================================
# Module 10: Health Check
# ==============================================================================
log_section "Module 10: Health Check"

log_info "Running Neovim health check..."
echo ""

HEALTH_OUTPUT=$(timeout 60 nvim --headless -c "checkhealth" -c "qa" 2>&1 || true)
ERRORS=$(echo "$HEALTH_OUTPUT" | grep -E "ERROR|WARNING|error|warning" | grep -v "^$" | head -20 || true)

if [ -z "$ERRORS" ]; then
  log_success "Health check passed - no errors detected"
else
  echo "$ERRORS"
fi

# ==============================================================================
# Module 11: Summary and Quick Reference
# ==============================================================================
log_section "Module 11: Setup Complete!"

echo -e "${GREEN}✓ Neovim IDE setup completed successfully!${NC}\n"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Quick Reference - Keyboard Shortcuts:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "${YELLOW}AI Shortcuts (Claude Code):${NC}"
echo -e "  ${BLUE}<leader>ac${NC}  - Open Claude Code in float window"
echo -e "  ${BLUE}<leader>av${NC}  - Open Claude Code in vertical split\n"

echo -e "${YELLOW}Java Development:${NC}"
echo -e "  ${BLUE}<leader>jo${NC}  - Run Java Application"
echo -e "  ${BLUE}<leader>js${NC}  - Stop Java Application"
echo -e "  ${BLUE}<leader>jt${NC}  - Test Current Method"
echo -e "  ${BLUE}<leader>jT${NC}  - Test Current Class"
echo -e "  ${BLUE}<leader>jD${NC}  - Config DAP (debug regular app, then <F5>)"
echo -e "  ${BLUE}<leader>jd${NC}  - Debug Test Method"
echo -e "  ${BLUE}<leader>jp${NC}  - Open Java Profiler\n"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Configuration Files:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "  ${BLUE}Main Config:${NC}       $NVIM_CONFIG_DIR/init.lua"
echo -e "  ${BLUE}AI Enhancement:${NC}   $AI_ENHANCE_FILE"
echo -e "  ${BLUE}Backup Location:${NC}  $HOME/.config/nvim.bak.*\n"

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

echo -e "  1. Set your Anthropic API key:"
echo -e "     ${BLUE}export ANTHROPIC_API_KEY='your-key-here'${NC}\n"

echo -e "  2. Set JAVA_HOME to your project's JDK (any version):"
echo -e "     ${BLUE}sudo apt install openjdk-17-jdk${NC}"
echo -e "     ${BLUE}export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64${NC}"
echo -e "     Add to ~/.bashrc to persist across sessions."
echo -e "     ${CYAN}Note: nvim-java auto-manages a separate JDK for JDTLS —${NC}"
echo -e "     ${CYAN}JAVA_HOME only affects your project compile/run toolchain.${NC}\n"

echo -e "  3. Java debug workflow:"
echo -e "     ${BLUE}<leader>jD${NC}  Config DAP  →  ${BLUE}<F9>${NC}  Set breakpoint  →  ${BLUE}<F5>${NC}  Start debug\n"

echo -e "  4. Launch Neovim:"
echo -e "     ${BLUE}nvim${NC}\n"

echo -e "  5. Verify setup with health check:"
echo -e "     ${BLUE}:checkhealth${NC}\n"

echo -e "  6. Install additional TreeSitter parsers as needed:"
echo -e "     ${BLUE}:TSInstall <language>${NC}\n"

echo -e "${GREEN}Happy coding!${NC}\n"

exit 0
```

- [ ] **Step 2: 语法检查**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
```

Expected: 无输出

- [ ] **Step 3: Commit**

```bash
git add setup-neovim-ide-ubuntu.sh
git commit -m "feat(ubuntu): add Modules 8-11 treesitter/mason/health/summary"
```

---

## Task 7: 创建 cleanup-neovim-ubuntu.sh

**Files:**
- Create: `cleanup-neovim-ubuntu.sh`

- [ ] **Step 1: 创建清理脚本**

创建 `cleanup-neovim-ubuntu.sh`，内容：

```bash
#!/bin/bash
# cleanup-neovim-ubuntu.sh
# 完全清理 Ubuntu 上的 Neovim 配置、插件、缓存和二进制

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

echo ""
echo "══════════════════════════════════════════"
echo "  Neovim 完全清理脚本 (Ubuntu)"
echo "══════════════════════════════════════════"
echo ""
log_warn "即将删除以下目录和文件："
echo "  ~/.config/nvim                          (配置)"
echo "  ~/.local/share/nvim                     (插件/Mason/数据)"
echo "  ~/.local/state/nvim                     (状态/日志)"
echo "  ~/.cache/nvim                           (缓存)"
echo "  ~/.local/bin/nvim                       (Neovim 二进制)"
echo "  ~/.local/bin/lazygit                    (lazygit 二进制)"
echo "  ~/.local/bin/yazi                       (yazi 二进制)"
echo "  ~/.local/share/fonts/JetBrainsMonoNerd  (Nerd Font)"
echo ""
log_warn "备份目录 (~/.config/nvim.bak.*) 不会被删除。"
log_warn "通过 apt 安装的包 (ripgrep, fzf 等) 不会被删除。"
echo ""
read -p "确认删除？(输入 yes 继续): " confirm
if [ "$confirm" != "yes" ]; then
  log_warn "已取消。"
  exit 0
fi

echo ""

remove_if_exists() {
  if [ -e "$1" ]; then
    rm -rf "$1"
    echo -e "${GREEN}[INFO]${NC}  已删除 $1"
  else
    echo -e "${YELLOW}[WARN]${NC}  $1 不存在，跳过"
  fi
}

remove_if_exists "$HOME/.config/nvim"
remove_if_exists "$HOME/.local/share/nvim"
remove_if_exists "$HOME/.local/state/nvim"
remove_if_exists "$HOME/.cache/nvim"
remove_if_exists "$HOME/.local/bin/nvim"
remove_if_exists "$HOME/.local/bin/lazygit"
remove_if_exists "$HOME/.local/bin/yazi"
remove_if_exists "$HOME/.local/share/fonts/JetBrainsMonoNerd"

# 刷新字体缓存
if command -v fc-cache &> /dev/null; then
  fc-cache -fv &> /dev/null
fi

echo ""
echo "══════════════════════════════════════════"
log_info "清理完成！"
echo ""
echo "重新安装："
echo "  bash setup-neovim-ide-ubuntu.sh"
echo "══════════════════════════════════════════"
echo ""
```

- [ ] **Step 2: 语法检查两个脚本**

```bash
rtk bash -n setup-neovim-ide-ubuntu.sh
rtk bash -n cleanup-neovim-ubuntu.sh
```

Expected: 两个均无输出

- [ ] **Step 3: 同时检查 macOS 改名后的脚本**

```bash
rtk bash -n setup-neovim-ide-mac.sh
rtk bash -n cleanup-neovim-mac.sh
```

Expected: 两个均无输出

- [ ] **Step 4: Commit**

```bash
git add cleanup-neovim-ubuntu.sh
git commit -m "feat(ubuntu): add cleanup script"
```

---

## Task 8: 最终检查 + 收尾

**Files:**
- 无代码改动，仅验证

- [ ] **Step 1: 确认四个脚本均可语法检查通过**

```bash
rtk bash -n setup-neovim-ide-mac.sh && echo "mac setup OK"
rtk bash -n cleanup-neovim-mac.sh   && echo "mac cleanup OK"
rtk bash -n setup-neovim-ide-ubuntu.sh && echo "ubuntu setup OK"
rtk bash -n cleanup-neovim-ubuntu.sh   && echo "ubuntu cleanup OK"
```

Expected:
```
mac setup OK
mac cleanup OK
ubuntu setup OK
ubuntu cleanup OK
```

- [ ] **Step 2: 确认文件均已存在**

```bash
ls -la setup-neovim-ide-mac.sh setup-neovim-ide-ubuntu.sh \
        cleanup-neovim-mac.sh cleanup-neovim-ubuntu.sh
```

Expected: 四个文件均存在，ubuntu 脚本约 600 行

- [ ] **Step 3: 确认 setup-neovim-ide.sh 原名不再存在**

```bash
ls setup-neovim-ide.sh 2>/dev/null && echo "ERROR: old name still exists" || echo "OK: old name removed"
```

Expected: `OK: old name removed`

- [ ] **Step 4: 最终 Commit（如有任何漏项）**

```bash
git status
# 若有未提交内容：
git add -p
git commit -m "chore(ubuntu): finalize ubuntu installer implementation"
```
