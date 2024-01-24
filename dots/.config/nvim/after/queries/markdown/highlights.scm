; extends
(
  ([
    (list_marker_star)
    (list_marker_plus)
    (list_marker_minus)
  ]) @markup.list.markdown
  (#offset! @markup.list.markdown 0 0 0 -1)
  (#set! conceal "•")
)

; checkboxes
((task_list_marker_unchecked) @markup.list.unchecked.markdown (#set! conceal ""))
((task_list_marker_checked) @markup.list.checked.markdown (#set! conceal "󰄲"))
