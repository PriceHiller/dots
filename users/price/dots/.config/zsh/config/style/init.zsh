configure() {
	# Enable Caching
	zstyle ':completion:*' use-cache on
	zstyle ':completion:*' cache-path "${HOME}/.cache/.zcompcache"

	### Fzf Tab Configuration ###
	zstyle ':fzf-tab:*' fzf-pad 100

	# Tab completion for CD/directory navigation
	zstyle ':completion:*:git-checkout:*' sort false
	zstyle ':completion:*:descriptions' format '[%d]'
	zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

	# Tab Completion for Kill
	zstyle ':completion:*:processes' command "ps -ef"
	zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
		'[[ $group == "[process ID]" ]] && ps -w $word'
	zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down,3,wrap

	# Tab completion for Systemd unit status
    zstyle ':fzf-tab:complete:systemctl-(status|(re|)start|(dis|en)able):*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status -- $word'
	# Mac does not have systemctl :pensive:

	# Tab Completion for environment variables
	zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
		fzf-preview 'echo ${(P)word}'

	# Tab Completion for previewing files or directories
	zstyle ':fzf-tab:complete:(mv|cat|bat|cp|rm|chmod|du|viu|nvim|ls|cd|eza):*' fzf-preview \
		'[[ -f ${realpath} ]] && bat -P --color=always --theme="Solarized (dark)" --style=header,grid,numbers,snip ${realpath} || eza -al --no-filesize --no-time --no-user --no-permissions ${realpath}'

	### Generic Oh My Zsh Styles ###

	# Highlight the current autocomplete option
	zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

	# Better SSH/Rsync/SCP Autocomplete
	zstyle ':completion:*:ssh:*' config on

	# Better SSH completions
	h=()
	if [[ -r ~/.ssh/config ]]; then
		h+=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
	fi

	if [[ -r ~/.ssh/known_hosts ]]; then
		h+=(${${$(cat ~/.ssh/known_hosts | awk '{print $1}')/]:*/}/\[/}) 2>/dev/null
	fi

	if [[ $#h -gt 0 ]]; then
		zstyle ':completion:*:ssh:*' hosts $h
		zstyle ':completion:*:scp:*' hosts $h
		zstyle ':completion:*:rsync:*' hosts $h
		zstyle ':completion:*:slogin:*' hosts $h
	fi

	# Git Completions
	zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
		'git diff $word | delta'
	zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
		'git log --color=always $word'
	zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
		'git help $word | bat -plman --color=always'
	zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
		'case "$group" in
		"commit tag") git show --color=always $word ;;
		*) git show --color=always $word | delta ;;
		esac'
	zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
		'case "$group" in
		"modified file") git diff $word | delta ;;
		"recent commit object name") git show --color=always $word | delta ;;
		*) git log --color=always $word ;;
		esac'
}

init() {
	configure
}

init
