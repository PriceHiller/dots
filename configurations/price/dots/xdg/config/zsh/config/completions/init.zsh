#!/usr/bin/env zsh

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/completions"
	FPATH="${FPATH}:${wkdir}/completions"

	autoload -Uz compinit
	compinit
}

init
