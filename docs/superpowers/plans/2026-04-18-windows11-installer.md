# Windows 11 Neovim IDE Installer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create PowerShell-based install and cleanup scripts for Windows 11, mirroring the existing macOS setup.

**Architecture:** Two standalone `.ps1` scripts (`setup-neovim-ide-win.ps1`, `cleanup-neovim-win.ps1`) using Scoop as package manager. Linear sequential modules with `Log-Section` separators, no function wrappers beyond logging helpers. Lua config embedded inline.

**Tech Stack:** PowerShell 5.1+, Scoop, Neovim, Git

**Spec:** `docs/superpowers/specs/2026-04-18-windows11-installer-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `setup-neovim-ide-win.ps1` | Windows 11 installer (11 modules) |
| Create | `cleanup-neovim-win.ps1` | Windows 11 cleanup script |
| Modify | `CLAUDE.md` | Document new files |

---

### Task 1: Create dev branch + script skeleton

**Files:**
- Create: `setup-neovim-ide-win.ps1`

- [ ] **Step 1: Create dev branch**

```bash
git checkout -b feature/windows11-installer
```

- [ ] **Step 2: Write script skeleton with header, logging helpers, and prerequisite checks**

Create `setup-neovim-ide-win.ps1` with the following content:

```powershell
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Color helpers ─────────────────────────────────────────────────────────────
function Log-Section($msg) {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host "▶ $msg" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
    Write-Host ""
}

function Log-Success($msg) { Write-Host "✓ $msg" -ForegroundColor Green }
function Log-Warning($msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Log-Error($msg)   { Write-Host "✗ $msg" -ForegroundColor Red }
function Log-Info($msg)    { Write-Host "ℹ $msg" -ForegroundColor Cyan }

function Test-CommandExists($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Install-ScoopPackage($package) {
    $installed = scoop list $package 2>$null
    if ($installed -match $package) {
        Log-Success "$package already installed"
    } else {
        Log-Info "Installing $package..."
        scoop install $package
        Log-Success "$package installed"
    }
}

# ── Header ────────────────────────────────────────────────────────────────────
Clear-Host
Write-Host @"
╔════════════════════════════════════════════════╗
║   Neovim IDE Setup Script (Windows 11)        ║
║   With AI Enhancement & Java Support          ║
╚════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan
Log-Info "Platform: Windows 11"
Log-Info "This script is idempotent and safe to run multiple times"

# ── Prerequisite: Scoop ───────────────────────────────────────────────────────
if (-not (Test-CommandExists "scoop")) {
    Log-Error "Scoop is not installed."
    Write-Host "  Install Scoop first:" -ForegroundColor Yellow
    Write-Host "  irm get.scoop.sh | iex" -ForegroundColor Blue
    Write-Host ""
    exit 1
}

# ── Prerequisite: Git (required by Scoop and NormalNvim clone) ────────────────
if (-not (Test-CommandExists "git")) {
    Log-Info "Installing git via Scoop..."
    scoop install git
    Log-Success "git installed"
}
```

- [ ] **Step 3: Commit skeleton**

```bash
git add setup-neovim-ide-win.ps1
git commit -m "feat(win): add script skeleton with logging helpers and prereq checks"
```

---

### Task 2: Modules 1–3 (system deps, language runtimes, nerd font)

**Files:**
- Modify: `setup-neovim-ide-win.ps1` (append after prerequisite checks)

- [ ] **Step 1: Append Module 1 — System Dependencies**

Append to `setup-neovim-ide-win.ps1`:

```powershell
# ==============================================================================
# Module 1: System Dependencies
# ==============================================================================
Log-Section "Module 1: Installing System Dependencies"

# Ensure extras bucket for some packages
$buckets = scoop bucket list 2>$null
if ($buckets -notmatch "extras") {
    Log-Info "Adding Scoop extras bucket..."
    scoop bucket add extras
}

Install-ScoopPackage "neovim"
Install-ScoopPackage "ripgrep"
Install-ScoopPackage "fd"
Install-ScoopPackage "fzf"
Install-ScoopPackage "lazygit"
Install-ScoopPackage "yazi"
Install-ScoopPackage "tree-sitter"
Install-ScoopPackage "cmake"
Install-ScoopPackage "luarocks"
Install-ScoopPackage "wget"
```

- [ ] **Step 2: Append Module 2 — Language Runtimes**

```powershell
# ==============================================================================
# Module 2: Language Runtimes
# ==============================================================================
Log-Section "Module 2: Setting Up Language Runtimes"

# Java (project JDK — read from environment, not hardcoded)
Log-Info "Checking Java environment..."
if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
    $javaVer = & "$env:JAVA_HOME\bin\java.exe" -version 2>&1 | Select-String -Pattern '"(.+?)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    Log-Success "JAVA_HOME is set → $env:JAVA_HOME (Java $javaVer)"
} elseif (Test-CommandExists "java") {
    $javaVer = & java -version 2>&1 | Select-String -Pattern '"(.+?)"' | ForEach-Object { $_.Matches[0].Groups[1].Value }
    Log-Success "java found in PATH (Java $javaVer) — JAVA_HOME not set"
    Log-Warning "Consider setting JAVA_HOME in your environment variables"
} else {
    Log-Warning "No Java found in PATH or JAVA_HOME"
    Log-Warning "Install a JDK for your project and set JAVA_HOME."
    Log-Warning "Example: scoop bucket add java && scoop install java/temurin17-jdk"
    Log-Warning "Example: scoop bucket add java && scoop install java/zulu17-jdk"
    Log-Info "Note: nvim-java will auto-download a separate JDK for JDTLS — no manual action needed."
}

# Node.js
Log-Info "Setting up Node.js..."
if (Test-CommandExists "node") {
    Log-Success "Node.js already installed"
} else {
    Log-Info "Installing Node.js..."
    Install-ScoopPackage "nodejs"
    Log-Success "Node.js installed"
}

# Python 3
Log-Info "Setting up Python 3..."
if (Test-CommandExists "python") {
    Log-Success "Python 3 already installed"
} else {
    Log-Info "Installing Python 3..."
    Install-ScoopPackage "python"
    Log-Success "Python 3 installed"
}

# Yarn
Log-Info "Setting up yarn..."
if (Test-CommandExists "yarn") {
    Log-Success "Yarn already installed"
} else {
    Log-Info "Installing yarn globally..."
    npm install -g yarn
    Log-Success "Yarn installed"
}
```

- [ ] **Step 3: Append Module 3 — Nerd Font**

```powershell
# ==============================================================================
# Module 3: Nerd Font
# ==============================================================================
Log-Section "Module 3: Installing Nerd Font"

$buckets = scoop bucket list 2>$null
if ($buckets -notmatch "nerd-fonts") {
    Log-Info "Adding Scoop nerd-fonts bucket..."
    scoop bucket add nerd-fonts
}
Install-ScoopPackage "JetBrainsMono-NF"
```

- [ ] **Step 4: Commit Modules 1–3**

```bash
git add setup-neovim-ide-win.ps1
git commit -m "feat(win): add modules 1-3 (system deps, runtimes, nerd font)"
```

---

### Task 3: Modules 4–5 (neovim config, embedded Lua)

**Files:**
- Modify: `setup-neovim-ide-win.ps1` (append)

- [ ] **Step 1: Append Module 4 — Neovim Configuration**

```powershell
# ==============================================================================
# Module 4: Neovim Configuration
# ==============================================================================
Log-Section "Module 4: Setting Up Neovim Configuration"

$nvimConfigDir = "$env:LOCALAPPDATA\nvim"
$backupTimestamp = Get-Date -Format "yyyyMMdd-HHmmss"

if (Test-Path $nvimConfigDir) {
    Log-Warning "Found existing Neovim config at $nvimConfigDir"
    $backupDir = "$env:LOCALAPPDATA\nvim.bak.$backupTimestamp"
    Log-Info "Backing up to $backupDir..."
    Copy-Item -Path $nvimConfigDir -Destination $backupDir -Recurse
    Log-Success "Backup created at $backupDir"
} else {
    Log-Info "Cloning NormalNvim configuration..."
    git clone https://github.com/NormalNvim/NormalNvim.git $nvimConfigDir
    Log-Success "NormalNvim cloned to $nvimConfigDir"
}
```

- [ ] **Step 2: Append Module 5 — Write 5-ai-enhance.lua**

This is the largest single block. The Lua content is identical to the macOS version except the avante.nvim `build` field uses the PowerShell build command.

```powershell
# ==============================================================================
# Module 5: Write 5-ai-enhance.lua
# ==============================================================================
Log-Section "Module 5: Writing AI Enhancement Configuration"

$pluginsDir = "$nvimConfigDir\lua\plugins"
if (-not (Test-Path $pluginsDir)) {
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
}

$aiEnhanceFile = "$pluginsDir\5-ai-enhance.lua"
Log-Info "Creating $aiEnhanceFile..."

$luaContent = @'
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
    build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false",
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
'@

Set-Content -Path $aiEnhanceFile -Value $luaContent -Encoding UTF8
Log-Success "AI enhancement configuration written to $aiEnhanceFile"
```

- [ ] **Step 3: Commit Modules 4–5**

```bash
git add setup-neovim-ide-win.ps1
git commit -m "feat(win): add modules 4-5 (neovim config, AI enhance lua)"
```

---

### Task 4: Modules 6–7 (headless plugin install, patches)

**Files:**
- Modify: `setup-neovim-ide-win.ps1` (append)

- [ ] **Step 1: Append Module 6 — Headless Plugin Install**

```powershell
# ==============================================================================
# Module 6: First Launch - Install Plugins
# ==============================================================================
Log-Section "Module 6: Installing Lazy Plugins (Headless)"

Log-Info "Launching Neovim to install plugins (this may take a moment)..."
$proc = Start-Process -FilePath "nvim" -ArgumentList '--headless', '"+Lazy! sync"', '+qa' `
    -NoNewWindow -PassThru -RedirectStandardError "$env:TEMP\nvim-lazy-sync.log"
if (-not $proc.WaitForExit(300000)) {
    $proc.Kill()
    Log-Warning "Plugin installation timed out after 5 minutes"
} else {
    Log-Success "Plugin installation completed"
}
```

- [ ] **Step 2: Append Module 7 — Patches**

```powershell
# ==============================================================================
# Module 7: Patching aerial.nvim for Neovim 0.12 Compatibility
# ==============================================================================
Log-Section "Module 7: Patching aerial.nvim for Neovim 0.12 Compatibility"

$aerialHelpers = "$env:LOCALAPPDATA\nvim-data\lazy\aerial.nvim\lua\aerial\backends\treesitter\helpers.lua"

if (Test-Path $aerialHelpers) {
    Log-Info "Patching aerial.nvim helpers.lua..."
    $content = Get-Content $aerialHelpers -Raw

    $content = $content -replace `
        'local row, col = start_node:start\(\)', `
        'local row, col = start_node:range()'
    Log-Success "Patched node:start() -> node:range()"

    $content = $content -replace `
        'local end_row, end_col = end_node:end_\(\)', `
        'local _, _, end_row, end_col = end_node:range()'
    Log-Success "Patched node:end_() -> node:range()"

    Set-Content -Path $aerialHelpers -Value $content -NoNewline -Encoding UTF8
} else {
    Log-Warning "aerial.nvim not found at $aerialHelpers (may not be installed yet)"
}

# Patch: nvim-treesitter query_predicates.lua for Neovim 0.12.1
$queryPredicates = "$env:LOCALAPPDATA\nvim-data\lazy\nvim-treesitter\lua\nvim-treesitter\query_predicates.lua"
if (Test-Path $queryPredicates) {
    $content = Get-Content $queryPredicates -Raw
    if ($content -match 'vim\.treesitter\.get_node_text\(node, bufnr\):lower\(\)') {
        Log-Info "Patching nvim-treesitter query_predicates.lua..."
        $content = $content -replace `
            'local injection_alias = vim\.treesitter\.get_node_text\(node, bufnr\):lower\(\)', `
            "local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)`n  if not ok or not text then return end`n  local injection_alias = text:lower()"
        Set-Content -Path $queryPredicates -Value $content -NoNewline -Encoding UTF8
        Log-Success "Patched query_predicates.lua get_node_text nil guard"
    } else {
        Log-Info "query_predicates.lua already patched, skipping"
    }
} else {
    Log-Warning "nvim-treesitter query_predicates.lua not found"
}
```

- [ ] **Step 3: Commit Modules 6–7**

```bash
git add setup-neovim-ide-win.ps1
git commit -m "feat(win): add modules 6-7 (plugin install, patches)"
```

---

### Task 5: Modules 8–11 (treesitter prompt, mason, health check, summary)

**Files:**
- Modify: `setup-neovim-ide-win.ps1` (append)

- [ ] **Step 1: Append Module 8 — TreeSitter Interactive Prompt**

```powershell
# ==============================================================================
# Module 8: TreeSitter Parser Installation (Interactive)
# ==============================================================================
Log-Section "Module 8: TreeSitter Parser Installation"

Write-Host "Please manually install TreeSitter parsers in Neovim:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Run this command in Neovim:" -ForegroundColor Yellow
Write-Host ":TSInstall java javascript typescript python lua bash json yaml toml html css markdown" -ForegroundColor Blue
Write-Host ""
Write-Host "Or execute in terminal:" -ForegroundColor Yellow
Write-Host 'nvim -c "TSInstall java javascript typescript python lua bash json yaml toml html css markdown" -c qa' -ForegroundColor Blue
Write-Host ""
Read-Host "Press Enter after installing TreeSitter parsers... "
```

- [ ] **Step 2: Append Module 9 — Mason Install**

```powershell
# ==============================================================================
# Module 9: Mason Installation
# ==============================================================================
Log-Section "Module 9: Installing Mason Tools"

Log-Info "Installing LSP servers and debug adapters via Mason..."
$masonArgs = @(
    '--headless',
    '-c', 'MasonInstall lua-language-server typescript-language-server pyright jdtls java-debug-adapter java-test debugpy js-debug-adapter codelldb bash-debug-adapter lombok-nightly spring-boot-tools',
    '-c', 'sleep 30',
    '-c', 'qa'
)
$proc = Start-Process -FilePath "nvim" -ArgumentList $masonArgs `
    -NoNewWindow -PassThru -RedirectStandardError "$env:TEMP\nvim-mason.log"
if (-not $proc.WaitForExit(300000)) {
    $proc.Kill()
    Log-Warning "Mason installation timed out after 5 minutes"
} else {
    Log-Success "Mason installation completed"
}
```

- [ ] **Step 3: Append Module 10 — Health Check**

```powershell
# ==============================================================================
# Module 10: Health Check
# ==============================================================================
Log-Section "Module 10: Health Check"

Log-Info "Running Neovim health check..."
Write-Host ""

$healthLog = "$env:TEMP\nvim-healthcheck.log"
$proc = Start-Process -FilePath "nvim" -ArgumentList '--headless', '-c', 'checkhealth', '-c', 'qa' `
    -NoNewWindow -PassThru -RedirectStandardOutput $healthLog -RedirectStandardError "$env:TEMP\nvim-health-err.log"
if (-not $proc.WaitForExit(60000)) {
    $proc.Kill()
    Log-Warning "Health check timed out"
} else {
    if (Test-Path $healthLog) {
        $errors = Get-Content $healthLog | Select-String -Pattern "ERROR|WARNING|error|warning" | Select-Object -First 20
        if ($errors) {
            $errors | ForEach-Object { Write-Host $_.Line }
        } else {
            Log-Success "Health check passed - no errors detected"
        }
    }
}
```

- [ ] **Step 4: Append Module 11 — Summary**

```powershell
# ==============================================================================
# Module 11: Summary and Quick Reference
# ==============================================================================
Log-Section "Module 11: Setup Complete!"

Write-Host "✓ Neovim IDE setup completed successfully!" -ForegroundColor Green
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Quick Reference - Keyboard Shortcuts:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "AI Shortcuts (Claude Code):" -ForegroundColor Yellow
Write-Host "  <leader>ac  - Open Claude Code in float window" -ForegroundColor Blue
Write-Host "  <leader>av  - Open Claude Code in vertical split" -ForegroundColor Blue
Write-Host ""

Write-Host "Java Development:" -ForegroundColor Yellow
Write-Host "  <leader>jo  - Run Java Application" -ForegroundColor Blue
Write-Host "  <leader>js  - Stop Java Application" -ForegroundColor Blue
Write-Host "  <leader>jt  - Test Current Method" -ForegroundColor Blue
Write-Host "  <leader>jT  - Test Current Class" -ForegroundColor Blue
Write-Host "  <leader>jD  - Config DAP (debug regular app, then <F5>)" -ForegroundColor Blue
Write-Host "  <leader>jd  - Debug Test Method" -ForegroundColor Blue
Write-Host "  <leader>jp  - Open Java Profiler" -ForegroundColor Blue
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Configuration Files:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Main Config:       $nvimConfigDir\init.lua" -ForegroundColor Blue
Write-Host "  AI Enhancement:   $aiEnhanceFile" -ForegroundColor Blue
Write-Host "  Backup Location:  $env:LOCALAPPDATA\nvim.bak.*" -ForegroundColor Blue
Write-Host ""

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

Write-Host "  1. Set your Anthropic API key:" -ForegroundColor White
Write-Host '     $env:ANTHROPIC_API_KEY = "your-key-here"' -ForegroundColor Blue
Write-Host '     # Persist across sessions:' -ForegroundColor Cyan
Write-Host '     [Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your-key-here", "User")' -ForegroundColor Blue
Write-Host ""

Write-Host "  2. Set JAVA_HOME to your project's JDK (any version):" -ForegroundColor White
Write-Host '     $env:JAVA_HOME = "C:\path\to\jdk"' -ForegroundColor Blue
Write-Host '     # Or if installed via Scoop: $env:JAVA_HOME = "$env:USERPROFILE\scoop\apps\temurin17-jdk\current"' -ForegroundColor Blue
Write-Host "     Note: nvim-java auto-manages a separate JDK for JDTLS —" -ForegroundColor Cyan
Write-Host "     JAVA_HOME only affects your project compile/run toolchain." -ForegroundColor Cyan
Write-Host ""

Write-Host "  3. Java debug workflow:" -ForegroundColor White
Write-Host "     <leader>jD  Config DAP  →  <F9>  Set breakpoint  →  <F5>  Start debug" -ForegroundColor Blue
Write-Host ""

Write-Host "  4. Launch Neovim:" -ForegroundColor White
Write-Host "     nvim" -ForegroundColor Blue
Write-Host ""

Write-Host "  5. Verify setup with health check:" -ForegroundColor White
Write-Host "     :checkhealth" -ForegroundColor Blue
Write-Host ""

Write-Host "  6. Install additional TreeSitter parsers as needed:" -ForegroundColor White
Write-Host "     :TSInstall <language>" -ForegroundColor Blue
Write-Host ""

Write-Host "Happy coding!" -ForegroundColor Green
Write-Host ""

exit 0
```

- [ ] **Step 5: Commit Modules 8–11**

```bash
git add setup-neovim-ide-win.ps1
git commit -m "feat(win): add modules 8-11 (treesitter, mason, health check, summary)"
```

---

### Task 6: Cleanup script

**Files:**
- Create: `cleanup-neovim-win.ps1`

- [ ] **Step 1: Write the complete cleanup script**

```powershell
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── Color helpers ─────────────────────────────────────────────────────────────
function Log-Info($msg)  { Write-Host "[INFO]  $msg" -ForegroundColor Green }
function Log-Warn($msg)  { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Log-Error($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "══════════════════════════════════════════"
Write-Host "  Neovim 完全清理脚本 (Windows)"
Write-Host "══════════════════════════════════════════"
Write-Host ""
Log-Warn "即将删除以下目录和文件："
Write-Host "  $env:LOCALAPPDATA\nvim         (配置)"
Write-Host "  $env:LOCALAPPDATA\nvim-data    (插件/Mason/数据)"
Write-Host "  $env:TEMP\nvim                 (缓存)"
Write-Host "  neovim (scoop)                 (二进制)"
Write-Host ""
$confirm = Read-Host "确认删除？(输入 yes 继续)"
if ($confirm -ne "yes") {
    Log-Warn "已取消。"
    exit 0
}

Write-Host ""

# ── 1. 卸载 Neovim ──────────────────────────────────────────────────────────
Log-Info "卸载 Neovim..."
$scoopList = scoop list neovim 2>$null
if ($scoopList -match "neovim") {
    scoop uninstall neovim
    Log-Info "Neovim 已卸载"
} else {
    Log-Warn "Neovim 未通过 Scoop 安装，跳过"
}

# ── 2. 删除配置目录 ──────────────────────────────────────────────────────────
Log-Info "删除 $env:LOCALAPPDATA\nvim ..."
if (Test-Path "$env:LOCALAPPDATA\nvim") {
    Remove-Item -Recurse -Force "$env:LOCALAPPDATA\nvim"
}

# ── 3. 删除数据目录（插件/Mason）────────────────────────────────────────────
Log-Info "删除 $env:LOCALAPPDATA\nvim-data ..."
if (Test-Path "$env:LOCALAPPDATA\nvim-data") {
    Remove-Item -Recurse -Force "$env:LOCALAPPDATA\nvim-data"
}

# ── 4. 删除缓存目录 ──────────────────────────────────────────────────────────
Log-Info "删除 $env:TEMP\nvim ..."
if (Test-Path "$env:TEMP\nvim") {
    Remove-Item -Recurse -Force "$env:TEMP\nvim"
}

Write-Host ""
Write-Host "══════════════════════════════════════════"
Log-Info "清理完成！"
Write-Host ""
Write-Host "重新安装："
Write-Host "  powershell -ExecutionPolicy Bypass -File setup-neovim-ide-win.ps1"
Write-Host "══════════════════════════════════════════"
Write-Host ""
```

- [ ] **Step 2: Commit cleanup script**

```bash
git add cleanup-neovim-win.ps1
git commit -m "feat(win): add cleanup script for Windows 11"
```

---

### Task 7: Update CLAUDE.md + final verification

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md File Structure section**

Add the two new files to the file structure table:

```markdown
## File Structure

```
setup-neovim-ide.sh        # Main installer - macOS ARM64 (idempotent, ~600 lines)
setup-neovim-ide-win.ps1   # Main installer - Windows 11 (idempotent, PowerShell)
cleanup-neovim.sh          # Full uninstall - macOS (destructive, requires confirmation)
cleanup-neovim-win.ps1     # Full uninstall - Windows 11 (destructive, requires confirmation)
docs/design.md             # Architecture design (source of truth for module intent)
docs/manual.md             # User-facing keyboard shortcut reference
```
```

- [ ] **Step 2: Add Windows section to CLAUDE.md**

After the "macOS ARM64 only" bullet in Key Design Principles, add a note. Then add a new section:

```markdown
## Windows 11 Scripts (setup-neovim-ide-win.ps1 / cleanup-neovim-win.ps1)

- Mirror the macOS version's 11-module structure in PowerShell
- Use Scoop as package manager (user-level, no admin)
- Neovim config path: `$env:LOCALAPPDATA\nvim` (not `~/.config/nvim`)
- Data path: `$env:LOCALAPPDATA\nvim-data` (not `~/.local/share/nvim`)
- avante.nvim build uses PowerShell command instead of `make`
- Same Lua content as macOS version (embedded inline)
- Same patches as macOS version (PowerShell string replacement instead of sed)
```

- [ ] **Step 3: Commit CLAUDE.md update**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with Windows 11 script documentation"
```

- [ ] **Step 4: Verify PowerShell syntax (if pwsh available)**

```bash
# If pwsh is installed on macOS:
pwsh -Command "[System.Management.Automation.Language.Parser]::ParseFile('setup-neovim-ide-win.ps1', [ref]\$null, [ref]\$errors); if (\$errors) { \$errors | ForEach-Object { Write-Host \$_ } } else { Write-Host 'No syntax errors' }"
pwsh -Command "[System.Management.Automation.Language.Parser]::ParseFile('cleanup-neovim-win.ps1', [ref]\$null, [ref]\$errors); if (\$errors) { \$errors | ForEach-Object { Write-Host \$_ } } else { Write-Host 'No syntax errors' }"
```

If pwsh is not available, skip this step — the scripts will be verified on Windows.
