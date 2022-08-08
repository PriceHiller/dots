#!/usr/bin/env bash

main() {
	local class
	local text=""
	class="$(playerctl metadata --format '{{lc(status)}}')"

	local player_ctl_info="$(playerctl metadata --format '{{ artist }} | {{ title }} | {{ album }}')"

	if [[ "${class}" == "playing" ]]; then
		text="▶ ${player_ctl_info}"

	elif [[ "${class}" == "paused" ]]; then
		text="⏸︎ ${player_ctl_info}"
	fi

	printf '{"class": "%s", "text": "%s"}\n' "${class}" "${text}"

}

main
