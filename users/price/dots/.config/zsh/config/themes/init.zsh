#!/usr/bin/env

# It may seem strange that themes are configured separate from oh-my-zsh (omz), as
# oh-my-zsh (omz) does have the capability to set and configure themes. Here's why:
# omz's handling of themes is dogshit. For instance, if I have a ~/.p10k.zsh to
# configure for p10k, I have to now separate logic away from that to handle it
# in a separate location which doesn't expose where the theme is truly coming
# from unless you understand omz. It is TRIVIAL to source a theme file before
# everything else loads, I see little to no reason to have my themes managed by
# omz.

configure() {
	if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
		source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
	fi
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/themes"
	source "${wkdir}/config.zsh"
}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/themes"
	configure
	typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
	source "${wkdir}/powerlevel10k/powerlevel10k.zsh-theme"
}

init
