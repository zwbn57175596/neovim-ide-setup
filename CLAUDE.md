# CLAUDE.md

## Project Overview

One-command Neovim IDE installer for **macOS ARM64**. Installs and configures a full IDE environment based on [NormalNvim](https://github.com/NormalNvim/NormalNvim), with Java development support and AI tooling.

## File Structure

```
setup-neovim-ide-mac.sh    # Main installer - macOS ARM64 (idempotent, ~600 lines)
setup-neovim-ide-ubuntu.sh # Main installer - Ubuntu Linux (idempotent)
setup-neovim-ide-win.ps1   # Main installer - Windows 11 (idempotent, PowerShell)
cleanup-neovim-mac.sh      # Full uninstall - macOS (destructive, requires confirmation)
cleanup-neovim-ubuntu.sh   # Full uninstall - Ubuntu (destructive, requires confirmation)
cleanup-neovim-win.ps1     # Full uninstall - Windows 11 (destructive, requires confirmation)
docs/design.md             # Architecture design (source of truth for module intent)
docs/manual.md             # User-facing keyboard shortcut reference
```

## Architecture: setup-neovim-ide-mac.sh

The script is **linear, not function-based**. Eleven sequential modules separated by `log_section` headers:

| Module | What it does |
|--------|-------------|
| 1 | Homebrew packages: neovim, ripgrep, fd, fzf, lazygit, yazi, tree-sitter, cmake, luarocks, wget |
| 2 | Language runtimes: Java (via `$JAVA_HOME` detection), Node.js, Python 3, yarn |
| 3 | Nerd Font: `font-jetbrains-mono-nerd-font` via brew cask |
| 4 | Neovim config: clone NormalNvim or backup existing `~/.config/nvim` |
| 5 | Write `~/.config/nvim/lua/plugins/5-ai-enhance.lua` (embedded Lua heredoc) |
| 6 | Headless plugin install: `nvim --headless "+Lazy! sync" +qa` |
| 7 | Patch aerial.nvim and nvim-treesitter for Neovim 0.12 compatibility |
| 8 | Interactive: prompt user to run `:TSInstall ...` |
| 9 | Mason headless install: LSP servers + DAP adapters |
| 10 | Health check: `nvim --headless -c "checkhealth"` |
| 11 | Print quickstart summary |

## Key Design Principles

- **Idempotent**: every install step checks before acting. Re-running is always safe.
- **Non-destructive**: existing `~/.config/nvim` is backed up with a timestamp, never deleted.
- **Inline Lua**: `5-ai-enhance.lua` is written by the script as a heredoc — do not split it into a separate file in this repo.
- **No functions**: the script uses flat sequential code with `log_section` separators. Keep this style; do not refactor into function wrappers unless explicitly asked.
- **macOS ARM64 only**: this script targets Apple Silicon only. Linux and Windows are supported by separate platform-specific scripts.

## The Embedded Lua Plugin (Module 5)

`5-ai-enhance.lua` adds four things to NormalNvim:

1. **nvim-treesitter matchup disable** — workaround for Neovim 0.12 regression
2. **avante.nvim** — Claude-backed AI sidebar (provider: `claude`, model: `claude-sonnet-4-20250514`)
3. **mason-lspconfig / mason-nvim-dap** — `ensure_installed` lists for LSP + DAP
4. **Keymaps + autocmds** — Claude Code terminal (`<leader>ac`/`<leader>av`), Java IDE keys (`<leader>jo/js/jt/jT/jD/jd/jp`), which-key group labels

When modifying the Lua, preserve the structure: one `return {}` table with plugin specs. Do not extract it into separate files.

## Patches (Module 7)

Two `sed -i ''` patches applied after plugin install:

- `aerial.nvim/lua/aerial/backends/treesitter/helpers.lua`: `node:start()` → `node:range()`, `node:end_()` → `node:range()`
- `nvim-treesitter/lua/nvim-treesitter/query_predicates.lua`: nil guard around `get_node_text`

These patches target upstream bugs in Neovim 0.12. **Remove a patch only when the upstream plugin ships the fix.**

## Verification / Testing

There is no automated test suite. To verify a change works:

```bash
# Syntax check only (safe, no side effects)
rtk bash -n setup-neovim-ide-mac.sh
rtk bash -n setup-neovim-ide-ubuntu.sh

# Full test requires a clean macOS ARM64 environment
# Use cleanup-neovim-mac.sh first, then re-run setup-neovim-ide-mac.sh
```

When refactoring, always run `rtk bash -n` to catch syntax errors before committing.

## RTK (Token Optimization)

All shell commands run in this project go through RTK automatically via the Claude Code hook. No manual `rtk` prefix is needed for `git`, `find`, `grep`, etc. — the hook handles rewriting transparently.

Use `rtk` explicitly only when the hook is not active (e.g., in scripts, manual terminal sessions, or meta commands like `rtk gain` / `rtk discover`).

## What NOT to Do

- Do not add new platform support (new OS, new architecture) without explicit request
- Do not extract the Lua heredoc into a separate `.lua` file in this repo
- Do not add a `--dry-run` flag or interactive menus — keep it a single linear script
- Do not add `set -u` — some brew/nvim env vars may be unset and that is intentional
- Do not change the backup strategy from `cp -r` to `mv` — copy is safer

## Ubuntu Scripts (setup-neovim-ide-ubuntu.sh / cleanup-neovim-ubuntu.sh)

- Mirror the macOS version's 11-module structure in Bash
- Use apt as package manager + GitHub Releases binaries for lazygit, yazi, Neovim
- Neovim installed via official tarball to `~/.local/bin/nvim` (auto-detects x86_64 / arm64)
- Font installed manually via curl + fc-cache (no brew cask)
- `sed -i` (GNU sed syntax, no empty-string argument)
- Same Lua content as macOS version (embedded inline)
- Same patches as macOS version

## Windows 11 Scripts (setup-neovim-ide-win.ps1 / cleanup-neovim-win.ps1)

- Mirror the macOS version's 11-module structure in PowerShell
- Use Scoop as package manager (user-level, no admin)
- Neovim config path: `$env:LOCALAPPDATA\nvim` (not `~/.config/nvim`)
- Data path: `$env:LOCALAPPDATA\nvim-data` (not `~/.local/share/nvim`)
- avante.nvim build uses PowerShell command instead of `make`
- Same Lua content as macOS version (embedded inline)
- Same patches as macOS version (PowerShell string replacement instead of sed)
