#!/usr/bin/env bash

log() {
	printf "%s\n" "${*}"
	systemd-cat -t init-wallpapers -p info echo "${*}"
}

get-monitor-wallpaper() {
	local mon
	mon="$(grep "^${1}:.*" <<<"$(swww query)")"
	printf "%s" "${mon##* }"
}

set-wallpaper() {
	local monitor="${1}"
	local wallpaper_path="${2}"

	until [[ "$(get-monitor-wallpaper "${monitor}")" == "${wallpaper_path}" ]]; do
		log "Setting wallpaper for monitor: '${monitor}' to '${wallpaper_path}'"
		swww img -t none "${wallpaper_path}" -o "${monitor}"
		log "Set wallpaper for monitor: '${monitor}' to '${wallpaper_path}'"
	done
}

set-wallpapers() {
	### Set default wallpaper ###
	local default_wallpaper="${HOME}/.dot_files/dots/.local/share/wallpapers/Nebula.jpg"

	# Monitors to not set a default for, to be set later down the script
	local excluded_monitors=("eDP-1")

	local monitor
	while read -r monitor; do
		local set_mon_wallpaper=true
		for excluded_mon in "${excluded_monitors[@]}"; do
			if [[ "${excluded_mon}" == "${monitor}" ]]; then
				set_mon_wallpaper=false
				break
			fi
		done
		if "${set_mon_wallpaper}"; then
			set-wallpaper "${monitor}" "${default_wallpaper}"
		fi
	done < <(hyprctl monitors -j | jq -r '.[].name')

	### Set any non defaults ###
	set-wallpaper "eDP-1" "${HOME}/.dot_files/dots/.local/share/wallpapers/Industrial-Shaded.png"
}

init() {
	until swww init; do
		sleep .1
	done
}

main() {
	init
	log "swww daemon running, setting wallpapers"
	while :; do
		while IFS= read -r line
		do
			if grep "color: 000000" <<< "${line}"; then
				set-wallpapers
			fi
			sleep .1
		done < <(swww query)
		sleep .5
		swww init
	done
}

main
