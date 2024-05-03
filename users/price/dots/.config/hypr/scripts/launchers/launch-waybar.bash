#!/usr/bin/env bash

main() {
	kill -15 "$(pidof waybar)" >/dev/null
	until GTK_THEME="THIS THEME DOESN'T EXIST" waybar; do
		sleep 1
	done
}
main
