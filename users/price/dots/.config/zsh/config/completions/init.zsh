#!/usr/bin/env zsh

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/completions"
	FPATH="${FPATH}:${wkdir}/completions"

	autoload -Uz compinit bashcompinit
    export ZSH_COMP_DUMPFILE="${XDG_CACHE_HOME}/zcompdump"
    compinit -d "${ZSH_COMP_DUMPFILE}"

	if command -v aws_completer >/dev/null 2>&1; then
		complete -C "$(command -v aws_completer)" aws
	fi
}

init