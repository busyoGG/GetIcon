#!/bin/bash

# 删除脚本文件
sudo rm -f /usr/local/bin/geticon
echo "🗑️ 已删除 /usr/local/bin/geticon"

# 提示用户是否卸载依赖
read -p "是否要卸载依赖 (icoutils)? [y/N]: " UNINSTALL_DEPS

# 如果用户选择卸载
if [[ "$UNINSTALL_DEPS" =~ ^[Yy]$ ]]; then
    if command -v pacman &>/dev/null; then
        sudo pacman -Rns --noconfirm icoutils
    elif command -v apt &>/dev/null; then
        sudo apt remove --purge -y icoutils
    elif command -v dnf &>/dev/null; then
        sudo dnf remove -y icoutils
    elif command -v zypper &>/dev/null; then
        sudo zypper remove -y icoutils
    else
        echo "❌ 未识别的包管理器，无法卸载 icoutils"
    fi
else
    echo "✅ 已保留依赖。"
fi

echo "✅ 卸载完成！"
