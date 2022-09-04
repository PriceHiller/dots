#!/usr/bin/env zsh

export PATH="${PATH}:${HOME}/.local/bin"

### Shell ###
export LANG=en_US.UTF-8
export ZSH_HIGHLIGHT_MAXLENGTH=10000
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=2
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)


### FZF ###
export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git --color=always'
export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --info=inline --border --margin=1 --ansi"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

### Python ###
export PYENV_ROOT="${HOME}/.local/share/pyenv"
export PATH="${PATH}:${PYENV_ROOT}/bin"
eval "$(pyenv init -)"

### MAC ##
if [[ "$OSTYPE" = "darwin"* ]]; then
	# Set Homebrew env variables
	eval "$(/opt/homebrew/bin/brew shellenv)"

	export PATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin:$PATH"
	export PATH="${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin:$PATH"
	export PATH="/Applications/Firefox Developer Edition.app/Contents/MacOS:$PATH"
	export PATH="${HOME}/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH"
	export MANPATH="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnuman:$MANPATH"

	complete -o nospace -C ${HOMEBREW_PREFIX}/bin/terraform terraform

	# LLDB
	export PATH="${HOMEBREW_PREFIX}/opt/llvm/bin:$PATH"

	_import_custom_bash_completions() {
		local custom_comps=(
			"az"
		)
		for file in "${custom_comps[@]}"; do
			source "${HOMEBREW_PREFIX}/etc/bash_completion.d/${file}"
		done
	}

	# Homebrew completions
	if type brew &>/dev/null; then
		# Zsh
		FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
		_import_custom_bash_completions

		autoload -Uz compinit
		compinit
	fi

fi

### Java ###
if [[ -r "${usr/libexec/java_home}" ]]; then
	export JAVA_HOME="$(/usr/libexec/java_home)"
fi

### Editor ###
if command -v nvim >/dev/null 2>&1; then
	export EDITOR=nvim
	export VISUAL=nvim
	export MANPAGER="nvim +Man!"
	export NVIM_ENVS_DIR="${HOME}/.nvim-environments"
elif command -v vim >/dev/null 2>&1; then
	export EDITOR=vim
	export VISUAL=vim
else
	export EDITOR=vi
	export VISUAL=less
fi

### Rust ###
export CARGO_HOME="${HOME}/.local/share/cargo"
source "${CARGO_HOME}/env"
export RUSTUP_HOME="${HOME}/.local/share/rustup"
export PATH="${PATH}:${CARGO_HOME}/bin"

## Dotnet ###
export PATH="${PATH}:${XDG_DATA_HOME}/dotnet"

### Go ###
export GOPATH="${HOME}/.local/share/go"
export PATH="${PATH}:/usr/local/go/bin:${GOPATH}/bin"

### Direnv ###
eval "$(direnv hook zsh)"

### Terminal Specific ###
# If using the kitty terminal we want to set our TERM var to be xterm as kitty will send
# kitty-xterm which causes a fucking headache and a half due to ncurses not containing
# that by default
if [[ "$TERM" = *"xterm-kitty"* ]]; then
	alias ssh="TERM=xterm-256color ssh"
	alias icat="kitty +kitten icat"
	__kitty_complete
fi

if [[ "${TERM}" = "wezterm" ]]; then
	alias ssh="TERM=xterm-256color ssh"
fi

### Miscellaneous ###
export AWS_CLI_AUTO_PROMPT=on
export DOCKER_BUILDKIT=1
export NOTES_DIR="${HOME}/.notes"
export GITLAB_HOST="https://gitlab.orion-technologies.io"
