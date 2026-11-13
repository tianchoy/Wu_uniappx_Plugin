(comment) @comment

((tag_name) @tag
  (#match? @tag "^[a-z]"))

((tag_name) @tag @tag.component.type.constructor
  (#match? @tag "^[A-Z]"))

(attribute) @attribute

(directive_attribute) @property

(quoted_attribute_value) @string

(interpolation) @punctuation.special

(raw_text) @embedded

((directive_name) @punctuation.delimiter
  (#any-of? @punctuation.delimiter ":" "@" "#"))

((directive_name) @keyword.directive
  (#match? @keyword.directive "^v-"))

(directive_argument) @attribute

(start_tag) @tag

(end_tag) @tag

(self_closing_tag) @tag

[
  "="
  ":"
] @punctuation.delimiter

[
  "<"
  ">"
  "</"
  "/>"
] @punctuation.bracket

; uni-app / uni-ui 内置组件 <uni-*>、<uv-*> 区分上色
; 本规则位于文件末尾，优先级高于上方的 (tag_name) @tag，对匹配到的节点生效
((tag_name) @tag.builtin
  (#match? @tag.builtin "^(uni|uv)-"))
