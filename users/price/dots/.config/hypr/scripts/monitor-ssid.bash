#!/usr/bin/env bash

log() {
	local title="Wifi State Changed"
	local app="Wifi State"
	local level="INFO"
	if (($# > 1)); then
		local level="${1}"
	fi
	local msg="${*}"
	case "${level^^}" in
	"TRACE")
		printf "[TRACE] %s: %s\n" "$title" "$msg"
		;;
	"INFO")
		printf "[INFO] %s: %s\n" "$title" "$msg"
		notify-send "$title" "$msg" -a "$app"
		;;
	"ERROR")
		printf "[ERROR] %s: %s\n" "$title" "$msg"
		notify-send "$title" "$msg" -a "$app" -u "critical"
		;;
	*)
		printf "INVALID LOG LEVEL PASSED!\n" >&2
		return 1
		;;
	esac
	printf "Laptop Clamshell: %s\n""$msg"
}

monitor-ssid() {
	local previous_ssid=""
	local ssid
	while :; do
		ssid="$(iwctl station wlan0 show | grep 'Connected network' | awk '{print $3}')"
		ssid="$(printf "%s" "$ssid" | xargs)"
		if [[ "$ssid" != "$previous_ssid" ]]; then
			if [[ -z "${ssid// /}" ]]; then
				log "Wifi Disconnected"
			else
				log "Wifi Connected to ${ssid}"
			fi
			previous_ssid="$ssid"
		fi
		sleep 1
	done
}

monitor-ssid
