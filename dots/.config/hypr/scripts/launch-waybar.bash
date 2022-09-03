#!/usr/bin/env bash

main() {
	kill -9 "$(pidof waybar)" >/dev/null
	waybar &
}
main
