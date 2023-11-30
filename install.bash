#!/usr/bin/env /bin/bash

home-manager switch --flake "git+file://$(pwd)?submodules=1"
