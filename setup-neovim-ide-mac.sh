#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
log_section() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}▶ $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

log_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

log_error() {
  echo -e "${RED}✗ $1${NC}"
}

log_info() {
  echo -e "${CYAN}ℹ $1${NC}"
}

check_installed() {
  if command -v "$1" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

brew_install() {
  local package=$1
  local is_cask=$2

  if [ "$is_cask" = "cask" ]; then
    if brew list --cask "$package" &> /dev/null 2>&1; then
      log_success "$package already installed"
    else
      log_info "Installing $package (cask)..."
      brew install --cask "$package"
      log_success "$package installed"
    fi
  else
    if brew list "$package" &> /dev/null 2>&1; then
      log_success "$package already installed"
    else
      log_info "Installing $package..."
      brew install "$package"
      log_success "$package installed"
    fi
  fi
}

# Header
clear
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║   Neovim IDE Setup Script (macOS ARM64)       ║
║   With AI Enhancement & Java Support          ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
log_info "Platform: macOS ARM64"
log_info "This script is idempotent and safe to run multiple times"

# ==============================================================================
# Module 1: System Dependencies
# ==============================================================================
log_section "Module 1: Installing System Dependencies"

brew_install neovim
brew_install ripgrep
brew_install fd
brew_install fzf
brew_install lazygit
brew_install yazi
brew_install tree-sitter
brew_install cmake
brew_install luarocks
brew_install wget

# ==============================================================================
# Module 2: Language Runtimes
# ==============================================================================
log_section "Module 2: Setting Up Language Runtimes"

# Java (project JDK — read from environment, not hardcoded)
# nvim-java manages its own JDK for running JDTLS (via jdk.auto_install).
# JAVA_HOME here only affects your project's compile/run toolchain.
log_info "Checking Java environment..."
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/java" ]; then
  JAVA_VER=$("$JAVA_HOME/bin/java" -version 2>&1 | awk -F'"' '/version/{print $2}')
  log_success "JAVA_HOME is set → $JAVA_HOME (Java $JAVA_VER)"
elif check_installed java; then
  JAVA_VER=$(java -version 2>&1 | awk -F'"' '/version/{print $2}')
  log_success "java found in PATH (Java $JAVA_VER) — JAVA_HOME not set"
  log_warning "Consider adding to ~/.zshrc: export JAVA_HOME=\$(/usr/libexec/java_home)"
else
  log_warning "No Java found in PATH or JAVA_HOME"
  log_warning "Install a JDK for your project and set JAVA_HOME."
  log_warning "Example (Zulu 17):  brew install --cask zulu@17"
  log_warning "Example (Zulu 21):  brew install --cask zulu@21"
  log_warning "Then add to ~/.zshrc: export JAVA_HOME=\$(/usr/libexec/java_home -v 17)"
  log_info "Note: nvim-java will auto-download a separate JDK for JDTLS — no manual action needed."
fi

# Node.js
log_info "Setting up Node.js..."
if check_installed node; then
  log_success "Node.js already installed"
else
  log_info "Installing Node.js..."
  brew install node
  log_success "Node.js installed"
fi

# Python 3
log_info "Setting up Python 3..."
if check_installed python3; then
  log_success "Python 3 already installed"
else
  log_info "Installing Python 3..."
  brew install python3
  log_success "Python 3 installed"
fi

# Yarn
log_info "Setting up yarn..."
if check_installed yarn; then
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

brew_install font-jetbrains-mono-nerd-font cask

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
    init = function()
      -- avante log.lua rejects vim.log.levels.WARN (3); remap to INFO before plugin loads
      if vim.log.level == vim.log.levels.WARN then
        vim.log.level = vim.log.levels.INFO
      end
    end,
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
      -- 4-dev.lua auto-closes dapui on event_terminated/event_exited,
      -- which hides console output. Override after dapui finishes setup.
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyLoad",
        callback = function(args)
          if args.data == "nvim-dap-ui" then
            -- vim.schedule: run after the plugin's config function completes
            vim.schedule(function()
              local ok, dap = pcall(require, "dap")
              if ok then
                dap.listeners.before.event_terminated["dapui_config"] = nil
                dap.listeners.before.event_exited["dapui_config"] = nil
              end
            end)
            return true -- remove this autocmd
          end
        end,
      })

      -- ── Fix: jdtls not starting on first Java file open ───────────────
      -- nvim-java lazy-loads on ft=java, but by the time it calls
      -- lspconfig.jdtls.setup(), the current buffer's FileType event has
      -- already fired. vim.lsp.enable() (Neovim 0.12+) attaches jdtls to
      -- all matching buffers immediately, bypassing the autocmd race.
      vim.lsp.enable("jdtls")

      -- ── Auto-register Java DAP config when jdtls attaches ─────────────
      vim.api.nvim_create_autocmd("LspAttach", {
        once = true,
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "jdtls" then return true end -- retry for next attach
          local java_ok, java = pcall(require, "java")
          if not java_ok or not java.dap then return end
          -- Poll until java-debug extension registers its commands
          local attempts = 0
          local function try_config_dap()
            attempts = attempts + 1
            local cmds = vim.tbl_get(client, "server_capabilities", "executeCommandProvider", "commands") or {}
            for _, cmd in ipairs(cmds) do
              if cmd == "vscode.java.resolveMainClass" then
                java.dap.config_dap()
                -- Also load .vscode/launch.json if present
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
            -- Wait for java-debug extension to register its command handlers
            -- before calling config_dap(), otherwise get "No delegateCommandHandler"
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

# ==============================================================================
# Module 6: First Launch - Install Plugins
# ==============================================================================
log_section "Module 6: Installing Lazy Plugins (Headless)"

log_info "Launching Neovim to install plugins (this may take a moment)..."
timeout 300 nvim --headless "+Lazy! sync" +qa 2>&1 | tail -10 || true
log_success "Plugin installation completed"

# ==============================================================================
# Module 7: Patch aerial.nvim for Neovim 0.12 Compatibility
# ==============================================================================
log_section "Module 7: Patching aerial.nvim for Neovim 0.12 Compatibility"

AERIAL_HELPERS="$HOME/.local/share/nvim/lazy/aerial.nvim/lua/aerial/backends/treesitter/helpers.lua"

if [ -f "$AERIAL_HELPERS" ]; then
  log_info "Patching aerial.nvim helpers.lua..."

  # Patch: node:start() -> node:range()
  sed -i '' 's/local row, col = start_node:start()/local row, col = start_node:range()/' "$AERIAL_HELPERS"
  log_success "Patched node:start() -> node:range()"

  # Patch: node:end_() -> node:range()
  sed -i '' 's/local end_row, end_col = end_node:end_()/local _, _, end_row, end_col = end_node:range()/' "$AERIAL_HELPERS"
  log_success "Patched node:end_() -> node:range()"
else
  log_warning "aerial.nvim not found at $AERIAL_HELPERS (may not be installed yet)"
fi

# Patch: nvim-treesitter query_predicates.lua for Neovim 0.12.1
QUERY_PREDICATES="$HOME/.local/share/nvim/lazy/nvim-treesitter/lua/nvim-treesitter/query_predicates.lua"
if [ -f "$QUERY_PREDICATES" ]; then
  if grep -q 'vim.treesitter.get_node_text(node, bufnr):lower()' "$QUERY_PREDICATES"; then
    log_info "Patching nvim-treesitter query_predicates.lua..."
    sed -i '' \
      's/local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()/local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)\n  if not ok or not text then return end\n  local injection_alias = text:lower()/' \
      "$QUERY_PREDICATES"
    log_success "Patched query_predicates.lua get_node_text nil guard"
  else
    log_info "query_predicates.lua already patched, skipping"
  fi
else
  log_warning "nvim-treesitter query_predicates.lua not found"
fi

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
echo -e "     ${BLUE}export JAVA_HOME=\$(/usr/libexec/java_home -v 17)${NC}  # or 11, 21, etc."
echo -e "     Add to ~/.zshrc to persist across sessions."
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
