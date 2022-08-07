#!/usr/bin/env options

export SAVEHIST=10000
export HISTSIZE=10000
export HISTFILE="${HOME}/.zsh_history"
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS

setopt EXTENDED_GLOB
setopt NULL_GLOB

setopt AUTO_CD
setopt CHASE_DOTS

setopt HASH_CMDS

unsetopt BEEP
