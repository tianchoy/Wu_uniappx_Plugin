# uni-app x (UVue) Syntax Highlighting

A Zed/Wu extension that adds syntax highlighting for uni-app x `.uvue` files and maps `.uts` (uni-app x UTS) and `.ets` (HarmonyOS ArkTS) files to TypeScript.

- Works with Zed and Wu (a Zed-based editor); verified on Wu 1.2.2 and current Zed builds.
- Ships with a prebuilt `tree-sitter-vue` grammar, so no separate Vue extension is required for local/dev installs.
- No Node.js or Rust toolchain is needed to use it.

## Features

- `.uvue`: template tags, attributes, `{{ }}` interpolations, `:prop` / `@click` / `v-if` expressions, `<script setup lang="uts">`, and `<style lang="scss">` highlighting
- Conditional compilation comments (`<!-- #ifdef APP -->`, `#ifndef`, `#endif`, `#else`, `#elif`) highlighted as keywords
- `<uni-*>` and `<uv-*>` built-in component tags highlighted separately from other tags
- Correct indentation inside `<template>`
- Code outline listing structural blocks (`template` / `script` / `style`) and components used in the template
- Bracket matching and auto-closing

## Installation in Zed

### From the extension registry

Once this extension is published to the official Zed extension registry, open the Extensions view in Zed, search for **uni-app x**, and install it.

> The published extension relies on the `repository` and `rev` declared in `extension.toml`; Zed compiles the Tree-sitter grammar from those sources.

### Local/dev install

From a checkout of this repository:

```bash
cd /path/to/Wu_uniappx_Plugin
bash install_zed.sh
```

The script:

- detects the Zed data directory for your platform (macOS: `~/Library/Application Support/Zed`; Linux: `~/.local/share/zed`; Windows Git Bash: `%APPDATA%/Zed`) and copies the extension to `extensions/dev/uniappx`;
- removes `repository` / `rev` only from the `[grammars.vue]` section of the copied `extension.toml`, so Zed uses the bundled `grammars/vue.wasm` instead of compiling the grammar;
- idempotently adds `"TypeScript": ["uts", "ets"]` to `file_types` in Zed's `settings.json`.

Environment overrides: `ZED_DATA`, `ZED_DEV_DIR`, `ZED_SETTINGS`. Example:

```bash
ZED_DATA="$HOME/.local/share/zed" bash install_zed.sh
```

On Windows, run the script with **Git Bash** or WSL.

Uninstall:

```bash
cd /path/to/Wu_uniappx_Plugin
bash uninstall_zed.sh
```

## Installation in Wu

1. Put the repository (or the extracted folder) in a permanent directory, for example:

   ```bash
   mkdir -p ~/.config/wu/extensions
   # final path: ~/.config/wu/extensions/uniappx/extension.toml
   ```

   Do not place it in Downloads and delete it later: Wu loads the extension through a symlink to this directory.

2. Run the installer:

   ```bash
   cd ~/.config/wu/extensions/uniappx
   bash install.sh
   ```

   It creates `~/Library/Application Support/Wu/extensions/installed/uniappx` as a symlink and adds `"TypeScript": ["uts", "ets"]` to `~/.config/wu/settings.json`. The original settings file is backed up as `settings.json.uniappx.bak`.

   Use `bash install.sh --no-settings` to skip the settings change and configure file types yourself.

3. Restart Wu (`Cmd+Q` then reopen).

Uninstall:

```bash
cd ~/.config/wu/extensions/uniappx
bash uninstall.sh
```

## Manual file type configuration

If you used `--no-settings`, or prefer to configure file types yourself, add this to the editor's `settings.json` (merge it into an existing `file_types` object):

```jsonc
"file_types": {
  "TypeScript": ["uts", "ets"]
}
```

Settings paths:

- Wu: `~/.config/wu/settings.json`
- Zed (macOS/Linux): `~/.config/zed/settings.json`
- Zed (Windows): `%APPDATA%/Zed/settings.json`

## Verification

- Open a `.uvue` file: the language shown in the status bar should be **UVue**, and template/script/style content should be colored.
- Open a `.uts` or `.ets` file: the language should be **TypeScript**.

## Scope and limitations

Provided:

- syntax highlighting, bracket matching / auto-closing, indentation, and code outline

Not provided:

- uni-app x or ArkTS language services (LSP), completion, go-to-definition, type checking, diagnostics, or `.uvue` file icons

Additional notes:

- UTS and ArkTS are highlighted using the TypeScript grammar; language-specific constructs may not be perfectly represented.
- ArkTS decorators such as `@State`, `@Component`, and `@Link` are colored normally; `struct`, `build()`, and built-in UI component names (`Column`, `Text`, etc.) are highlighted as ordinary identifiers.
- Conditional compilation comments are colored as a whole; they are not split into lexical tokens.

### TypeScript diagnostics on `.uts` / `.ets`

Mapping `.uts` and `.ets` to TypeScript also starts the editor's TypeScript language server. It understands standard TypeScript, but not uni-app x / ArkTS-specific syntax and APIs, so some diagnostics cannot be eliminated:

| Diagnostic | Cause |
| --- | --- |
| `ts(2307) Cannot find module './foo.uts'` | TypeScript's module resolver does not recognize `.uts` paths |
| `ts(2304) Cannot find name 'UTSJSONObject'` | UTS/ArkTS globals and `@ohos.*` modules are unknown to TypeScript |
| `ts(2352)` object literal `as UTSJSONObject` | The object literal does not provide `UTSJSONObject` method signatures |

These messages **only affect editor display**; they do not affect HBuilderX or DevEco compilation and runtime.

If the noise is too high, disable the TypeScript language server once in your editor settings (applies to all projects; no per-project type shims are required):

```jsonc
"languages": {
  "TypeScript": {
    "enable_language_server": false
  }
}
```

Syntax highlighting, indentation, brackets, and outline remain available; completion, go-to-definition, and hover are disabled.

## Troubleshooting

- **No highlighting**: restart the editor first. For Wu, check `~/Library/Logs/Wu/Wu.log` for `failed to load language UVue`.
- **Grammar instantiation failures / editor version differences**: install the official Vue extension from the editor's extension marketplace, delete this extension's `grammars/` directory, and remove the whole `[grammars.vue]` section from `extension.toml`. Keep `grammar = "vue"` in `languages/uvue/config.toml`, then restart. This makes the extension reuse the official grammar.
- **Do not** click `Rebuild Dev Extension` in Wu's extension page: it would try to rebuild the grammar from the repository URL, which this local/dev setup does not need.
- **An `uniappx` directory already exists**: `install.sh` refuses to overwrite it; back it up manually first.

## License

MIT — see [LICENSE](LICENSE).

Syntax parsing uses [`tree-sitter-vue`](https://github.com/tree-sitter-grammars/tree-sitter-vue) (MIT), revision `7e48557b903a9db9c38cea3b7839ef7e1f36c693`. The queries are based on Zed/Vue extension queries with UTS injection rules added.
