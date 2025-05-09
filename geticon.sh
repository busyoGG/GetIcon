#!/bin/bash

# 显示帮助信息
show_help() {
    echo "用法: $0 <path-to-exe> [-o output-dir] [-n file-name] [-s size] [-h]"
    echo
    echo "  <path-to-exe>      指定 EXE 文件路径（必须）"
    echo "  -o output-dir      指定输出目录（默认: $(xdg-user-dir PICTURES)/Icons）"
    echo "  -n file-name       指定文件名（不带扩展名，默认: icon）"
    echo "  -s size            指定图标尺寸（可选，默认选择最大尺寸）"
    echo "  -l                 列出所有图标尺寸信息"
    echo "  -a                 导出所有图标（默认：output-dir/file-name/*.png）"
    echo "  -h                 显示帮助信息"
}

# 默认值
FILE_NAME="icon"  # 默认文件名
OUTPUT_DIR="$(xdg-user-dir PICTURES)/Icons"  # 默认输出目录
SIZE=""
EXE_PATH=""

# 选项
LIST_SIZES=false
ALL_ICONS=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s) SIZE="$2"; shift ;;  # 获取 -s 参数（尺寸）
        -o) OUTPUT_DIR="$2"; shift ;;  # 获取 -o 参数（输出目录）
        -n) FILE_NAME="$2"; shift ;;  # 获取 -n 参数（文件名）
        -l) LIST_SIZES=true ;;  # 启用列出图标尺寸信息
        -a) ALL_ICONS=true ;;  # 获取 -a 参数（导出所有图标）
        -h) show_help; exit 0 ;;  # 显示帮助信息并退出
        -*)
          echo "无效的选项: $1"
          echo "用法: $0 <path-to-exe> [-o output-dir] [-n file-name] [-s size]"
          exit 1
          ;;
        *)
          if [[ -z "$EXE_PATH" ]]; then
            EXE_PATH="$1"  # 如果 EXE_PATH 为空，赋值
          fi
          ;;
    esac
    shift
done

# 检查 EXE 路径是否传入
if [[ -z "$EXE_PATH" ]]; then
  echo "❌ 请提供 EXE 文件路径"
  echo "使用 -h 查看详细用法"
  exit 1
fi

# 临时目录
TMP_DIR="/tmp/get_icon"
mkdir -p "$TMP_DIR"

TEMP_ICON="$TMP_DIR/temp_icon.ico"
FINAL_ICON="$OUTPUT_DIR/$FILE_NAME.png"

# 如果 -l 选项被启用，列出所有图标尺寸
if [[ "$LIST_SIZES" == true ]]; then
    echo "🎯 从 EXE 提取 ICO..."
    wrestool -x -t14 "$EXE_PATH" > "$TEMP_ICON"

    if [[ ! -s "$TEMP_ICON" ]]; then
        echo "❌ 未能提取 ICO 资源"
        exit 1
    fi

    echo "🎯 从 ICO 中提取所有图层..."
    icotool -x -o "$TMP_DIR" "$TEMP_ICON"

    echo "🎯 图标尺寸信息："
    for icon in $TMP_DIR/*.png; do
        if [[ -f "$icon" ]]; then
            SIZE_INFO=$(identify -format "%wx%h" "$icon")
            echo "  图标文件: $(basename "$icon") 尺寸: $SIZE_INFO"
        fi
    done

    rm -rf "$TMP_DIR"
    exit 0
fi

# 输出结果
echo "EXE 路径: $EXE_PATH"
echo "输出目录: $OUTPUT_DIR"
echo "文件名: $FILE_NAME"
echo "尺寸: $SIZE"

echo "🎯 从 EXE 提取 ICO..."
wrestool -x -t14 "$EXE_PATH" > "$TEMP_ICON"
if [[ ! -s "$TEMP_ICON" ]]; then
  echo "❌ 未能提取ICO资源"
  exit 1
fi

echo "🎯 从 ICO 中提取所有图层..."
icotool -x -o "$TMP_DIR" "$TEMP_ICON"

# 导出所有图标（如果 -a 参数传入）
if [[ "$ALL_ICONS" == true ]]; then
  echo "🎯 导出所有图标..."
  for icon in $TMP_DIR/*.png; do
    ICON_NAME=$(basename "$icon")
    mkdir -p "$OUTPUT_DIR/$FILE_NAME"
    OUTPUT_PATH="$OUTPUT_DIR/$FILE_NAME/$ICON_NAME"
    cp "$icon" "$OUTPUT_PATH"
    echo "✅ 已保存图标为: $OUTPUT_PATH"
  done
  exit 0
fi

if compgen -G "$TMP_DIR"/*.png > /dev/null; then
  if [[ -n "$SIZE" ]]; then
    # 如果指定了尺寸，查找并保存该尺寸的图标
    TARGET_FILE=$(find "$TMP_DIR" -name "*$SIZE*.png" | head -n1)

    echo "🎯 尝试复制尺寸为 $SIZE 的文件: $TARGET_FILE"

    if [[ -n "$TARGET_FILE" ]]; then
      mkdir -p "$OUTPUT_DIR"
      cp "$TARGET_FILE" "$FINAL_ICON"
      echo "✅ 已保存尺寸为 $SIZE 的图标: $FINAL_ICON"
    else
      echo "❌ 找不到指定尺寸 ($SIZE) 的图标"
      exit 1
    fi
  else
    # 如果没有指定尺寸，保存最大尺寸图标
    echo "🎯 识别最大尺寸图像..."
    MAX_FILE=$(identify "$TMP_DIR"/*.png | sort -k3 -nr | head -n1 | cut -d ' ' -f1)

    if [[ -n "$MAX_FILE" ]]; then
      mkdir -p "$OUTPUT_DIR"
      cp "$MAX_FILE" "$FINAL_ICON"
      echo "✅ 已保存最大图标为: $FINAL_ICON"
    else
      echo "❌ 找不到 PNG 图层"
      exit 1
    fi
  fi
else
  echo "❌ 没有提取出任何 PNG 图层"
  exit 1
fi

rm -rf "$TMP_DIR"
