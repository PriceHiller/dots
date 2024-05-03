#!/usr/bin/env bash

main() {
	if pidof waybar >/dev/null 2>&1; then
		killall waybar
	fi
	waybar &
}
main
