; Thank you: https://github.com/dmtrKovalenko/my-nvim-config/blob/main/queries/gitcommit/injections.scm
; Inject text language for word-level Git keyword highlighting
; Text parser should tokenize individual words
((message_line) @injection.content
 (#set! injection.language "markdown"))
