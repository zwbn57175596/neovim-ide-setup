#!/bin/bash
# cleanup-neovim-ubuntu.sh
# 完全清理 Ubuntu 上的 Neovim 配置、插件、缓存和二进制

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC}  $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }

echo ""
echo "══════════════════════════════════════════"
echo "  Neovim 完全清理脚本 (Ubuntu)"
echo "══════════════════════════════════════════"
echo ""
log_warn "即将删除以下目录和文件："
echo "  ~/.config/nvim                          (配置)"
echo "  ~/.local/share/nvim                     (插件/Mason/数据)"
echo "  ~/.local/state/nvim                     (状态/日志)"
echo "  ~/.cache/nvim                           (缓存)"
echo "  ~/.local/bin/nvim                       (Neovim 二进制)"
echo "  ~/.local/bin/lazygit                    (lazygit 二进制)"
echo "  ~/.local/bin/yazi                       (yazi 二进制)"
echo "  ~/.local/share/fonts/JetBrainsMonoNerd  (Nerd Font)"
echo ""
log_warn "备份目录 (~/.config/nvim.bak.*) 不会被删除。"
log_warn "通过 apt 安装的包 (ripgrep, fzf 等) 不会被删除。"
echo ""
read -p "确认删除？(输入 yes 继续): " confirm
if [ "$confirm" != "yes" ]; then
  log_warn "已取消。"
  exit 0
fi

echo ""

remove_if_exists() {
  if [ -e "$1" ]; then
    rm -rf "$1"
    echo -e "${GREEN}[INFO]${NC}  已删除 $1"
  else
    echo -e "${YELLOW}[WARN]${NC}  $1 不存在，跳过"
  fi
}

remove_if_exists "$HOME/.config/nvim"
remove_if_exists "$HOME/.local/share/nvim"
remove_if_exists "$HOME/.local/state/nvim"
remove_if_exists "$HOME/.cache/nvim"
remove_if_exists "$HOME/.local/nvim"
remove_if_exists "$HOME/.local/bin/nvim"
remove_if_exists "$HOME/.local/bin/lazygit"
remove_if_exists "$HOME/.local/bin/yazi"
remove_if_exists "$HOME/.local/bin/ya"
remove_if_exists "$HOME/.local/share/fonts/JetBrainsMonoNerd"

# 刷新字体缓存
if command -v fc-cache &> /dev/null; then
  fc-cache -fv &> /dev/null
fi

echo ""
echo "══════════════════════════════════════════"
log_info "清理完成！"
echo ""
echo "重新安装："
echo "  bash setup-neovim-ide-ubuntu.sh"
echo "══════════════════════════════════════════"
echo ""
