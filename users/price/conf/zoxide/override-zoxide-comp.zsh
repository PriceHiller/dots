export _ZO_FZF_OPTS="--preview 'eza --color=always -1 --all --classify --icons --group-directories-first --git {2}' --info=inline --cycle --input-border=rounded --style=full --layout=reverse --height=80%"
# Improved zoxide tab completion (I don't care about local dirs)
__zoxide_z_complete () {
    __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})"  || __zoxide_result=''
    compadd -Q ""
    \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
    \builtin printf '\e[5n'
    return 0
}

