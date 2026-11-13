; uni-app x .uvue 语言注入
; 语法树来自 tree-sitter-vue，这里补齐 UTS(<script lang="uts">) 的注入。

; <script> 无 lang：uvue 默认按 UTS / TypeScript 解析
((script_element
  (start_tag) @_no_lang
  (raw_text) @content)
  (#not-match? @_no_lang "lang=")
  (#set! "language" "typescript"))

; <script lang="js">
((script_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value
        (attribute_value) @_js)))
  (raw_text) @content)
  (#eq? @_lang "lang")
  (#eq? @_js "js")
  (#set! "language" "javascript"))

; <script setup lang="ts"> / <script setup lang="uts">
; UTS 与 TypeScript 语法高度重合，直接复用 TS 语法做高亮
((script_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value
        (attribute_value) @_script_lang)))
  (raw_text) @content)
  (#eq? @_lang "lang")
  (#any-of? @_script_lang "ts" "uts")
  (#set! "language" "typescript"))

; <script lang="tsx"> / <script lang="jsx">
(script_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @language)))
  (#eq? @_attr "lang")
  (#any-of? @language "tsx" "jsx")
  (raw_text) @content)

; {{ }} 插值
((interpolation
  (raw_text) @content)
  (#set! "language" "typescript"))

; :prop="..." / @click="..." / v-if="..." 等指令表达式
(directive_attribute
  (quoted_attribute_value
    (attribute_value) @content
    (#set! "language" "typescript")))

; <style lang="scss|less|sass|stylus|postcss|css"> 等（显式列举，避免把未知 lang 当语法去加载）
((style_element
  (start_tag
    (attribute
      (attribute_name) @_attr
      (quoted_attribute_value
        (attribute_value) @language)))
  (raw_text) @content)
  (#eq? @_attr "lang")
  (#any-of? @language "scss" "less" "sass" "stylus" "postcss" "css"))

; <style> 无 lang 默认 css
((style_element
  (start_tag
    (attribute
      (attribute_name) @_attr_name)*)
  (raw_text) @content
  (#not-any-of? @_attr_name "lang")
  (#set! language "css"))

; <template lang="pug">
((template_element
  (start_tag
    (attribute
      (attribute_name) @_lang
      (quoted_attribute_value
        (attribute_value) @_pug)))
  (text) @content)
  (#eq? @_lang "lang")
  (#eq? @_pug "pug")
  (#set! language "pug"))

; 自定义块（如 <i18n lang="json">）
(element
  (start_tag
    (tag_name) @_tag
    (attribute
      (attribute_name) @_attr
      (#eq? @_attr "lang")
      (quoted_attribute_value
        (attribute_value) @language)))
  (#not-any-of? @_tag "template" "script" "style")
  (text) @content)

; <!-- --> 注释按 HTML 处理
((comment) @content
  (#set! language "html"))
