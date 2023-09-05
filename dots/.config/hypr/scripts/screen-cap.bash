#!/bin/bash

# Dependencies:
#	- wf-recorder: https://github.com/ammen99/wf-recorder
#	- notification daemon: https://archlinux.org/packages/?name=notification-daemon
#	- wl-clipboard: https://github.com/bugaevc/wl-clipboard
#	- gifski: https://github.com/sindresorhus/Gifski
#
#	Some of this is hacky because I can't get wf-recorder to nicely output GIFs by itself :(

mk-video() {
	local program_name="Screen Capture"
	local pid_file="/tmp/mk-gif-pid"
	local output_type="${1:-MP4}"

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
		notify-send "Starting ${program_name}" "Recording ${output_type^^} of Selected Region" -a "${program_name}"
		(
			local tmp_dir
			tmp_dir="$(mktemp -d)"
			cd "${tmp_dir}"
			input_tmpfile="${tmp_dir}/$(mktemp wf-recorder.XXXXXXXXXXX).mp4"
			local card
			card="$(find /dev/dri -maxdepth 1 -name "card*" -print -quit)"
			if [[ -n "${card}" ]]; then
				wf-recorder -g "$(slurp)" -f "${input_tmpfile}" -c h264_vaapi -d "${card}" -- &
			else
				notify-send "Card Detection" "Did not detect a card to use, encoding will be slower!" -a "${program_name}" -u critical
				wf-recorder -g "$(slurp)" -f "${input_tmpfile}" -c h264_vaapi -- &
			fi
			printf "%s" $! >"${pid_file}"
			wait
			if [[ "${output_type}" == "gif" ]]; then
				local gifski_tmpoutput
				pwd
				gifski_tmpoutput="${tmp_dir}/$(mktemp gifski.XXXXXXXXXXX).gif"
				gifski "${input_tmpfile}" --output "${gifski_tmpoutput}"
				wl-copy --type image/png <"${gifski_tmpoutput}"
			else
				wl-copy --type video/mp4 <"${input_tmpfile}"
			fi
			rm -f "${pid_file}"
		)
	fi
}

mk-video "${@}"
