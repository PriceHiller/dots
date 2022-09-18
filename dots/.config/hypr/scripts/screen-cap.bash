#!/bin/bash

mk-gif() {
	local program_name="Screen Capture"
	local pid_file="/tmp/mk-gif-pid"

	if [[ -f "${pid_file}" ]]; then
		notify-send "Saving ${program_name}" "This May Take a Minute" -a "${program_name}"
		if ! kill -SIGINT "$(cat /tmp/mk-gif-pid)"; then
			notify-send "Failed ${program_name}" "Failed to Save Screen Capture" -u "critical" -a "${program_name}"
			exit 1
		fi
		inotifywait -e delete_self /tmp/mk-gif-pid && notify-send "Saved ${program_name}" "Successfully Saved Screen Capture to Clipboard" -a "${program_name}"
	else
		local input_tmpfile
		notify-send "Starting ${program_name}" "Recording GIF of Selected Region" -a "${program_name}"
		input_tmpfile="/tmp/$(mktemp wf-recorder.XXXXXXXXXXX).mp4"
		wf-recorder -g "$(slurp)" -f "${input_tmpfile}" &
		printf "%s" $! >"${pid_file}"
		wait
		yes | gifski "${input_tmpfile}" --output "${input_tmpfile}.gif"
		wl-copy --type image/gif <"${input_tmpfile}.gif"
		rm -f "${pid_file}"
	fi
}

mk-gif
