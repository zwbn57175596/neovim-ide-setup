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
