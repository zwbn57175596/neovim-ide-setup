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
