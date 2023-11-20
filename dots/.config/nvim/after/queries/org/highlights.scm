; extends
((bullet)
 @punctuation.special
 (#any-of? @punctuation.special "-" "*" "+")
 (#set! conceal "•"))
