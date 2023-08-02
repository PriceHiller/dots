#!/usr/bin/env zsh

### Exa ###
if command -v exa >/dev/null 2>&1; then
	alias ls="exa --icons --group --group-directories-first --octal-permissions --classify"
	alias l="ls -alh"
	alias ll="l"
	alias tree="ls --tree"
fi

### Git ###
if command -v git >/dev/null 2>&1; then

	if command -v nvim >/dev/null 2>&1; then
		alias g="nvim -c 'Neogit'"
	fi

	alias gc="git commit"
	alias gcm="git commit -m"
	alias ga="git add"
	alias gp="git push"
	alias gb="git branch"
	alias gco="git checkout"
	alias gpl="git pull"
	alias gs="git status"
	alias gst="git stash"
	alias gstc="git stash clear"
	alias gsw="git switch"
	alias gd="nvim -c 'DiffviewOpen' -R"
	alias gr="git remote"
	alias gl="git log"
	alias glo="git log --oneline"
	alias gw="git worktree"
	alias gwa="git worktree add"
	alias gwr="git worktree remove"
	alias git-remote="git config --get remote.origin.url"
	alias git-head-default="git rev-parse --abbrev-ref origin/HEAD | cut -d '/' -f2"
	alias gbc="git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'"
fi

### Mac ###
if [[ "$OSTYPE" = "darwin"* ]]; then
	alias c="pbcopy"
	alias p="pbpaste"
	alias grep="ggrep"
	alias find="gfind"
	alias sed="gsed"
fi

### Linux ###
if [[ "${OSTYPE}" == "linux-gnu"* ]]; then
	if command -v wl-copy >/dev/null 2>&1; then
		alias c="wl-copy"
		alias p="wl-paste"
	fi

	if ! command -v open >/dev/null 2>&1 && command -v xdg-open >/dev/null 2>&1; then
		alias open="xdg-open"
	fi
fi

### Bat ###
if command -v bat >/dev/null 2>&1; then
	alias cat="bat"
fi

### Wezterm ###
if command -v wezterm >/dev/null 2>&1; then
	alias img="wezterm imgcat"
fi

### Misc ###
alias e="${EDITOR}"
alias Get-Public-IPV4="dig @resolver4.opendns.com myip.opendns.com +short -4"
alias Get-Public-IPV6="dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6"
alias cv="command -v"

if command -v arecord >/dev/null 2>&1; then
	alias audio-record="arecord -f dat -r 41000 -d 5 $(date_iso_8601).wav"
fi
