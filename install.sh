#!/bin/bash

# 脚本文件名
SCRIPT_NAME="geticon"
SCRIPT_PATH="./geticon.sh"

# 检查 geticon.sh 是否存在
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "❌ 找不到 $SCRIPT_PATH，请在脚本所在目录运行安装命令。"
    exit 1
fi

# 检测操作系统类型
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO_FAMILY=${ID_LIKE,,}
else
    echo "❌ 无法识别操作系统（缺少 /etc/os-release）"
    exit 1
fi

# 安装依赖
echo "🔍 正在安装依赖 icoutils ..."

if command -v pacman &>/dev/null; then
    echo "使用 pacman 安装"
    sudo pacman -Sy --noconfirm icoutils  # 不使用 `-Syu`，只更新库信息再安装
elif command -v apt &>/dev/null; then
    echo "使用 apt 安装"
    sudo apt update
    sudo apt install -y icoutils
elif command -v dnf &>/dev/null; then
    echo "使用 dnf 安装"
    sudo dnf makecache
    sudo dnf install -y icoutils
elif command -v zypper &>/dev/null; then
    echo "使用 zypper 安装"
    sudo zypper refresh
    sudo zypper install -y icoutils
else
    echo "❌ 未识别的包管理器，请手动安装 icoutils"
    exit 1
fi

# 安装脚本到 /usr/local/bin
echo "📦 安装脚本到 /usr/local/bin/$SCRIPT_NAME..."
sudo cp "$SCRIPT_PATH" /usr/local/bin/"$SCRIPT_NAME"
sudo chmod +x /usr/local/bin/"$SCRIPT_NAME"

echo "✅ 安装完成！你现在可以通过命令行输入 '$SCRIPT_NAME' 来运行该工具。"
