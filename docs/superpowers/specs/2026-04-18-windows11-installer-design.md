# Windows 11 Neovim IDE Installer - Design Spec

## Overview

Create a Windows 11 version of the existing macOS ARM64 Neovim IDE installer. Two new PowerShell scripts that mirror the macOS versions:

- `setup-neovim-ide-win.ps1` — Install script (11 modules, idempotent)
- `cleanup-neovim-win.ps1` — Cleanup script (destructive, requires confirmation)

## Approach

**Approach A: Parallel dual scripts.** Each platform has its own independent scripts. Same 11-module structure, same functionality, no cross-platform abstraction. Lua config (`5-ai-enhance.lua`) is embedded inline in the script as a heredoc-equivalent (`@"..."@`), matching the macOS design principle.

## Script Language & Package Manager

- **Script language**: PowerShell (.ps1), native to Windows 11
- **Package manager**: Scoop (user-level, no admin required)
- **Execution policy**: Script checks at startup; prompts `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` if restricted

## File Structure

```
setup-neovim-ide-win.ps1    # Windows 11 installer (PowerShell)
cleanup-neovim-win.ps1      # Windows 11 cleanup (PowerShell)
```

## Windows Path Mapping

| macOS | Windows |
|-------|---------|
| `~/.config/nvim` | `$env:LOCALAPPDATA\nvim` |
| `~/.local/share/nvim` | `$env:LOCALAPPDATA\nvim-data` |
| `~/.local/state/nvim` | `$env:LOCALAPPDATA\nvim-data` |
| `~/.cache/nvim` | `$env:TEMP\nvim` |
| `~/.zshrc` | PowerShell `$PROFILE` |
| Homebrew | Scoop |

## Module Design (setup-neovim-ide-win.ps1)

### Module 1: System Dependencies

Install via Scoop (skip if already installed):

```powershell
scoop bucket add extras   # for some packages
scoop bucket add nerd-fonts
scoop install neovim ripgrep fd fzf lazygit yazi tree-sitter cmake luarocks wget
```

### Module 2: Language Runtimes

- **Java**: Check `$env:JAVA_HOME`, suggest `scoop bucket add java && scoop install java/temurin-jdk` or `java/zulu17-jdk`
- **Node.js**: `scoop install nodejs`
- **Python 3**: `scoop install python`
- **Yarn**: `npm install -g yarn`

### Module 3: Nerd Font

```powershell
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF
```

### Module 4: Neovim Configuration

- Config dir: `$env:LOCALAPPDATA\nvim`
- If exists: backup to `$env:LOCALAPPDATA\nvim.bak.YYYYMMDD-HHmmss` via `Copy-Item -Recurse`
- If not exists: `git clone https://github.com/NormalNvim/NormalNvim.git $env:LOCALAPPDATA\nvim`

### Module 5: Write 5-ai-enhance.lua

Identical Lua content to macOS version, with one difference:

- avante.nvim `build` field: `"powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"` instead of `"make"`

Written via `Set-Content` with a PowerShell here-string (`@"..."@`).

### Module 6: Headless Plugin Install

```powershell
$proc = Start-Process -FilePath "nvim" -ArgumentList '--headless', '"+Lazy! sync"', '+qa' -NoNewWindow -PassThru
if (-not $proc.WaitForExit(300000)) { $proc.Kill() }
```

### Module 7: Patches (aerial.nvim + nvim-treesitter)

Same patches as macOS, implemented with PowerShell string replacement:

```powershell
$content = Get-Content $filePath -Raw
$content = $content -replace 'pattern', 'replacement'
Set-Content $filePath $content
```

Patch targets under `$env:LOCALAPPDATA\nvim-data\lazy\`.

### Module 8: TreeSitter (Interactive)

`Read-Host` prompt to remind user to run `:TSInstall ...` in Neovim.

### Module 9: Mason Install

Headless nvim with MasonInstall, same tools as macOS version, with timeout.

### Module 10: Health Check

`nvim --headless -c "checkhealth" -c "qa"` — parse output for errors/warnings.

### Module 11: Summary

`Write-Host` with colored output. Environment variable instructions use PowerShell syntax:

```powershell
$env:ANTHROPIC_API_KEY = "your-key-here"
# Persist:
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your-key-here", "User")
```

Java home instructions use `$env:JAVA_HOME` instead of `/usr/libexec/java_home`.

## Cleanup Script (cleanup-neovim-win.ps1)

### Targets

| Item | Path |
|------|------|
| Neovim config | `$env:LOCALAPPDATA\nvim` |
| Plugins/Mason/data | `$env:LOCALAPPDATA\nvim-data` |
| Cache | `$env:TEMP\nvim` |
| Neovim binary | `scoop uninstall neovim` |

### Flow

1. List directories to be deleted (Chinese prompts, matching macOS cleanup script)
2. `Read-Host` confirmation (must type `yes`)
3. `scoop uninstall neovim`
4. `Remove-Item -Recurse -Force` each directory
5. Print completion message with reinstall command

Does NOT uninstall Scoop itself or other Scoop packages.

## Design Principles (inherited from macOS version)

- **Idempotent**: every step checks before acting, re-running is safe
- **Non-destructive**: existing config is backed up, never deleted
- **Inline Lua**: `5-ai-enhance.lua` embedded in the script, not a separate file
- **No functions**: flat sequential code with `Log-Section` separators (except logging helper functions)
- **Windows 11 only**: no Linux, no macOS, no older Windows versions

## What NOT to Do

- Do not add cross-platform logic or shared abstractions
- Do not extract the Lua config into a separate file
- Do not require admin/elevated privileges (Scoop is user-level)
- Do not install Scoop automatically — if missing, print instructions and exit
