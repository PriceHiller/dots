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
nvim-env() {
	# If using ZSH uncomment the line below, requires emulate
	emulate -L ksh
	local nvim_env
	local nvim_env_path
	local nvim_env_full_path

	nvim_env="${1:-primary}"
	nvim_env_path="${NVIM_ENVS_DIR}"
	nvim_env_full_path="$nvim_env_path/$nvim_env"

	declare -A nvim_syml_paths=(["$HOME/.config/nvim"]="$nvim_env_full_path/config" ["$HOME/.local/share/nvim"]="$nvim_env_full_path/share")
	mkdir -p "${nvim_env_full_path}/share"

	local red='\033[0;31m'
	local cyan='\033[0;36m'
	local green='\033[0;32m'
	local light_green='\033[1;32m'
	local reset='\033[0m'

	# Check that the given environment exists
	if [[ ! -d "$nvim_env_full_path" ]]; then
		printf "${red}Error:\n\tUnable to locate environment, ${reset}\"${cyan}%s\"\n\t\"%s\"\n${reset}" "$nvim_env" "$nvim_env_full_path" >&2
		return 1
	fi

	local symlink_src
	local symlink_dst
	for syml_key in "${!nvim_syml_paths[@]}"; do
		symlink_src="${nvim_syml_paths[$syml_key]}"
		symlink_dst="$syml_key"

		# Check that the configuration path exist from our env
		if [[ ! -d "$symlink_src" ]]; then
			printf "${red}ERROR:\n\tUnable to find configuration:${reset} \"${cyan}%s${reset}\"${red} in environment ${reset}\"${cyan}%s${reset}\"${red}\n\tConsider creating it with ${reset} \"${cyan}mkdir -p %s${reset}\"\n" "$symlink_src" "$nvim_env" "$symlink_src" >&2
			return 1
		fi

		# If a directory (not a symlink) exists in where we want to write a symlink refuse to overwrite
		if [[ -r "$symlink_dst" ]] && [[ ! -L "$symlink_dst" ]]; then
			printf "${red}ERROR:\n\tNeovim configuration to be replaced is not a symlink, please remove the files before proceeding, issue file:${reset}\n\t\"${cyan}%s${reset}\"\n" "$symlink_dst" >&2
			return 1
		fi

		# If we find an existing symlink, try to delete it
		if [[ -L "$symlink_dst" ]]; then
			local linked_sym
			linked_sym="$(readlink "$symlink_dst")"
			printf "${light_green}Attemping to remove symlink:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$linked_sym" "$symlink_dst"
			if ! rm "$symlink_dst"; then
				printf "${red}ERROR:\n\tFailed to remove symlink:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$linked_sym" "$symlink_dst" >&2
				return 1
			else
				printf "${light_green}Successfully removed symlink:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$linked_sym" "$symlink_dst"
			fi
		fi

		# Actually write the env now we're past our guards
		printf "${light_green}Linking:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$symlink_src" "$symlink_dst"
		if ! ln -s "$symlink_src" "$symlink_dst"; then
			printf "${red}ERROR:\n\tFailed to link:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$symlink_src" "$symlink_dst" >&2
			return 1
		else
			printf "${light_green}Successfully linked:${reset}\n\t${cyan}%s${reset} -> ${cyan}%s${reset}\n" "$symlink_src" "$symlink_dst"
		fi
		printf "${green}%.s─${reset}" $(seq 1 $(tput cols))
		printf "\n"
	done
}

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

