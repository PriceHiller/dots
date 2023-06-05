#!/usr/bin/env bash

main() {
	local package_updates
	package_updates="$(checkupdates | cut -d " " -f1)"
	package_update_number="$(printf "%s" "${package_updates}" | wc -l)"

	# Limit the number of results shown to ten, add trailing ellipsis
	if ((package_update_number > 10)); then
		package_updates="$(printf "%s" "${package_updates}" | head -n 10)"
		package_updates+="\n..."
	elif (( package_update_number == 0 )); then
		# Don't return anything if there are no updates available
		return 0
	fi

	printf '{"text": "%s", "tooltip": "%s"}\n' "${package_update_number}" "${package_updates//$'\n'/\\n}"
}

main
