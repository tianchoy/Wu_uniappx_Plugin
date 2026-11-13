#!/usr/bin/env bash
# 把本插件安装为 Zed 的 dev 扩展（macOS / Linux / Windows-GitBash）。
#
# 与 Wu 版（install.sh）不同：Zed 构建 dev 扩展时会按 extension.toml 的
# repository/rev 联网编译语法，而本插件自带 grammars/vue.wasm。这里复制一份插件
# 并删掉 [grammars.vue] 下的 repository 与 rev 两行，强制用本地 wasm。
#
# 跨平台：自动识别 Zed 数据目录；也可用环境变量覆盖：
#   ZED_DATA      Zed 数据根目录（其下应有 extensions/dev）
#   ZED_DEV_DIR   直接指定 dev 扩展目录
#   ZED_SETTINGS  指定 settings.json 路径
# 例：ZED_DATA="$HOME/.local/share/zed" bash install_zed.sh

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
if [ -z "$ZED_DATA" ]; then
  echo "无法识别当前系统的 Zed 数据目录，请用 ZED_DATA 环境变量指定，例如：" >&2
  echo '  ZED_DATA="$HOME/.local/share/zed" bash install_zed.sh' >&2
  exit 1
fi

ZED_DEV_DIR="${ZED_DEV_DIR:-$ZED_DATA/extensions/dev}"
ZED_EXT="$ZED_DEV_DIR/uniappx"
ZED_SETTINGS="${ZED_SETTINGS:-$(zed_settings_default)}"

mkdir -p "$ZED_DEV_DIR"

if [ -e "$ZED_EXT" ] && [ ! -L "$ZED_EXT" ]; then
  echo "已存在 $ZED_EXT，请先删除该目录再重装：" >&2
  echo "  rm -rf \"$ZED_EXT\"" >&2
  exit 1
fi

# 复制插件（优先 rsync 以排除 .git；无 rsync 时回退 cp -a）
if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete --exclude='.git' "$SCRIPT_DIR/" "$ZED_EXT/"
else
  rm -rf "$ZED_EXT"
  cp -a "$SCRIPT_DIR" "$ZED_EXT"
fi

# 去掉 [grammars.vue] 下的 repository / rev，强制 Zed 使用本地 grammars/vue.wasm
sed -i.bak -e '/repository = /d' -e '/^rev = /d' "$ZED_EXT/extension.toml"
rm -f "$ZED_EXT/extension.toml.bak"

# 写入 .uts -> TypeScript 映射（复用 Wu 版 patch 脚本，仅路径不同）
python3 "$SCRIPT_DIR/tools/patch_settings.py" install "$ZED_SETTINGS"

echo "已安装到 Zed dev 扩展：$ZED_EXT"
echo "完全退出并重启 Zed 后生效。"
