#!/usr/bin/env options

export SAVEHIST=10000
export HISTSIZE=10000
export HISTFILE="${XDG_CACHE_HOME:-"$HOME"}/zsh_history"
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt AUTO_PARAM_SLASH

setopt EXTENDED_GLOB
setopt NULL_GLOB

setopt AUTO_CD
setopt AUTO_PUSHD

setopt HASH_CMDS
setopt COMBININGCHARS

unsetopt BEEP
