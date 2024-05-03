#!/usr/bin/env bash

main() {
	local workspace_id="${1}"
	local should_change_focus="${2:-0}"

	local focused_monitor
	focused_monitor="$(hyprctl monitors -j | jq -c '.[] | select(.focused)' | jq -r '.name')"

	hyprctl dispatch movetoworkspacesilent "${workspace_id}"
	hyprctl dispatch movecurrentworkspacetomonitor "${focused_monitor}"

	if ((should_change_focus == 1)); then
		hyprctl dispatch workspace "${workspace_id}"
	fi
}

main "${@}"
unset -f main
