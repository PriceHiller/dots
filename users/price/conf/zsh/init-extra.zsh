emit_osc7_dir_change() {
    printf "\033]7;file://$PWD\033\\"
}

chpwd_functions=(${chwpd_functions[@]} "emit_osc7_dir_change")

_prompt_executing=""
function __emit_osc133() {
    local ret="$?"
    if [[ "$_prompt_executing" != "0" ]]; then
        _PROMPT_SAVE_PS1="$PS1"
        _PROMPT_SAVE_PS2="$PS2"
        PS1=$'%{\e]133;P;k=i\a%}'$PS1$'%{\e]133;B\a\e]122;> \a%}'
        PS2=$'%{\e]133;P;k=s\a%}'$PS2$'%{\e]133;B\a%}'
    fi
    if [[ "$_prompt_executing" != "" ]]; then
        printf "\033]133;D;%s;aid=%s\007" "$ret" "$$"
    fi
    printf "\033]133;A;cl=m;aid=%s\007" "$$"
    _prompt_executing=0
}

function __restore_prompt_osc133() {
    PS1="$_PROMPT_SAVE_PS1"
    PS2="$_PROMPT_SAVE_PS2"
    printf "\033]133;C;\007"
    _prompt_executing=1
}

preexec_functions+=(__restore_prompt_osc133)
precmd_functions+=(__emit_osc133)


if [[ -n "$XDG_CONFIG_HOME" && -r "$XDG_CONFIG_HOME/zsh/zsh" ]]; then
    source "$XDG_CONFIG_HOME/zsh/zsh"
fi

