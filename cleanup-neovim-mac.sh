#!/bin/bash
# cleanup-neovim.sh
# 完全清理 Neovim 配置、插件、缓存和二进制

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

echo ""
echo "══════════════════════════════════════════"
echo "  Neovim 完全清理脚本"
echo "══════════════════════════════════════════"
echo ""
log_warn "即将删除以下目录和文件："
echo "  ~/.config/nvim       (配置)"
echo "  ~/.local/share/nvim  (插件/Mason/数据)"
echo "  ~/.local/state/nvim  (状态/日志)"
echo "  ~/.cache/nvim        (缓存)"
echo "  neovim (brew)        (二进制)"
echo ""
read -p "确认删除？(输入 yes 继续): " confirm
if [ "$confirm" != "yes" ]; then
  log_warn "已取消。"
  exit 0
fi

echo ""

# ── 1. 卸载 Neovim ──────────────────────────────────────────────────────────
log_info "卸载 Neovim..."
if brew list neovim &>/dev/null; then
  brew uninstall neovim
  log_info "Neovim 已卸载"
else
  log_warn "Neovim 未通过 brew 安装，跳过"
fi

# ── 2. 删除配置目录 ──────────────────────────────────────────────────────────
log_info "删除 ~/.config/nvim ..."
rm -rf ~/.config/nvim

# ── 3. 删除数据目录（插件/Mason）────────────────────────────────────────────
log_info "删除 ~/.local/share/nvim ..."
rm -rf ~/.local/share/nvim

# ── 4. 删除状态目录（日志/swap/undo）────────────────────────────────────────
log_info "删除 ~/.local/state/nvim ..."
rm -rf ~/.local/state/nvim

# ── 5. 删除缓存目录 ──────────────────────────────────────────────────────────
log_info "删除 ~/.cache/nvim ..."
rm -rf ~/.cache/nvim

echo ""
echo "══════════════════════════════════════════"
log_info "清理完成！"
echo ""
echo "重新安装："
echo "  bash ~/setup-neovim-ide.sh"
echo "══════════════════════════════════════════"
echo ""
