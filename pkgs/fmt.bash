#!/usr/bin/env bash
# vim: ft=sh

set -euo pipefail

fmt() {
	local check_mode="${1:?Format Check mode not specified!}"
	local fail_fast="${2:?Fail Fast mode not specified!}"
	shift 2

	local badly_formatted_files=()
	for file in "${@}"; do
		local ret=0
		if ((check_mode == 1)); then
			printf ">>> Checking Formatting of file: %s\n" "${file}"
		else
			printf ">>> Formatting file: %s\n" "${file}"
		fi

		if [[ ! -r "${file}" ]]; then
			printf "Could not read/file does not exist at: %s\n" "${file}"
			ret=1
		fi

		case "${file}" in
		# Excluded files/dirs
		*.config/zsh/config/omz* | *.config/zsh/config/plugins* | *lazy-lock.json) ;;
		*.lua)
			if ((check_mode == 1)); then
				stylua --check "${file}" || ret="${?}"
			else
				stylua "${file}" || ret="${?}"
			fi
			;;
		*.sh | *.bash)
			if ((check_mode == 1)); then
				ret="$(shfmt -l "${file}" || printf "\n" | wc -l)"
			else
				shfmt -w "${file}" || ret="${?}"
			fi
			;;
		*.nix)
			if ((check_mode == 1)); then
				nixfmt --check "${file}" || ret="${?}"
			else
				nixfmt "${file}" || ret="${?}"
			fi
			;;
		*.json)
			if ((check_mode == 1)); then
				prettier --check "${file}" || ret="${?}"
			else
				prettier --write "${file}" || ret="${?}"
			fi
			;;
		esac
		if ((ret > 0)); then
			if ((fail_fast == 1)); then
				printf "Fail Fast Specified, returning!\n"
				return "${ret}"
			fi
			badly_formatted_files+=("${file}")
		fi
	done

	if (("${#badly_formatted_files[@]}" > 0)); then
		if ((check_mode == 1)); then
			printf "\n====== Incorrectly Formatted Files ======\n"
		else
			printf "\n====== Failed to Format Files ======\n"
		fi

		for badly_formatted_file in "${badly_formatted_files[@]}"; do
			printf "%s\n" "${badly_formatted_file}"
		done
		return 1
	fi
}

usage() {
	local base
	base="$(basename "${0}")"
	cat <<-__EOS__
		Usage: ${base} "path-to-a-file-to-format" "another-file-to-format" "and-another-file"
		    -f | --fmt
		      Enables format mode. By default this script only checks if the
		      formatting of files is correct.

		      Example:
		          ${base} --fmt -- "file-to-format"

		    -F | --fail-fast
		      Fails on the first format error instead of gathering all errors.

		      Example:
		          ${base} --fail-fast -- "file-to-format"
	__EOS__
}

parse_args() {
	local check_mode=1
	local fail_fast=0

	if ((${#@} == 0)); then
		usage
		exit 1
	fi

	while :; do
		case "${1}" in
		-h | -\? | --help)
			usage # Display a usage synopsis.
			exit
			;;
		--) # End of all options.
			shift
			break
			;;
		-F | --fail-fast)
			fail_fast=1
			;;
		-f | --fmt)
			check_mode=0
			;;
		-?*)
			printf 'Unknown option: %s\n' "$1" >&2
			usage
			exit 1
			;;
		*) # Default case: No more options, so break out of the loop.
			break ;;
		esac
		shift
	done

	if ((${#@} == 0)); then
		usage
		exit 1
	fi

	fmt "${check_mode}" "${fail_fast}" "${@}"
}

parse_args "${@}"
