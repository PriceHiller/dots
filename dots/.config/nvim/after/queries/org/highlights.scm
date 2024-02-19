; extends
((bullet)
 @markup.list
 (#any-of? @markup.list "-" "*" "+")
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


; Quote highlights
(block
   name: (expr) @org-block-start-name (#any-of? @org-block-start-name "quote" "QUOTE")
   contents: (contents) @markup.quote
   end_name: (expr) @org-block-end-name (#any-of? @org-block-end-name "quote" "QUOTE"))

(block
   name: (expr) @org-block-start-name (#any-of? @org-block-start-name "src" "SRC")
   !parameter
   contents: (contents) @markup.raw.block
   end_name: (expr) @org-block-end-name (#any-of? @org-block-end-name "src" "SRC"))
