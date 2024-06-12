#!/usr/bin/env -S nix --extra-experimental-features "flakes nix-command" shell nixpkgs#bash nixpkgs#git --command bash
# vim: ft=sh

set -euo pipefail

main() {
	local root
	root="$(git rev-parse --show-toplevel)"

	local files=()
	local excluded_files=()
	local excluded_dirs=(
		"${root}/users/price/dots/.config/vesktop"
	)

	while IFS= read -r file; do
		local add_file=true
		local fpath="${root}/${file}"
		if [[ -r "$fpath" ]]; then
			for excluded_dir in "${excluded_dirs[@]}"; do
				if [[ "$fpath" == "$excluded_dir"* ]]; then
					add_file=false
					break
				fi
			done

			for excluded_file in "${excluded_files[@]}"; do
				if [[ "$fpath" == "$excluded_file" ]]; then
					add_file=false
					break
				fi
			done

			if [[ "$add_file" == true ]]; then
				files+=("$fpath")
			fi
		fi
	done < <(git diff --name-only --staged --diff-filter=d)

	if ((${#files[@]} > 0)); then
		Fmt -- "${files[@]}"
	fi
}

main "${@}"
