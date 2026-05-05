#!/bin/bash

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
log_section() {
  echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}▶ $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

log_success() { echo -e "${GREEN}✓ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
log_error()   { echo -e "${RED}✗ $1${NC}"; }
log_info()    { echo -e "${CYAN}ℹ $1${NC}"; }

# Prereq checks
for cmd in curl git unzip sudo; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: '$cmd' is required but not installed. Please install it first."
    exit 1
  fi
done

# Header
clear
echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════╗
║   Neovim IDE Setup Script (Ubuntu Linux)      ║
║   With AI Enhancement & Java Support          ║
╚════════════════════════════════════════════════╝
EOF
echo -e "${NC}"
log_info "Platform: Ubuntu Linux ($(uname -m))"
log_info "This script is idempotent and safe to run multiple times"
log_info "sudo is required for apt operations"

# ==============================================================================
# Module 1: System Dependencies
# ==============================================================================
log_section "Module 1: Installing System Dependencies"

# Ensure ~/.local/bin exists and is on PATH
mkdir -p "$HOME/.local/bin"
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  log_warning "~/.local/bin is not on PATH. Adding to shell rc files..."
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  [ -f "$HOME/.zshrc" ] && echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  export PATH="$HOME/.local/bin:$PATH"
  log_success "PATH updated"
fi

log_info "Updating apt package index..."
sudo apt update -qq

# Core apt packages
for pkg in ripgrep fzf cmake luarocks wget curl unzip git; do
  if dpkg -l "$pkg" &> /dev/null 2>&1; then
    log_success "$pkg already installed"
  else
    log_info "Installing $pkg..."
    sudo apt install -y "$pkg"
    log_success "$pkg installed"
  fi
done

# fd-find (binary name is fdfind on Ubuntu)
if dpkg -l fd-find &> /dev/null 2>&1; then
  log_success "fd-find already installed"
else
  log_info "Installing fd-find..."
  sudo apt install -y fd-find
  log_success "fd-find installed"
fi
if [ ! -f "$HOME/.local/bin/fd" ]; then
  ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
  log_success "Created symlink: fd -> fdfind"
fi

# Neovim (official tarball — apt version is too old)
NVIM_BIN="$HOME/.local/bin/nvim"
if [ -f "$NVIM_BIN" ]; then
  log_success "Neovim already installed at $NVIM_BIN"
else
  log_info "Installing Neovim (latest release tarball)..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    NVIM_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    NVIM_ARCH="arm64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${NVIM_ARCH}.tar.gz"
  log_info "Downloading $NVIM_URL ..."
  curl -L "$NVIM_URL" -o /tmp/nvim-linux.tar.gz
  tar -xzf /tmp/nvim-linux.tar.gz -C /tmp/
  mv "/tmp/nvim-linux-${NVIM_ARCH}/bin/nvim" "$NVIM_BIN"
  chmod +x "$NVIM_BIN"
  rm -rf "/tmp/nvim-linux-${NVIM_ARCH}" /tmp/nvim-linux.tar.gz
  log_success "Neovim installed to $NVIM_BIN"
fi

# lazygit (GitHub Releases)
LAZYGIT_BIN="$HOME/.local/bin/lazygit"
if [ -f "$LAZYGIT_BIN" ]; then
  log_success "lazygit already installed"
else
  log_info "Installing lazygit..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    LG_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    LG_ARCH="arm64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  LG_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_Linux_${LG_ARCH}.tar.gz"
  curl -L "$LG_URL" -o /tmp/lazygit.tar.gz
  tar -xzf /tmp/lazygit.tar.gz -C /tmp/ lazygit
  mv /tmp/lazygit "$LAZYGIT_BIN"
  chmod +x "$LAZYGIT_BIN"
  rm /tmp/lazygit.tar.gz
  log_success "lazygit installed"
fi

# yazi (GitHub Releases)
YAZI_BIN="$HOME/.local/bin/yazi"
if [ -f "$YAZI_BIN" ]; then
  log_success "yazi already installed"
else
  log_info "Installing yazi..."
  ARCH=$(uname -m)
  if [ "$ARCH" = "x86_64" ]; then
    YZ_ARCH="x86_64"
  elif [ "$ARCH" = "aarch64" ]; then
    YZ_ARCH="aarch64"
  else
    log_error "Unsupported architecture: $ARCH"
    exit 1
  fi
  YZ_URL="https://github.com/sxyazi/yazi/releases/latest/download/yazi-${YZ_ARCH}-unknown-linux-gnu.zip"
  curl -L "$YZ_URL" -o /tmp/yazi.zip
  mkdir -p /tmp/yazi-extract
  unzip -o /tmp/yazi.zip -d /tmp/yazi-extract/
  mv "/tmp/yazi-extract/yazi-${YZ_ARCH}-unknown-linux-gnu/yazi" "$YAZI_BIN"
  chmod +x "$YAZI_BIN"
  rm -rf /tmp/yazi.zip /tmp/yazi-extract
  log_success "yazi installed"
fi
