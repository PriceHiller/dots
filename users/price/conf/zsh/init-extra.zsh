emit_osc7_dir_change () {
    printf "\033]7;file://$PWD\033\\"
}

chpwd_functions=(${chwpd_functions[@]} "emit_osc7_dir_change")

if [[ -n "$XDG_CONFIG_HOME" && -r "$XDG_CONFIG_HOME/zsh/zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/zsh"
fi
