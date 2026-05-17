# Remote One-Line Install Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `curl | bash` (and `irm | iex` for Windows) one-liners to README.md so users can install without cloning the repo.

**Architecture:** README-only change. Each platform's "快速开始" section gets a "无需 clone，直接运行" block above the existing local-run instructions. No installer scripts are modified.

**Tech Stack:** Markdown, raw.githubusercontent.com CDN, bash curl, PowerShell irm/iex

---

### Task 1: Update README.md with remote install commands

**Files:**
- Modify: `README.md` (macOS section ~line 23, Ubuntu section ~line 40, add Windows section)

- [ ] **Step 1: Open README.md and locate the macOS section**

The macOS section currently looks like:

```markdown
### macOS ARM64 (Apple Silicon)

**前提：**
- 已安装 [Homebrew](https://brew.sh)
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）

```bash
bash setup-neovim-ide-mac.sh
```
```

- [ ] **Step 2: Add remote install block to macOS section**

Replace the macOS code block with:

```markdown
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
```

- [ ] **Step 3: Add remote install block to Ubuntu section**

The Ubuntu section currently looks like:

```markdown
### Ubuntu Linux (x86_64 / ARM64)

**前提：**
- Ubuntu 22.04 LTS 或更高版本
- 已设置 `ANTHROPIC_API_KEY`（avante.nvim 需要）
- 需要 `sudo` 权限（apt 操作）

```bash
bash setup-neovim-ide-ubuntu.sh
```
```

Replace with:

```markdown
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
```

- [ ] **Step 4: Add Windows section to README**

After the Ubuntu section, add:

```markdown
### Windows 11

**前提：**
- PowerShell 5.1 或更高版本
- 已安装 [Scoop](https://scoop.sh)
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
```

- [ ] **Step 5: Verify README renders correctly**

Run:
```bash
bash -c "grep -n 'curl\|irm\|raw.githubusercontent' README.md"
```

Expected output — three matches, one per platform:
```
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-mac.sh | bash
curl -fsSL https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-ubuntu.sh | bash
irm https://raw.githubusercontent.com/zwbn57175596/neovim-ide-setup/main/setup-neovim-ide-win.ps1 | iex
```

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "docs: add remote one-line install commands to README"
```
