#!/usr/bin/env bash

main() {
	local mon_count
	mon_count="$(hyprctl monitors -j | jq length)"
	if ((mon_count > 1)); then
		hyprctl dpms off eDP-1
	fi
}

main
