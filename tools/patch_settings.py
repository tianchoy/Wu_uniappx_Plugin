#!/usr/bin/env python3
"""幂等地在 Wu 的 settings.json (JSONC) 中增删 .uts/.ets -> TypeScript 映射。

Wu 的 settings.json 允许 // 注释和尾逗号，因此这里按文本插入，而不是 json.dump。
install 前会把原文件备份为 settings.json.uniappx.bak（只在首次备份）。

.uts: uni-app x 的 UTS 脚本
.ets: HarmonyOS ArkTS（TypeScript 超集），复用 TypeScript 语法高亮
"""
import json
import re
import shutil
import sys
from pathlib import Path

SETTINGS = Path.home() / ".config" / "wu" / "settings.json"
BACKUP = SETTINGS.with_name(SETTINGS.name + ".uniappx.bak")

# 需要映射到 TypeScript 的扩展名（不含点）
SUFFIXES = ["uts", "ets"]


def strip_jsonc(text: str) -> str:
    text = re.sub(r"^\s*//.*$", "", text, flags=re.MULTILINE)
    text = re.sub(r",(\s*[}\]])", r"\1", text)
    return text


def valid(text: str) -> bool:
    try:
        json.loads(strip_jsonc(text))
        return True
    except ValueError:
        return False


def fail(message: str) -> None:
    print("错误：" + message, file=sys.stderr)
    raise SystemExit(1)


def has_suffix(text: str, suffix: str) -> bool:
    return re.search(r'["\']%s["\']' % re.escape(suffix), text) is not None


def install() -> None:
    if not SETTINGS.exists():
        SETTINGS.parent.mkdir(parents=True, exist_ok=True)
        items = ", ".join('"%s"' % s for s in SUFFIXES)
        SETTINGS.write_text(
            '{\n  "file_types": {\n    "TypeScript": [%s]\n  }\n}\n' % items
        )
        print("已创建 settings.json 并写入 .uts/.ets 映射")
        return

    text = SETTINGS.read_text()
    missing = [s for s in SUFFIXES if not has_suffix(text, s)]
    if not missing:
        print("settings.json 已包含 uts/ets 映射，跳过（幂等）")
        return
    if not valid(text):
        fail("settings.json 不是合法 JSONC，未做修改；请用 --no-settings 安装后按 README 手动配置")

    if not BACKUP.exists():
        shutil.copy2(SETTINGS, BACKUP)
        print("已备份原配置: %s" % BACKUP)

    items = ", ".join('"%s"' % s for s in missing)

    ft = text.find('"file_types"')
    if ft >= 0:
        ts = re.search(r'("TypeScript"\s*:\s*\[)', text[ft:])
        if ts:
            idx = ft + ts.end()
            if re.match(r"\s*\]", text[idx:]):
                # 空数组，直接填入
                new_text = text[:idx] + items + text[idx:]
            else:
                # 非空数组，插入后补逗号分隔
                new_text = text[:idx] + items + "," + text[idx:]
        else:
            opening = re.search(r'("file_types"\s*:\s*\{)', text[ft:])
            if not opening:
                fail("无法解析已有的 file_types 配置")
            idx = ft + opening.end()
            new_text = text[:idx] + '\n    "TypeScript": [%s],' % items + text[idx:]
    else:
        idx = text.rfind("}")
        if idx < 0:
            fail("settings.json 中找不到根对象结束符")
        head = text[:idx].rstrip()
        sep = "" if head.endswith(("{", ",")) else ","
        # 一并写入 Wu 的默认映射，避免用户设置覆盖默认值时丢失 JSONC/Markdown 等规则
        defaults = (
            '  "file_types": {\n'
            '    "JSONC": [\n'
            '      "**/.zed/*.json",\n'
            '      "**/.vscode/**/*.json",\n'
            '      "**/{zed,Zed}/{settings,keymap,tasks,debug}.json",\n'
            '      "tsconfig*.json",\n'
            '    ],\n'
            '    "Markdown": [".rules", ".cursorrules", ".windsurfrules", ".clinerules"],\n'
            '    "Shell Script": [".env.*"],\n'
            '    "TypeScript": [%s],\n'
            '  },\n'
        ) % ", ".join('"%s"' % s for s in SUFFIXES)
        new_text = head + sep + "\n" + defaults + text[idx:]

    if not valid(new_text):
        fail("生成的内容不是合法 JSONC，settings.json 未改动；请手动配置")
    SETTINGS.write_text(new_text)
    print('已写入: "file_types": { "TypeScript": [%s] }' % ", ".join('"%s"' % s for s in SUFFIXES))


def uninstall() -> None:
    if not SETTINGS.exists():
        print("未找到 settings.json，跳过")
        return
    text = SETTINGS.read_text()
    if not any(has_suffix(text, s) for s in SUFFIXES):
        print("settings.json 中无 uts/ets 映射，跳过")
        return

    def strip_typescript(m: "re.Match[str]") -> str:
        had_comma = m.group(0).rstrip().endswith(",")
        items = [x.strip() for x in m.group(1).split(",") if x.strip()]
        kept = [x for x in items if x.strip("\"'") not in SUFFIXES]
        if not kept:
            return ""  # 数组里只剩我们加的项，整段（含尾逗号）删掉
        return '"TypeScript": [%s]%s' % (", ".join(kept), "," if had_comma else "")

    new_text = re.sub(r'[ \t]*"TypeScript"\s*:\s*\[([^\]]*)\]\s*,?', strip_typescript, text, count=1)
    if new_text == text:
        # 没有 TypeScript 数组，退化为移除散落的扩展名
        for s in SUFFIXES:
            new_text = re.sub(r'\s*["\']%s["\']\s*,?' % re.escape(s), "", new_text)
    new_text = re.sub(r'\s*"file_types"\s*:\s*\{\s*\}\s*,?', "", new_text, count=1)

    if not valid(new_text):
        fail("还原后的内容不是合法 JSONC，settings.json 未改动；请手动使用备份: %s" % BACKUP)
    SETTINGS.write_text(new_text)
    print("已移除 uts/ets 映射（原始备份保留在 %s）" % BACKUP)


if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "install"
    # 第二个参数可指定 settings 路径，便于测试或自定义配置目录
    if len(sys.argv) > 2:
        SETTINGS = Path(sys.argv[2]).expanduser()
        BACKUP = SETTINGS.with_name(SETTINGS.name + ".uniappx.bak")
    if action == "install":
        install()
    elif action == "uninstall":
        uninstall()
    else:
        fail("用法: patch_settings.py install|uninstall [settings.json 路径]")
