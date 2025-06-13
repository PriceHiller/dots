#!/usr/bin/env python

import subprocess

res = subprocess.run(["brightnessctl", "-m"], stdout=subprocess.PIPE)
res.check_returncode()
brightness = int(res.stdout.decode().split(",")[-2][:-1])
print(f"Current brightness read as: {brightness}%")

new_brightness = min(brightness, 5)
set_cmd =["brightnessctl", "-s", "set", f"{new_brightness}%"]
print(f"Setting new brightness to: {new_brightness}%")
print(f"Running: {set_cmd}")
res = subprocess.run(set_cmd)
res.check_returncode()
