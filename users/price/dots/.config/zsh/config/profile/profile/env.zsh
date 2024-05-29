#!/usr/bin/env zsh

export PATH="${PATH}:${HOME}/.local/bin"

### Shell ###
export ZSH_HIGHLIGHT_MAXLENGTH=10000
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=2
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source ~/.config/zsh/lib/colors.zsh

read -r -d '' TIMEFMT <<-__EOS__
${kanagawa[crystalBlue]}╭────────────────────────────────────────────────────────────────────────────────────╮
│                                       ${kanagawa[roninYellow]}Job${reset_color}${kanagawa[crystalBlue]}                                          │
├────────────────────────────────────────────────────────────────────────────────────╯${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   %J
${kanagawa[crystalBlue]}├────────────────────────────────────────────────────────────────────────────────────╮
│                                      ${kanagawa[roninYellow]}Stats${reset_color}${kanagawa[crystalBlue]}                                         │
├────────────────────────────────────────────────────────────────────────────────────╯${reset_color}
${kanagawa[crystalBlue]}│${reset_color} ${kanagawa[springGreen]}${UNDERLINE}${BOLD}Basic Stats${reset_color}
${kanagawa[crystalBlue]}│${reset_color} ${kanagawa[oniViolet2]}real:${reset_color}                           %E
${kanagawa[crystalBlue]}│${reset_color} ${kanagawa[oniViolet2]}user:${reset_color}                           %U
${kanagawa[crystalBlue]}│${reset_color} ${kanagawa[oniViolet2]}sys:${reset_color}                            %S
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color} ${kanagawa[springGreen]}${UNDERLINE}${BOLD}Detailed Stats${reset_color}
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}CPU${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}CPU Percentage:${reset_color}               %P
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}Signals${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Signals Received:${reset_color}             %k
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}Memory${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Max Memory Used:${reset_color}              %M KB
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Total Space Used:${reset_color}             %K KB
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Average Shared Space Used:${reset_color}    %X KB
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Average Unshared Space Used:${reset_color}  %D KB
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}Page Faults${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Major Page Faults:${reset_color}            %F
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Minor Page Faults:${reset_color}            %R
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}I/O Operations${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Input Operations:${reset_color}             %I
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Output Operations:${reset_color}            %O
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}Context Switches${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Voluntary Context Switches:${reset_color}   %w
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Involuntary Context Switches:${reset_color} %c
${kanagawa[crystalBlue]}│${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[carpYellow]}${UNDERLINE}Socket Messages${reset_color}
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Socket Messages Sent:${reset_color}         %s
${kanagawa[crystalBlue]}│${reset_color}   ${kanagawa[oniViolet2]}Socket Messages Received:${reset_color}     %r
${kanagawa[crystalBlue]}╰${reset_color}
__EOS__

export TIMEFMT
export REPORTTIME=600

### FZF ###
export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git --color=always'
export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --info=inline --border --margin=1 --ansi"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

### Python ###
export PATH="${PATH}:${HOME}/.local/share/poetry/bin"

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
	fi

fi

### Java ###
if [[ -r "${usr/libexec/java_home}" ]]; then
	export JAVA_HOME="$(/usr/libexec/java_home)"
fi

# ### Editor ###
() {
	local new_editor
	local new_visual
	local new_manpager
	if command -v nvim >/dev/null 2>&1; then
		new_editor=nvim
		new_visual=nvim
		new_manpager="nvim +Man!"
	elif command -v vim >/dev/null 2>&1; then
		new_editor=vim
		new_visual=vim
		new_manpager=less
	else
		new_editor=vi
		new_visual=vi
		new_manpager=less
	fi

    if [[ -n "${new_editor}" ]]; then
        export EDITOR="${new_editor}"
        export VISUAL="${new_visual}"
        export MANPAGER="${new_manpager}"
    fi
}

### Rust ###
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
if [[ -r "${CARGO_HOME}/env" ]]; then
    source "${CARGO_HOME}/env"
fi
export PATH="${PATH}:${CARGO_HOME}/bin"

## Dotnet ###
export DOTNET_CLI_HOME="${XDG_DATA_HOME}/dotnet"
export DOTNET_ROOT="${XDG_DATA_HOME}/dotnet"
export PATH="${PATH}:${XDG_DATA_HOME}/dotnet"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export NUGET_PACKAGES="${XDG_DATA_HOME}/NugetPackages"
export OMNISHARPHOME="${XDG_CONFIG_HOME}/omnisharp"
export PATH="${PATH}:${HOME}/.dotnet/tools"

### Go ###
export GOPATH="${XDG_DATA_HOME}/go"
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
fi

if [[ "${TERM}" = "wezterm" ]]; then
	alias ssh="TERM=xterm-256color ssh"
fi

### Miscellaneous ###
export AWS_CLI_AUTO_PROMPT=on
export DOCKER_BUILDKIT=1
export NOTES_DIR="${HOME}/.notes"
export GITLAB_HOST="https://gitlab.orion-technologies.io"
export SSLKEYLOGFILE="${XDG_DATA_HOME}/ssl-key-log.log"
export POWERSHELL_TELEMETRY_OPTOUT=true

### NPM ###
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME}/npm/npmrc"
export NPM_CONFIG_PREFIX="${XDG_DATA_HOME}/npm-global"
export PATH="${PATH}:${NPM_CONFIG_PREFIX}/bin"
