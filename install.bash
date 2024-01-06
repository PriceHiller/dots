#!/usr/bin/env /bin/bash
nix run --extra-experimental-features 'nix-command flakes' . -- switch --extra-experimental-features 'nix-command flakes' --flake "git+file://$(pwd)?submodules=1" "${@}"
