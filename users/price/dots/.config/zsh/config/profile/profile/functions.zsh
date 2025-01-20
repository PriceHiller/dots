#!/usr/bin/env zsh

# NOTE: Mac Specific Functions
if [[ "${OSTYPE}" = "darwin"* ]]; then
	yubikey-manage() {
		local yubikey_mngr_base_path=/Applications/YubiKey\ Manager.app/Contents
		local python_base_path="${yubikey_mngr_base_path}"/Frameworks/Python.framework/Versions

		local python_version
		# Find where the current symlink points to for yubikey's env
		python_version="$(readlink -f "${python_base_path}"/Current)"
		# Get the version number off the end of the path for python
		python_version="${python_version##*/}"

		PYTHONHOME="${python_base_path}/Current" \
			PYTHONPATH="${python_base_path}/Current/lib/python${python_version}/site-packages" \
			"${yubikey_mngr_base_path}/MacOS/ykman-gui" --log-level DEBUG
	}
fi

### FZF ###
wgrep() {
	local selection
	read -r selection < =(rg --color=always --line-number --no-heading --smart-case "${*:-}" | fzf --ansi \
		--color "hl:-1:underline,hl+:-1:underline:reverse" \
		--delimiter : \
		--preview 'bat --color=always {1} --highlight-line {2}' \
		--preview-window 'up,60%,border-bottom,+{2}+3/3,~3')

	# This crazy shit handles egde cases of files having colons (:) in them
	selection=$(rev <<< $selection | cut -d ':' -f 3- | rev)
	if [[ -n "${selection}" ]]; then
		[[ -r "${selection}" ]] && "${EDITOR}" "${selection}" || printf "Cannot open %s\n" "${selection}"
	fi

}

pods() {
	FZF_DEFAULT_COMMAND="kubectl get pods --all-namespaces" \
		fzf --info=inline --layout=reverse --header-lines=1 \
		--prompt "$(kubectl config current-context | sed 's/-context$//')> " \
		--header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
		--bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
		--bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
		--bind 'ctrl-o:execute:${EDITOR:-vim} <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty' \
		--bind 'ctrl-r:reload:$FZF_DEFAULT_COMMAND' \
		--preview-window up:follow \
		--preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
}

killer() {
	(
		date
		ps -ef
	) |
		fzf --bind='ctrl-r:reload(date; ps -ef)' \
			--header=$'Press CTRL-R to reload\n\n' --header-lines=2 \
			--preview='echo {}' --preview-window=down,3,wrap \
			--layout=reverse --height=80% | awk '{print $2}' | xargs kill -"${1:-9}"
}

### Wezterm ###
wezterm-install-terminfo() {
	tempfile=$(mktemp) \
		&& curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/master/termwiz/data/wezterm.terminfo \
		&& tic -x -o ~/.terminfo $tempfile \
		&& rm $tempfile
}

### Rust ###
update_cargo_crates() {
	cargo install "$(cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d" ")"
}

### Neovim ###
DAP-Python-Gen() {
	local module
	module="${1}"
	name="${2:=Local Module}"

	mkdir -p .vscode
	cat <<__EOF__ >.vscode/launch.json
{
	"configurations": [
		{
			"name": "Launch ${name}",
			"type": "python",
			"request": "launch",
			"module": "${module}"
		}
	]
}
__EOF__
}

### Python ###
chr() {
	python3 -c "print(chr(int('${1}')))"
}

ord() {
	python3 -c "print(ord('${1}'))"
}

### Git ###
gbf() {
	local remote
	local default_branch
	remote="${1:=origin}"
	default_branch="$(git remote show "$remote" | awk '/HEAD branch/ {print $NF}')"
	git fetch "$remote" "$default_branch":"$default_branch"
}

### Miscellaneous ###
browser_search() {
	local browser
	local search_term
	browser="firefox"
	search_term="${*}"
	eval "$browser -search \"$search_term\""
}

tmp() {
	(
		export MY_SHLVL=tmp:$MY_SHLVL
		export od=$PWD
		tmp=$(mktemp -d)
		export tmp
		trap 'rm -rf ${tmp}' 0
		if ! cd "$tmp"; then
			printf "%s \"%s\"\n" "Unable to cd into" "$tmp"
			exit 1
		fi
		if [ "$1" = "" ]; then
			"$SHELL" -l
		else
			[ "$1" = "-l" ] && {
				shift
				set "${@}" ";" "$SHELL -l"
			}
			eval "${@}"
		fi
	)
}

date_iso_8601() {
	date +%Y-%m-%dT%H:%M:%S
}

Known-Hosts() {
	local prev_ifs
	prev_ifs="$IFS"
	while IFS=$'\n' read -r line; do
		echo "$line" | cut -d " " -f1
	done <~/.ssh/known_hosts
	IFS="$prev_ifs"
}

TCPDump-Capture() {
	tcpdump -qns 0 -X -r "${1}"
}

Unzip () {
	for item in "${*[@]}"; do
		unzip -d "${item%.zip}" "${item}" || return
		printf "\n"
	done
}

File-Strip-Blank() {
	for file in "${*[@]}"; do
		mv "${file}" "${file//[[:blank:]]/-}"
	done
}

precmd() {
	if [[ -n "${__SHELL_LAUNCHED}" ]]; then
		if [[ -n "${WEZTERM_PANE}" ]]; then
			echo "\x1b]0;wezterm\x1b\\"
		else
			echo "\x1b]0;${2}\x1b\\"
		fi
	fi
}

preexec() {
	[[ -z "${__SHELL_LAUNCHED}" ]] && export __SHELL_LAUNCHED=true
}

# Editor with single letter
e() {
	eval "${EDITOR} ${@}"
}

# Open file with default program and detach
o() {
	local in="${@}"
	xdg-open "${@}" & disown
}
