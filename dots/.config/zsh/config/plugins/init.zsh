configure() {
	zvm_after_init() {
		local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"

		# source fzf
		[[ -r "${XDG_CONFIG_HOME}/fzf/fzf.zsh" ]]  && source "${XDG_CONFIG_HOME}/fzf/fzf.zsh"

		# activate syntax highlighting
		source "${wkdir}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	}

}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"
	source "${wkdir}/fzf-tab/fzf-tab.plugin.zsh"
	source "${wkdir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source "${wkdir}/zsh-completions/zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-vi-mode/zsh-vi-mode.zsh"
	source "${wkdir}/nix-zsh-completions/nix.plugin.zsh"
	FPATH="${FPATH}:${wkdir}/nix-zsh-completions"
	eval "$(lua "${wkdir}/z.lua/z.lua" --init zsh enhanced once)"

	configure
}

init
