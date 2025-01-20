#!/usr/bin/env -S nix shell nixpkgs#bash --command bash

set -eEuo pipefail

main() {
	local bat_capacity
	local icon=" ";
	bat_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"

	if (( bat_capacity > 25 )); then
		icon=" "
	fi

	if (( bat_capacity > 50 )); then
		icon=" "
	fi

	if (( bat_capacity > 75 )); then
		icon=" "
	fi
	if (( bat_capacity > 90 )); then
		icon=" "
	fi

	echo -n "${icon} ${bat_capacity}%"
}

main
