#!/usr/bin/env -S nix --extra-experimental-features "flakes nix-command" shell nixpkgs#bash nixpkgs#git --command bash
# vim: ft=sh

set -euo pipefail

main() {
	local root
	root="$(git rev-parse --show-toplevel)"

	local files=()

	while IFS= read -r file; do
		local fpath="${root}/${file}"
		if [[ -r "${fpath}" ]]; then
			files+=("${fpath}")
		fi
	done < <(git ls-tree --full-name --full-tree --name-only -r HEAD)

	"${root}/scripts/fmt.bash" -- "${files[@]}"
}

main "${@}"
