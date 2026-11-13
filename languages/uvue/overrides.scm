(comment) @comment

; 条件编译注释 <!-- #ifdef APP --> / #ifndef / #endif / #else / #elif 单独上色
; 放在 overrides 里，确保优先级高于 highlights.scm 的普通 (comment) @comment
((comment) @keyword.directive
  (#match? @keyword.directive "#if(def|ndef)|#endif|#else|#elif"))

[
  (raw_text)
  (attribute_value)
  (quoted_attribute_value)
] @string
