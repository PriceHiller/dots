; extends
(
  ([
    (list_marker_star)
    (list_marker_minus)
  ]) @markup.list
  (#offset! @markup.list 0 0 0 -1)
  (#set! conceal "•")
)
(
  ([
    (list_marker_plus)
    (list_marker_dot)
  ]) @markup.list.number
)

; checkboxes
((task_list_marker_unchecked) @markup.list.unchecked (#set! conceal ""))
((task_list_marker_checked) @markup.list.checked (#set! conceal "󰄲"))
