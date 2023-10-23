#!/usr/bin/env bash

main() {
	local workspace_id="${1}"

	local focused_monitor
	focused_monitor="$(hyprctl monitors -j | jq -c '.[] | select(.focused)' | jq -r '.name')"

	hyprctl dispatch workspace "${workspace_id}"
	hyprctl dispatch movecurrentworkspacetomonitor "${focused_monitor}"
}

main "${@}"
unset -f main
