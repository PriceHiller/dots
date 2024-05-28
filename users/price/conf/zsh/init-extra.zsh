() {
    if [[ -n "$XDG_CONFIG_HOME" && -r "$XDG_CONFIG_HOME/zsh/zsh" ]]; then
        source "$XDG_CONFIG_HOME/zsh/zsh"
    fi
}
