configure() {
	prompt_nix_shell_setup
}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"
	source "${wkdir}/fzf-tab/fzf-tab.plugin.zsh"
	source "${wkdir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source "${wkdir}/zsh-completions/zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source "${wkdir}/nix-zsh-completions/nix.plugin.zsh"
	source "${wkdir}/zsh-nix-shell/nix-shell.plugin.zsh"

	# export PATH="${PATH}:${wkdir}/forgit/bin"
	# source "${wkdir}/forgit/forgit.plugin.zsh"

	FPATH="${FPATH}:${wkdir}/nix-zsh-completions"
	eval "$(lua "${wkdir}/z.lua/z.lua" --init zsh enhanced once)"

	# source fzf
	[[ -r "${XDG_CONFIG_HOME}/fzf/fzf.zsh" ]]  && source "${XDG_CONFIG_HOME}/fzf/fzf.zsh"

	configure
}

init
