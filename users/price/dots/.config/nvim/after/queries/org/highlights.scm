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
 (#set! @markup.list.checked conceal "󰄲"))

((checkbox
   status:
   (expr)
   @org-checkbox-content (#any-of? @org-checkbox-content "-")) @markup.list.indeterminate
 (#set! @markup.list.indeterminate conceal "󰍵"))

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

; Improved timestamp highlights
(entry
  timestamp:
  (timestamp
    ("<"  @org.timestamp.active.delimiter)
    (">" @org.timestamp.active.delimiter)))
(entry
  timestamp:
  (timestamp
    ("["  @org.timestamp.inactive.delimiter)
    ("]" @org.timestamp.inactive.delimiter)))

; Improved list delimiter highlights
(tag_list ":" @org.tag.delimiter)
(tag) @org.tag.body
