configure() {
	# Enable Caching
	zstyle ':completion:*' use-cache on
    zstyle ':completion:*' menu no

	### Fzf Tab Configuration ###
	zstyle ':fzf-tab:*' fzf-pad 100
    zstyle ':fzf-tab:*' use-fzf-default-opts yes
    zstyle ':fzf-tab:*' switch-group '<' '>'

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
		'[[ -f ${realpath} ]] && bat -P --color=always --style=header,grid,numbers,snip ${realpath} || eza --color=always -1 --all --classify --icons --group-directories-first --git ${realpath}'

	# Highlight the current autocomplete option
	zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

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
