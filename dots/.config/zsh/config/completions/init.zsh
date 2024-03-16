#!/usr/bin/env zsh

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/completions"
	FPATH="${FPATH}:${wkdir}/completions"

	autoload bashcompinit && bashcompinit
	autoload -Uz compinit && compinit

	if command -v aws_completer >/dev/null 2>&1; then
		complete -C "$(command -v aws_completer)" aws
	fi
}

init
