#!/usr/bin/env bash
# 卸载 Zed 版扩展，并移除 settings.json 里的 .uts 映射。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

zed_data_default() {
  case "$(uname -s)" in
    Darwin)              printf '%s/Library/Application Support/Zed' "$HOME" ;;
    Linux)               printf '%s/.local/share/zed' "$HOME" ;;
    MINGW*|MSYS*|CYGWIN*) printf '%s/Zed' "$APPDATA" ;;
    *)                   printf '' ;;
  esac
}

zed_settings_default() {
  case "$(uname -s)" in
    Darwin|Linux)        printf '%s/.config/zed/settings.json' "$HOME" ;;
    MINGW*|MSYS*|CYGWIN*) printf '%s/Zed/settings.json' "$APPDATA" ;;
    *)                   printf '' ;;
  esac
}

ZED_DATA="${ZED_DATA:-$(zed_data_default)}"
ZED_DEV_DIR="${ZED_DEV_DIR:-$ZED_DATA/extensions/dev}"
ZED_EXT="$ZED_DEV_DIR/uniappx"
ZED_SETTINGS="${ZED_SETTINGS:-$(zed_settings_default)}"

if [ -e "$ZED_EXT" ]; then
  rm -rf "$ZED_EXT"
  echo "已移除 Zed 扩展：$ZED_EXT"
else
  echo "未找到 Zed 扩展目录，跳过"
fi

python3 "$SCRIPT_DIR/tools/patch_settings.py" uninstall "$ZED_SETTINGS"
echo "完成。"
