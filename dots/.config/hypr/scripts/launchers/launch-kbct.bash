#!/usr/bin/env bash

main() {
	kill -9 "$(pidof kbct)" >/dev/null
	sudo modprobe uinput
	local kbct_config="${HOME}/.config/kbct/config.yml"
	sudo kbct remap --config "${kbct_config}"
}

main
