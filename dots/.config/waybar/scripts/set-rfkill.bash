#!/usr/bin/env bash

main () {
	local notify_application_name="RF Status"
	local enable_airplane_mode=true

	local unblocked_devices=""

	local rf_soft_status
	local rf_hard_status
	local device
	local device_type


	for rf_status in $(rfkill -J | jq '.rfkilldevices[]' | jq -r tostring); do
		rf_soft_status="$(printf "%s" "${rf_status}" | jq -r '.soft')"
		rf_hard_status="$(printf "%s" "${rf_status}" | jq -r '.hard')"
		device="$(printf "%s" "${rf_status}" | jq -r '.device')"
		device_type="$(printf "%s" "${rf_status}" | jq -r '.type')"
		printf "RF Status JSON: %s\n" "${rf_status}"

		if [[ "${rf_soft_status}" == "blocked" ]]; then
			enable_airplane_mode=false
			unblocked_devices+="  - ${device} (${device_type})\n"
		fi

		if [[ "${rf_hard_status}" == "blocked" ]]; then
			notify-send " Hard Block Detected In Network Device" "${device} (${device_type}) has a hard block!" -a "${notify_application_name}" -u "critical"
		fi
	done

	if [[ "${enable_airplane_mode}" = true ]]; then
		printf "Airplane mode to be enabled\n"
		if rfkill block all; then
			notify-send "󱡻 Enabled Airplane Mode" "All wireless network devices have been blocked!" -a "${notify_application_name}"
		else
			notify-send "󱡺 Failed to Enable Airplane Mode" "An error has occurred! Unable to modify rf status of some devices" -a "${notify_application_name}" -u "critical"
		fi
	else
		printf "Airplane mode to be disabled\n"
		if rfkill unblock all; then
			notify-send "󱢂 Disabled Airplane Mode" "Unblocked Devices:\n${unblocked_devices}" -a "${notify_application_name}"
		else
			notify-send "󱡺 Failed to Disable Airplane Mode" "An error has occurred! Unable to modify rf status of some devices!" -a "${notify_application_name}" -u "critical"
		fi
	fi


}

main
