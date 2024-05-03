#!/usr/bin/env bash
if grep -q open /proc/acpi/button/lid/LID/state; then
	swaymsg output eDP-2 enable
else
	swaymsg output eDP-2 disable
fi
