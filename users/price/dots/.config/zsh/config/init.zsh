#!/usr/bin/env zsh

configure() {
}

init() {
	configure
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config"
	source "${wkdir}/profile/init.zsh"
	source "${wkdir}/style/init.zsh"
	source "${wkdir}/themes/init.zsh"
}

init
unset -f init
unset -f configure
