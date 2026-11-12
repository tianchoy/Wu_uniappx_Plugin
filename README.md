# Wu 编辑器 · uni-app x (UVue) 高亮插件

给 Wu 编辑器增加 `.uvue` 语法高亮，并让 `.uts` 文件按 TypeScript 高亮。

- 适用：macOS 版 Wu（Zed 内核），已在 Wu 1.2.2 验证
- 依赖：系统自带 `python3`（仅安装脚本用），无需联网、无需 Node/Rust
- 插件自带 tree-sitter-vue 编译产物，**不需要**先安装 Vue 扩展

## 安装

1. 解压 `wu-uniappx.zip`，把解压出来的 `uniappx` 文件夹放到一个**长期保留的目录**，例如：

   ```bash
   mkdir -p ~/.config/wu/extensions
   # 把 uniappx 文件夹放进去，最终路径类似：
   # ~/.config/wu/extensions/uniappx/extension.toml
   ```

   > 不要放在「下载」里随后删掉：Wu 通过软链指向这个目录，目录被删插件即失效。

2. 执行安装脚本：

   ```bash
   cd ~/.config/wu/extensions/uniappx
   bash install.sh
   ```

   脚本会做两件事：
   - 在 `~/Library/Application Support/Wu/extensions/installed/uniappx` 创建软链（Wu 把软链识别为本地 dev 扩展，启动时自动加载）
   - 在 `~/.config/wu/settings.json` 的 `file_types` 中幂等加入 `"TypeScript": ["uts"]`，并把原配置备份为 `settings.json.uniappx.bak`

   如果不想让脚本改配置，用 `bash install.sh --no-settings`，然后按下面「手动配置 .uts」操作。

3. 完全退出 Wu（`Cmd+Q`）再打开；运行中 Wu 通常也会自动热重载。

## 验证

- 打开任意 `.uvue` 文件，右下角语言应显示 **UVue**
- `<template>` 标签/属性、`{{ }}` 插值、`:prop` / `@click` / `v-if` 表达式、`<script setup lang="uts">` 里的代码、`<style lang="scss">` 都应有颜色
- 打开 `.uts` 文件，语言显示 **TypeScript**

## 手动配置 .uts（使用 `--no-settings` 时）

在 `~/.config/wu/settings.json` 里加一段（已有 `file_types` 就合并进去）：

```jsonc
"file_types": {
  "TypeScript": ["uts"]
}
```

## 可选配置

- Wu 使用自定义数据目录时，给脚本指定扩展目录：
  `WU_EXTENSIONS_DIR="/your/path/extensions/installed" bash install.sh`
- 想改高亮规则：编辑 `languages/uvue/injections.scm`，重启 Wu 生效。

## 故障排查

- **没高亮**：先重启 Wu；再看日志 `~/Library/Logs/Wu/Wu.log` 里是否有 `failed to load language UVue`。
- **日志报 grammar 实例化失败 / Wu 版本差异**：本机 Vue 扩展可兜底。先在 Wu 扩展页安装官方 **Vue** 扩展，然后删除本插件的 `grammars/` 目录，并把 `extension.toml` 末尾的 `[grammars.vue]` 整段（含 repository/rev 两行）删掉；`languages/uvue/config.toml` 里的 `grammar = "vue"` 保持不变，重启 Wu 即可改为复用官方语法。
- **不要**在 Wu 扩展页点 `Rebuild Dev Extension`：那会按 `extension.toml` 里的仓库地址联网重新编译语法，本插件不需要。
- **已有同名 `uniappx` 目录**：`install.sh` 会拒绝覆盖，先手动备份该目录。

## 卸载

```bash
cd ~/.config/wu/extensions/uniappx
bash uninstall.sh
```

这会移除扩展软链并清掉 `.uts` 映射（原始配置备份仍保留在 `settings.json.uniappx.bak`）。之后可删除插件目录，重启 Wu。

## 能力边界

- 提供：语法高亮、括号匹配/自动闭合、缩进、代码大纲
- 不提供：uni-app x 语言服务（LSP）、补全、跳转、类型检查、诊断、`.uvue` 文件图标
- UTS 复用 TypeScript 语法树，个别 UTS 特有写法可能不完美；`<!-- #ifdef APP -->` 之类的条件编译注释按普通 HTML 注释处理
- `.uts` 按 TypeScript 处理，Wu 会顺带启动 TS 语言服务，可能出现与 UTS 语法不完全匹配的诊断提示；只想要高亮可用 `--no-settings` 并在 Wu 设置里按语言关闭对应 LSP

## 来源

语法解析使用 `tree-sitter-vue`（MIT），rev `7e48557b903a9db9c38cea3b7839ef7e1f36c693`；查询文件在 Zed/Vue 扩展查询基础上补充了 UTS 注入规则。
