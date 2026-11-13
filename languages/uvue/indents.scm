(element
  (start_tag) @start
  [
    (end_tag)
    (erroneous_end_tag)
  ]? @end) @indent

; <template> 的直接子元素相对 <template> 缩进（template_element 不是 element，原规则不会缩进其子级）
(template_element) @indent
