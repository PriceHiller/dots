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

	printf '{"class": "%s", "text": "%s"}\n' "${class}" "${text}"
}

album-info-dbus-update() {
	while IFS= read -r _; do
		get-album-info
	done < <(busctl --user monitor --json=short --match 'interface=org.mpris.MediaPlayer2.Player,type=signal')
}

album-info-poller() {
	while sleep 1; do
		get-album-info
	done
}

main() {
	album-info-dbus-update &
	album-info-poller &
	wait
}

main
