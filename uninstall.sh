#!/usr/bin/env bash
# Wu / uni-app x 插件卸载脚本（macOS）
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WU_EXT_DIR="${WU_EXTENSIONS_DIR:-$HOME/Library/Application Support/Wu/extensions/installed}"
LINK="$WU_EXT_DIR/uniappx"

if [ -L "$LINK" ]; then
  rm "$LINK"
  echo "已移除扩展软链: $LINK"
else
  echo "未找到扩展软链，跳过。"
fi

if [ "${1:-}" = "--no-settings" ] || [ "${WU_NO_SETTINGS:-}" = "1" ]; then
  echo "已跳过 settings.json 还原。"
else
  python3 "$PLUGIN_DIR/tools/patch_settings.py" uninstall
fi

echo "卸载完成，重启 Wu 后生效。插件目录可自行删除: $PLUGIN_DIR"
