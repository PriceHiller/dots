#!/usr/bin/env bash

log() {
	printf "%s\n" "${*}"
	systemd-cat -t init-wallpapers -p info echo "${*}"
}

set-wallpapers() {
	### Set default wallpaper ###

	# Monitors to not set a default for, to be set later down the script
	local excluded_monitors=("eDP-1")

	local monitor
	while read -r monitor; do
		local set_mon_wallpaper=true
		for excluded_mon in "${excluded_monitors[@]}"; do
			if [[ "${excluded_mon}" == "${monitor}" ]]; then
				log "Not setting default wallpaper for '${monitor}' as it is excluded"
				set_mon_wallpaper=false
				break
			fi
		done
		if "${set_mon_wallpaper}"; then
			log "Set default wallpaper for monitor: '${monitor}'"
			swww img -t none "${XDG_DATA_HOME}/wallpapers/Nebula.jpg" -o "${monitor}"
		fi
	done < <(hyprctl monitors -j | jq -r '.[].name')

	### Set any non defaults ###
	swww img -t none ~/.local/share/wallpapers/Industrial-Shaded.png -o eDP-1
}

main() {
	swww kill; swww init && log "Initialized swww daemon"
	set-wallpapers
}

main
