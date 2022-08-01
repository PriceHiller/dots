# This has to break spec because omz will source EVERYTHING inside of the
# omz directory :(

configure() {

	export plugins=(
		git
		zsh-autosuggestions
		zsh-completions
		zsh-syntax-highlighting
		colored-man-pages
		pip
		extract
		fzf-tab
		aws
		docker
		docker-compose
		nmap
		npm
		python
		zsh-vi-mode
		zsh-kitty
		rust
		dotnet
	)

	if [[ "${OSTYPE}" = "darwin"* ]]; then
		plugins +=(
			macos
		)
	fi

	source "${ZSH}/oh-my-zsh.sh"

}

init() {
	local wkdir="${BASE_ZSH_CONFIG_DIR}/config/omz"
	export ZSH="${HOME}/.local/share/omz"
	export ZSH_CUSTOM="${wkdir}/"

}

init
