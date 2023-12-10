#!/usr/bin/env /bin/bash
nix run . -- switch --flake "git+file://$(pwd)?submodules=1"
