; uni-app x (.uvue) 大纲
; 作用于 vue 根语法：列出 template/script/style 结构块，以及 template 中使用的组件。
; <script> 内的 import / 顶层函数·类·const 由注入的 TypeScript 语法大纲提供
; （取决于 Zed 是否合并注入语言的大纲；若未合并，需在编辑器里验证）。

; 注释作为大纲标注
(comment) @annotation

; ---------- 顶层结构块 ----------
(template_element
  (start_tag) @name) @item

(script_element
  (start_tag) @name) @item

(style_element
  (start_tag) @name) @item

; ---------- template 中使用的组件 ----------
; PascalCase 业务组件，如 <MyComp />
((tag_name) @name
  (#match? @name "^[A-Z]")) @item

; 短横线组件（含 uni-/uv- 内置组件），如 <uni-badge>
((tag_name) @name
  (#match? @name "[-]")) @item
