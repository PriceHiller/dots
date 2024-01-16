#!/usr/bin/env zsh

configure() {
	export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
	export XDG_CACHE_HOME="${XDG_CONFIG_HOME:-$HOME/.cache}"
	export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
	export XDG_STATE_HOME="${XDG_DATA_HOME:-$HOME/.local/state}"
	export XDG_DATA_DIRS="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
	export XDG_CONFIG_DIRS="${XDG_CONFIG_DIRS:-/etc/xdg}"
}

init() {
	configure
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config"
	source "${wkdir}/profile/init.zsh"
	source "${wkdir}/style/init.zsh"
	source "${wkdir}/omz/init.zsh"
	source "${wkdir}/plugins/init.zsh"
	source "${wkdir}/completions/init.zsh"
	source "${wkdir}/themes/init.zsh"
}

init
unset -f init
unset -f configure
