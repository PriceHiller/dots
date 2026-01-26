#!/usr/bin/env bash

get-album-info() {
	local class
	local text=""
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

	jq \
		--null-input \
		--compact-output \
		--arg class "$class" \
		--arg text "$text" \
		'{"class": $class, "text": $text}'
}

album-info-poller() {
	while IFS= read -r _; do
		get-album-info
	done < <(playerctl metadata -F -f '{{ status }} {{ title }}  {{ album }} {{ artist }}')
}

main() {
	album-info-poller &
	wait
}

main
