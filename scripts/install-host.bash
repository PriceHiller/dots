#!/usr/bin/env bash

set -Eeuo pipefail

BASE_DIR="$PWD"

gen-system-key() {
	local system="${1:?"No system provided to generate a key for!"}"
	local priv_key_path="${2:?"No private key path provided!"}"
	local key_file="out-key"
	local priv_key
	local pub_key

	# Gen Key in a temp directory
	pushd "$(mktemp -d)" >/dev/null
	ssh-keygen -t ed25519 -f ./"${key_file}" -N '' -C "${system}" -q
	priv_key="$(cat "${key_file}")"
	pub_key="$(cat "${key_file}.pub")"
	rm -f "${key_file}" "${key_file}.pub" >/dev/null
	popd >/dev/null

	# Update public key for system and rekey secrets
	printf "Rekeying for '%s' secrets with new system key!\n" "${system}" 1>&2
	local host_pubkey_path="${BASE_DIR}/hosts/${system}/pubkey.nix"
	if [[ -r "${host_pubkey_path}" ]]; then
		local backup_pub_key_path
		backup_pub_key_path="${host_pubkey_path}.$(date +'%Y-%d-%m_%H:%M:%S')"
		printf "Backing up old public key file to '%s'!\n" "${backup_pub_key_path}" 1>&2
		mv "${host_pubkey_path}" "${backup_pub_key_path}"
	fi
	printf '"%s"' "${pub_key}" >"${host_pubkey_path}"
	git add "${host_pubkey_path}" 1>&2

	pushd secrets >/dev/null
	agenix -r -i "${priv_key_path}" 1>&2
	git add . 1>&2
	popd >/dev/null

	printf "%s" "${priv_key}"
}

main() {
	local persist_dir="/mnt/persist"
	local flake_install_path="${persist_dir}/ephemeral/etc/nixos"

	local system="${1:?"Provide system to build!"}"
	local flake=".#${system}"
	local conn="${2:?"Provide ssh connection string! (E.g. root@myhost)"}"
	local priv_key_path="${3:?Provide path to private key}"
	local ssh_port="${4:-22}"

	if [[ ! -r "${priv_key_path}" ]]; then
		printf "Unable a private key file at '%s'\n!" "${priv_key_path}" 1>&2
		exit 1
	elif [[ ! -r "${BASE_DIR}/hosts/${system}" ]]; then
		printf "Could not find a system named '%s' in '%s'!\n" "${system}" "${BASE_DIR}/hosts" 1>&2
		exit 1
	fi
	cat <<-__EOS__
		─────────────────────────────────
		 Installing NixOS on Remote Host
		=================================
		 Host:  "${conn}"
		 Flake: "${flake}"
		─────────────────────────────────
	__EOS__
	printf "Generating system keys\n"
	local new_sys_key
	new_sys_key="$(gen-system-key "${system}" "${priv_key_path}")"
	printf "Finished generating system keys\n"
	local nixos_anywhere_log
	nixos_anywhere_log="$(nix run github:nix-community/nixos-anywhere -- --flake "${flake}" "${conn}" --stop-after-disko -p "${ssh_port}" 2>&1 | tee >(cat >&2))"
	local ssh_login_key="${nixos_anywhere_log##*$'\n'}"
	ssh_login_key="${ssh_login_key#*\'}"
	ssh_login_key="${ssh_login_key%\'*}"
	local ssh_opts="-i ${ssh_login_key} -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${ssh_port} -l root"
	local ssh_cmd="ssh ${conn} ${ssh_opts}"
	local system_key_dest="${persist_dir}/ephemeral/etc/ssh/ssh_host_ed25519_key"
	printf "SSH Command: %s\n" "${ssh_cmd}"
	eval "${ssh_cmd}" <<-__EOS__
		mkdir -p "${persist_dir}/ephemeral/etc/ssh"
		mkdir -p "${persist_dir}/save"
		mkdir -p "${flake_install_path}"
		printf "Putting new system key into place\n"
		printf "%s\n" "${new_sys_key}" > "${system_key_dest}"
		chmod 0600 "${system_key_dest}"
		printf "Installing rsync for later stage\n"
		nix-env -f '<nixpkgs>' -iA rsync
	__EOS__
	printf "Copying flake to system\n"
	local rsync_cmd="rsync -r '${BASE_DIR}'/ '${conn}:${flake_install_path}' -e 'ssh ${ssh_opts}' --info=PROGRESS2"
	printf "Issuing rsync command: '%s\n'" "${rsync_cmd}"
	eval "${rsync_cmd}"
	printf "Doing final install\n"
	eval "${ssh_cmd}" <<-__EOS__
		set -euo pipefail
		cd "${flake_install_path}"
		nix-env -f '<nixpkgs>' -iA git
		sudo nixos-install --flake "git+file:${flake}" --no-root-password --no-channel-copy && reboot
	__EOS__

	cat <<-__EOS__
		──────────────────────────────────────────
		 Finished Installing NixOS on Remote Host
		==========================================
		 Host:  "${conn}"
		 Flake: "${flake}"
		──────────────────────────────────────────
	__EOS__
}

main "${@}"
