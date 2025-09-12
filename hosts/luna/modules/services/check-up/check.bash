#!/usr/bin/env bash

set -eEuo pipefail

main() {
	local domain="${1}"
	local alert_email="${2:-root}"

	logger --stderr --priority "user.debug" "Starting check of domain '${domain}'"

	local failed_attempts=0
	local max_failed_attempts=3

	local sleep_time=1
	local max_sleep_time=10

	for attempt in {1..15}; do
		if ! curl --insecure --silent --location "${1}" >/dev/null; then
			_=$((failed_attempts++))
			logger --stderr --priority 'user.warning' "Attempt ${attempt} to check if '${domain}' is up FAILED, trying again in ${sleep_time} seconds"
			if ((failed_attempts >= max_failed_attempts)); then
				break
			fi

			sleep "${sleep_time}"
			sleep_time=$((sleep_time * 2))
			sleep_time=$((sleep_time > max_sleep_time ? max_sleep_time : sleep_time))
			continue
		fi
		sleep 0.5
		logger --stderr --priority "user.debug" "Attempt ${attempt} to check if '${domain}' is up succeeded"
	done

	if ((failed_attempts >= max_failed_attempts)); then
		logger --stderr "Domain '${domain}' failed to respond on '${attempt}' attempts, sending alert email"
		sendmail "${alert_email}" <<-__EOS__
			Content-Type: text/plain
			Subject: ${domain} is down!

			'${domain}' had ${failed_attempts} failed attempts to validate it was up as of $(date)
		__EOS__
		return
	fi

	logger --stderr "'${domain}' successfully validated to be up"
}

main "${@}"