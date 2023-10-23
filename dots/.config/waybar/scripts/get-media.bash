#!/usr/bin/env bash

get-album-info () {
	local class
	local text=""

	while :; do
		if class="$(playerctl metadata --format '{{lc(status)}}')"; then
			local player_ctl_info
			player_ctl_info="$(playerctl metadata --format '{{ artist }} | {{ title }} | {{ album }}')"

			if [[ "${class}" == "playing" ]]; then
				text="󰎆 ${player_ctl_info}"

			elif [[ "${class}" == "paused" ]]; then
				text="󰏦 ${player_ctl_info}"
			fi
		else
			class="paused"
			text="󰓄 No Media"
		fi

		printf '{"class": "%s", "text": "%s"}\n' "${class}" "${text}"
		sleep .5
	done
}


main() {
	get-album-info
}

main
