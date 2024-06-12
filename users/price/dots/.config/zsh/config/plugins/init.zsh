configure() {
	if [ -n "${commands[fzf-share]}" ]; then
	  source "$(fzf-share)/key-bindings.zsh"
	  source "$(fzf-share)/completion.zsh"
	fi
	prompt_nix_shell_setup
}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"
	source "${wkdir}/fzf-tab/fzf-tab.plugin.zsh"
	source "${wkdir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source "${wkdir}/zsh-completions/zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source "${wkdir}/nix-zsh-completions/nix-zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-nix-shell/nix-shell.plugin.zsh"

	FPATH="${FPATH}:${wkdir}/nix-zsh-completions"

    export _ZL_DATA="${_ZL_DATA:-"$XDG_CACHE_HOME/zlua"}"
	eval "$(lua "${wkdir}/z.lua/z.lua" --init zsh enhanced once)"

	[[ -r "${XDG_CONFIG_HOME}/fzf/fzf.zsh" ]]  && source "${XDG_CONFIG_HOME}/fzf/fzf.zsh"

	configure
}

init
