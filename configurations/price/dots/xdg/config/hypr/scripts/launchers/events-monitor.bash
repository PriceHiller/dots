#!/usr/bin/env bash

monitor-dir() {
	local event="${1}"
	local directory="${2}"
	local message_title="${3}"

	inotifywait -m -e "${event}" --format '%w%f' "${directory}" | while read -r NEWFILE; do
		notify-send "${message_title}" "${NEWFILE}" -a "Device Monitor"
	done
}

monitor-ssid() {
	local notify_title="Wifi State Changed"
	local notify_app="Wifi State"
	local previous_ssid=""
	local ssid
	while :; do
		ssid="$(iwctl station wlan0 show | grep 'Connected network' | awk '{print $3}')"
		ssid="$(printf "%s" "${ssid}" | xargs)"
		if [[ "${ssid}" != "${previous_ssid}" ]]; then
			if [[ -z "${ssid// /}" ]]; then
				notify-send "${notify_title}" "Wifi Disconnected" -a "${notify_app}"
			else
				notify-send "${notify_title}" "Wifi Connected to ${ssid}" -a "${notify_app}"
			fi
			previous_ssid="${ssid}"
		fi
		sleep 1
	done
}

monitor-laptop-lid() {
	local laptop_lid_state
	while :; do
		laptop_lid_state="$(</proc/acpi/button/lid/LID0/state)"
		laptop_lid_state="${laptop_lid_state##* }"
		laptop_lid_state="${laptop_lid_state^^}"
		case "${laptop_lid_state}" in
		"CLOSED")
			if hyprctl monitors -j | jq -er '.[] | select(.name=="eDP-1") | .name' >/dev/null; then
				hyprctl keyword monitor "eDP-1, disable" >/dev/null && printf "Disabled laptop screen as the laptop was shut\n"
			fi
			;;
		esac
		sleep 1
	done
}
kill -9 "$(pgrep -f "${BASH_SOURCE[0]}" | grep -v "${$}")"
monitor-ssid &
monitor-laptop-lid &
wait
