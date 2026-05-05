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
