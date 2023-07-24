#!/usr/bin/env bash

main() {
	set -o pipefail
	local package_updates
	package_updates="$(checkupdates | cut -d " " -f1)"

	if [[ "${?}" != 0 ]]; then
		return 0
	fi

	package_update_number="$(wc -l <<<"${package_updates}")"

	# Limit the number of results shown to ten, add trailing ellipsis
	package_updates="$(printf "%s" "${package_updates}" | head -n 10)"
	if ((package_update_number > 10)); then
		package_updates+="\n..."
	fi

	printf '{"text": "%s", "tooltip": "%s"}\n' "${package_update_number}" "${package_updates//$'\n'/\\n}"
}

main
