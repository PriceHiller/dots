#!/usr/bin/env bash

log() {
	local monitor="${1}"
	local msg="${2}"
	printf "%s: %s\n" "${monitor}" "${msg}"
}

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
				log "SSID" "Wifi Disconnected"
				notify-send "${notify_title}" "Wifi Disconnected" -a "${notify_app}"
			else
				log "SSID" "Wifi Connected to ${ssid}"
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
				printf "Laptop screen was shut, attempting to disable it...\n"
				if hyprctl keyword monitor "eDP-1, disable"; then
					local msg="Laptop screen successfully disabled"
					log "Laptop Clamshell" "${msg}"
					notify-send "Laptop Clamshell Error" "${msg}" -a "Laptop Clamshell"
				else
					local msg="Received an error when disabling the laptop screen in clamshell mode!\n"
					log "Laptop Clamshell" "${msg}"
					notify-send "Laptop Clamshell Error" "${msg}" -a "Laptop Clamshell"
				fi
			fi
			;;
		esac
		sleep 1
	done
}
monitor-ssid &
monitor-laptop-lid &
wait
