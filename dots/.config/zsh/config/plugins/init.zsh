configure() {

}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/plugins"
	source "${wkdir}/fzf-tab/fzf-tab.plugin.zsh"
	source "${wkdir}/zsh-autosuggestions/zsh-autosuggestions.zsh"
	source "${wkdir}/zsh-completions/zsh-completions.plugin.zsh"
	source "${wkdir}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	source "${wkdir}/zsh-vi-mode/zsh-vi-mode.zsh"

	configure
}

init
