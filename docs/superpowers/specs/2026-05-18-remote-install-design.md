# Remote One-Line Install — Design Spec

**Date:** 2026-05-18  
**Status:** Approved

## Goal

Allow users to install the Neovim IDE without cloning the repository first, using a single `curl | bash` (or `irm | iex` on Windows) command.

## Approach

Update `README.md` only. No changes to installer scripts.

Add remote install commands to each platform section in "快速开始":

```bash
# macOS ARM64
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-mac.sh | bash

# Ubuntu Linux
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-ubuntu.sh | bash

# Windows 11 (PowerShell)
irm https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-win.ps1 | iex
```

Scripts always pulled from the `main` branch (latest version).

## Constraints

- Keep existing "clone locally then run" instructions as an alternative.
- Installer scripts themselves are not modified.
- Windows users must use PowerShell (`irm | iex`); `curl | bash` does not apply.

## Out of Scope

- Version-pinned install (specific git tag or release)
- Auto-platform-detection wrapper script (`install.sh`)
- Windows PowerShell wrapper (`install.ps1`)
