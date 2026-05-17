# Ubuntu Installer Design Spec

**Date:** 2026-05-05
**Branch:** feature/windows11-installer (to be extended or new branch)

## Overview

Add Ubuntu Linux support by:
1. Renaming existing macOS scripts to include `-mac` suffix
2. Creating `setup-neovim-ide-ubuntu.sh` — 11-module installer mirroring macOS structure
3. Creating `cleanup-neovim-ubuntu.sh` — uninstaller mirroring macOS cleanup script
4. Updating `CLAUDE.md` and `README.md` to reflect new filenames

## File Changes

### Renames (git mv)

| Before | After |
|--------|-------|
| `setup-neovim-ide.sh` | `setup-neovim-ide-mac.sh` |
| `cleanup-neovim.sh` | `cleanup-neovim-mac.sh` |

### New Files

| File | Purpose |
|------|---------|
| `setup-neovim-ide-ubuntu.sh` | Ubuntu installer (idempotent, 11 modules) |
| `cleanup-neovim-ubuntu.sh` | Ubuntu uninstaller (destructive, requires confirmation) |

## Architecture: setup-neovim-ide-ubuntu.sh

Same 11-module linear structure as the macOS version. No functions beyond logging helpers. Re-running is always safe (idempotent).

### Module-by-Module Adaptations

**Module 1 — System Dependencies**

Use `apt install` instead of `brew install`. Package name differences:

| Tool | macOS | Ubuntu |
|------|-------|--------|
| neovim | `brew install neovim` | AppImage from GitHub Releases (apt version too old) |
| fd | `fd` | `fd-find` (binary: `fdfind`) |
| ripgrep | `ripgrep` | `ripgrep` |
| fzf | `fzf` | `fzf` |
| cmake | `cmake` | `cmake` |
| luarocks | `luarocks` | `luarocks` |
| wget | `wget` | `wget` |
| lazygit | `brew install lazygit` | Download binary from GitHub Releases |
| yazi | `brew install yazi` | Download binary from GitHub Releases |
| tree-sitter | `brew install tree-sitter` | `npm install -g --prefix "$HOME/.local" tree-sitter-cli` (after Node install in Module 2) |

**Neovim AppImage install** (part of Module 1):
```bash
ARCH=$(uname -m)   # x86_64 or aarch64
# Download nvim-linux-<arch>.appimage from GitHub Releases
# Install to ~/.local/bin/nvim, chmod +x
```
Idempotent: skip if `~/.local/bin/nvim` already exists.

After installing `fd-find`, create symlink so `fd` works:
```bash
mkdir -p ~/.local/bin
ln -sf /usr/bin/fdfind ~/.local/bin/fd
```

Ensure `~/.local/bin` is on `$PATH` (add to `~/.bashrc` / `~/.zshrc` if missing).

`lazygit` and `yazi` install pattern:
```bash
# detect ARCH=$(uname -m), map to release asset name
# curl -L <github-releases-url> -o /tmp/<tool>.tar.gz
# tar -xzf ... -C ~/.local/bin/
```

**Module 2 — Language Runtimes**

- **Java:** Remove `/usr/libexec/java_home` call. Check `$JAVA_HOME` and `which java`. If missing, advise: `sudo apt install openjdk-17-jdk` and `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`.
- **Node.js:** Use NodeSource setup script (Ubuntu apt ships outdated Node). Install via `curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt install -y nodejs`.
- **Python 3:** `sudo apt install -y python3 python3-pip` (usually pre-installed on Ubuntu).
- **npm global CLI prefix:** Use `~/.local` so npm-installed CLIs do not require root and are available through the existing `~/.local/bin` PATH entry.
- **Yarn:** `npm install -g --prefix "$HOME/.local" yarn`.

**Module 3 — Nerd Font**

No brew cask. Manual install:
```bash
mkdir -p ~/.local/share/fonts
curl -L "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
  -o /tmp/JetBrainsMono.zip
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd/
fc-cache -fv
```

Idempotent check: skip download if font files already present.

**Module 4 — Neovim Configuration**

Identical to macOS: clone NormalNvim or backup existing `~/.config/nvim`.

**Module 5 — Write 5-ai-enhance.lua**

Identical Lua heredoc as macOS version.

**Module 6 — Plugin Install**

Identical: `timeout 300 nvim --headless "+Lazy! sync" +qa`

**Module 7 — Patches**

Same patches as macOS, but use GNU sed syntax:
```bash
sed -i 's/old/new/' file    # Linux GNU sed (no empty string arg)
```

**Module 8 — TreeSitter (Interactive)**

Identical prompt and instructions.

**Module 9 — Mason Install**

Identical headless Mason command.

**Module 10 — Health Check**

Identical.

**Module 11 — Summary**

Same structure. Adapt Java hint to show `apt install openjdk-17-jdk` instead of brew cask.

## Architecture: cleanup-neovim-ubuntu.sh

Mirrors `cleanup-neovim-mac.sh`. Requires user confirmation before deleting.

Removes:
```
~/.config/nvim
~/.local/share/nvim
~/.local/state/nvim
~/.cache/nvim
~/.local/bin/nvim          # AppImage
~/.local/bin/lazygit       # manually installed
~/.local/bin/yazi          # manually installed
~/.local/share/fonts/JetBrainsMonoNerd/  # font files
```

Does NOT remove:
- `~/.config/nvim.bak.*` — backups preserved (same policy as macOS)
- System packages installed via apt (ripgrep, fzf, etc.) — not the installer's job to uninstall
- Node.js / Python — shared system tools

## CLAUDE.md / README.md Updates

Update file table in both documents to reflect new `-mac` suffixed filenames and add Ubuntu entries.

## Constraints

- No `set -u` (same as macOS version)
- Idempotent: every step checks before acting
- Non-destructive: existing `~/.config/nvim` backed up with timestamp
- No functions: flat sequential code with `log_section` separators
- Single file: no external lib dependencies, must run standalone
- Requires `sudo` for apt operations (will prompt user)
