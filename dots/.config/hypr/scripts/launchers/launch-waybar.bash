#!/usr/bin/env bash

main() {
	kill -9 "$(pidof waybar)" >/dev/null
	GTK_THEME="THIS THEME DOESN'T EXIST" waybar &
}
main
