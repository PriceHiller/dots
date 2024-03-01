#!/usr/bin/env -S nix --extra-experimental-features "nix-command flakes" shell nixpkgs#bash --command bash

main() {
	neovide --no-fork -- "+silent!+Man!" -- <(cat "${@}")
}

main "${@}"
