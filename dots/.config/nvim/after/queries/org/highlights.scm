; extends
((bullet)
 @punctuation.special
 (#any-of? @punctuation.special "-" "*" "+")
 (#set! conceal "•"))

((checkbox !status) @markup.list.unchecked (#set! conceal ""))

((checkbox
   status:
   (expr)
   @org-checkbox-content (#any-of? @org-checkbox-content "x" "X")) @markup.list.checked
 (#set! conceal "󰄲"))

((checkbox
   status:
   (expr)
   @org-checkbox-content (#any-of? @org-checkbox-content "-")) @markup.list.indeterminate
 (#set! conceal "󰍵"))

; Table highlights
(row
  "|" @punctuation.special)
(cell
  "|" @punctuation.special)
(table
  (row
    (cell (contents) @markup.heading))
  (hr) @punctuation.special)
