#!/usr/bin/env zsh

configure() {
	autoload -U +X bashcompinit && bashcompinit
}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config"
	source "${wkdir}/themes/init.zsh"
	source "${wkdir}/profile/init.zsh"
	source "${wkdir}/style/init.zsh"
	source "${wkdir}/omz/init.zsh"
	source "${wkdir}/plugins/init.zsh"
	source "${wkdir}/completions/init.zsh"
	configure
}

init
