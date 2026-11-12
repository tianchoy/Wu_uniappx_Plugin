#!/usr/bin/env bash
# Wu / uni-app x 插件安装脚本（macOS）
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WU_EXT_DIR="${WU_EXTENSIONS_DIR:-$HOME/Library/Application Support/Wu/extensions/installed}"
LINK="$WU_EXT_DIR/uniappx"

echo "插件目录: $PLUGIN_DIR"

if [ ! -f "$PLUGIN_DIR/extension.toml" ]; then
  echo "错误：未找到 extension.toml，请确认压缩包已完整解压。" >&2
  exit 1
fi

if [ -z "${WU_EXTENSIONS_DIR:-}" ] && [ ! -d "$HOME/Library/Application Support/Wu" ]; then
  echo "错误：未找到 Wu 数据目录，请先启动一次 Wu 再安装。" >&2
  exit 1
fi

if [ -e "$LINK" ] && [ ! -L "$LINK" ]; then
  echo "错误：$LINK 已存在且不是软链，请先手动备份该目录后重试。" >&2
  exit 1
fi

mkdir -p "$WU_EXT_DIR"
if [ -L "$LINK" ]; then
  rm "$LINK"
fi
ln -s "$PLUGIN_DIR" "$LINK"
echo "已注册扩展: $LINK -> $PLUGIN_DIR"

if [ "${1:-}" = "--no-settings" ] || [ "${WU_NO_SETTINGS:-}" = "1" ]; then
  echo "已跳过 settings.json；.uts 高亮需按 README 手动配置。"
else
  python3 "$PLUGIN_DIR/tools/patch_settings.py" install
fi

echo ""
echo "安装完成。若 .uvue 仍无高亮，请完全退出 Wu（Cmd+Q）后重新打开。"
