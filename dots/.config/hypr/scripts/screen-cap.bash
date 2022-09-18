#!/bin/bash

# Dependencies:
#	- wf-recorder: https://github.com/ammen99/wf-recorder
#	- Gifski: https://github.com/ImageOptim/gifski
#		- I do a conversion from mp4 to gif because there is various issues with recording straight to gif format with
#		wf-recorder
#	- notification daemon: https://archlinux.org/packages/?name=notification-daemon
#	- wl-clipboard: https://github.com/bugaevc/wl-clipboard
#
#	Some of this is hacky because I can't get wf-recorder to nicely output GIFs by itself :(

mk-gif() {
	local program_name="Screen Capture"
	local pid_file="/tmp/mk-gif-pid"

	if [[ -f "${pid_file}" ]]; then
		notify-send "Saving ${program_name}" "This May Take a Minute" -a "${program_name}"
		if ! kill -SIGINT "$(cat "${pid_file}")" 2>/dev/null; then
			notify-send "Failed ${program_name}" "Failed to Save Screen Capture" -u "critical" -a "${program_name}"
			rm -rf "${pid_file}"
			exit 1
		fi
		inotifywait -e delete_self "${pid_file}" &&
			notify-send "Saved ${program_name}" "Successfully Saved Screen Capture to Clipboard" -a "${program_name}"
	else
		local input_tmpfile
		notify-send "Starting ${program_name}" "Recording GIF of Selected Region" -a "${program_name}"
		(
			cd "/tmp"
			input_tmpfile="/tmp/$(mktemp wf-recorder.XXXXXXXXXXX).mp4"
			wf-recorder -g "$(slurp)" -f "${input_tmpfile}" &
			printf "%s" $! >"${pid_file}"
			wait
			gifski "${input_tmpfile}" --output "${input_tmpfile}.gif"
			wl-copy --type image/gif <"${input_tmpfile}.gif"
			rm -f "${pid_file}"
		)
	fi
}

mk-gif
