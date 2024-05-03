#!/usr/bin/env bash

log() {
	printf "%s\n" "${*}"
	systemd-cat -t wallpaper -p info echo "${*}"
}

get-monitor-wallpaper() {
	local mon
	mon="$(grep "^${1}:.*" <<<"$(swww query)")"
	printf "%s" "${mon##* }"
}

set-wallpaper() {
	local monitor="${1}"
	local wallpaper_path="${2}"

	log "Setting wallpaper for monitor: '${monitor}' to '${wallpaper_path}'"
	swww img -t none "${wallpaper_path}" -o "${monitor}"
	log "Set wallpaper for monitor: '${monitor}' to '${wallpaper_path}'"
}

set-wallpapers() {
	log "Setting wallpapers"
	### Set default wallpaper ###
	local wallpapers_dir
	wallpapers_dir="$(realpath "${XDG_DATA_HOME}/wallpapers")"
	local default_wallpaper="${wallpapers_dir}/Nebula.jpg"

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
		if ${set_mon_wallpaper}; then
			set-wallpaper "${monitor}" "${default_wallpaper}"
		fi
	done < <(hyprctl monitors -j | jq -r '.[].name')

	### Set any non defaults ###
	set-wallpaper "eDP-1" "${wallpapers_dir}/Industrial-Shaded.png"
}

init() {
	log "Killing existing swww daemon if an swww daemon is running"
	swww kill >/dev/null || true
	until swww init; do
		sleep .1
	done
	log "swww daemon started"
}

main() {
	log "Starting up swww!"
	init

	while :; do
		while IFS= read -r line; do
			if grep "color: 000000" <<<"${line}"; then
				set-wallpapers
			fi
			sleep .1
		done < <(swww query)
		sleep .5
	done
}

main
