#!/usr/bin/env bash

main() {
	if pidof waybar >/dev/null 2>&1; then
		killall -9 waybar
	fi
	waybar &
}
main
