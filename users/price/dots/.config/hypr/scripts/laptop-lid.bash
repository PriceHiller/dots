#!/usr/bin/env bash

set -eEuo pipefail

log() {
	local syslog_id="laptop-lid"
	local title="Laptop Clamshell"
	local level="INFO"
	local args="${*}"
	if (($# > 1)); then
		local level="${1}"
		shift
	fi
	local msg="${*}"
	case "${level^^}" in
	"TRACE")
		systemd-cat -t "$syslog_id" -p "debug" <<<"$msg"
		logger --stderr -p "user.debug" "$syslog_id" "$msg"
		;;
	"INFO")
		systemd-cat -t "$syslog_id" -p "notice" <<<"$msg"
		notify-send "$title" "$msg" -a "$title"
		;;
	"ERROR")
		systemd-cat -t "$syslog_id" -p "error" <<<"$msg"
		notify-send "$title" "$msg" -a "$title" -u "critical"
		;;
	*)
		systemd-cat -t "$syslog_id" -p "error" <<-__EOS__
			Invalid log level passed!

			Received input as: '${args}'
		__EOS__
		return 1
		;;
	esac
}

handle-laptop-lid() {
	local laptop_lid_state
	local laptop_mon="${1:-"eDP-1"}"
	local laptop_lid_acpi_path="${2:-"/proc/acpi/button/lid/LID0/state"}"
	if [[ ! -r "$laptop_lid_acpi_path" ]]; then
		log "ERROR" "Unable to read laptop state from ACPI path: '${laptop_lid_acpi_path}'"
		return 1
	fi
	log "TRACE" "Checking monitor laptop lid state at: '${laptop_lid_acpi_path}'"
	laptop_lid_state="$(</proc/acpi/button/lid/LID0/state)"
	laptop_lid_state="${laptop_lid_state##* }"
	laptop_lid_state="${laptop_lid_state^^}"
	log "TRACE" "Laptop lid state: '${laptop_lid_state}'"
	case "$laptop_lid_state" in
	"OPEN")
		if ! hyprctl monitors -j | jq -er '.[] | select(.name=="eDP-1")' >/dev/null; then
			log "TRACE" "Laptop lid is open, attempting to enable it..."
			if hyprctl keyword monitor "${laptop_mon},enable" >/dev/null; then
				log "Laptop screen enabled"
			else
				log "ERROR" "Received an error when enabling the laptop screen!"
			fi
		fi
		;;
	"CLOSED")
		if hyprctl monitors -j | jq -er '.[] | select(.name=="eDP-1")' >/dev/null; then
			log "TRACE" "Laptop lid is shut, attempting to disable it..."
			if hyprctl keyword monitor "${laptop_mon},disable" >/dev/null; then
				log "Laptop screen disabled"
			else
				log "ERROR" "Received an error when disabling the laptop screen in clamshell mode!"
			fi
		fi
		;;
	esac
}

handle-laptop-lid "${@}"
