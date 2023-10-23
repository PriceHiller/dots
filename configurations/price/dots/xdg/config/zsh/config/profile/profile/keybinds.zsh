autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
