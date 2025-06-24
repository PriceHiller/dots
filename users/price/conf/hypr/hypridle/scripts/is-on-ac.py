#!/usr/bin/env python

import json
from pathlib import Path


def ac_is_connected(
    acpi_path: str | Path = "/sys/class/power_supply/AC/online",
) -> bool:
    connected: bool = False
    with open(acpi_path) as f:
        connected = bool(int(f.read(1)))
    return connected


def main():
    ac_state = ac_is_connected()
    print(json.dumps({"on-ac": ac_state}))
    res = not ac_state
    exit(res)


main()
