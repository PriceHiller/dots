configure() {

}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"
	source "${wkdir}/fzf-tab/fzf-tab.plugin.zsh"
	source "${wkdir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source "${wkdir}/zsh-completions/zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	eval "$(lua "${wkdir}/z.lua/z.lua" --init zsh enhanced once)"

	configure
}

init
