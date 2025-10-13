#!/usr/bin/env bash

set -euo pipefail

BASE_DIR="$(git rev-parse --show-toplevel)"

gen-system-key() {
	local system="${1:?"No system provided to generate a key for!"}"

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
	local host_pubkey_path="${BASE_DIR}/secrets/secrets/hosts/${system}/pubkey/pubkey.nix"
	if [[ -r "${host_pubkey_path}" ]]; then
		local backup_pub_key_path
		backup_pub_key_path="${host_pubkey_path}.$(date +'%Y-%d-%m_%H:%M:%S')"
		printf "Backing up old public key file to '%s'!\n" "${backup_pub_key_path}" 1>&2
		mv "${host_pubkey_path}" "${backup_pub_key_path}"
	fi
	printf '"%s"' "${pub_key}" >"${host_pubkey_path}"

	pushd secrets >/dev/null
	agenix -r 1>&2
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
	local ssh_port="${4:-22}"
	local nix_extra_experimental_features="nix-command flakes recursive-nix pipe-operators"

	if [[ ! -r "${BASE_DIR}/hosts/${system}" ]]; then
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
	new_sys_key="$(gen-system-key "${system}")"
	printf "Finished generating system keys\n"

	printf "Running NixOS Anywhere\n"
	nix --extra-experimental-features "${nix_extra_experimental_features}" run github:nix-community/nixos-anywhere -- --flake "${flake}" "${conn}" --phases kexec,disko -p "${ssh_port}" 2>&1 | tee >(cat >&2)
	printf "Finished running NixOS Anywhere\n"

	local ssh_opts="-o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${ssh_port}"
	local ssh_cmd="ssh ${conn} ${ssh_opts}"
	local system_key_dest="${persist_dir}/ephemeral/etc/ssh/ssh_host_ed25519_key"
	printf "SSH Command: %s\n" "${ssh_cmd}"
	eval "${ssh_cmd}" <<-__EOS__
		set -euo pipefail

		mkdir -p '${persist_dir}/ephemeral/etc/ssh'
		mkdir -p '${persist_dir}/save'
		mkdir -p '${flake_install_path}'
		printf "Putting new system key into place\n"
		printf "%s\n" '${new_sys_key}' > '${system_key_dest}'
		chmod 0600 '${system_key_dest}'
		printf "Installing rsync for later stage\n"
		nix-env --extra-experimental-features '${nix_extra_experimental_features}' -f '<nixpkgs>' -iA rsync
	__EOS__

	printf "Copying flake to system\n"
	local rsync_cmd="rsync -r '${BASE_DIR}'/ '${conn}:${flake_install_path}' -e 'ssh ${ssh_opts}' --info=PROGRESS2"
	printf "Issuing rsync command: '%s\n'" "${rsync_cmd}"
	eval "${rsync_cmd}"

	printf "\n\n==== Doing Final Install ====\n\n"

	eval "${ssh_cmd}" <<-__EOS__
		set -euo pipefail
		pushd "${flake_install_path}"

		nix-env --extra-experimental-features '${nix_extra_experimental_features}' -f '<nixpkgs>' -iA git
		sudo nixos-install --flake "git+file:${flake}" --no-channel-copy

		rm -rf "${flake_install_path}/" || true
		popd
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
