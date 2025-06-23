#!/usr/bin/env bash

from enum import Enum
from pathlib import Path
from typing import Self


class LidState(Enum):
    OPEN = 1
    CLOSED = 2
    UNKNOWN = 3

    @classmethod
    def from_str(cls, input: str) -> Self:
        state = cls.UNKNOWN
        state = cls[input.upper()] or cls.UNKNOWN
        return state

    @classmethod
    def from_acpi_str(cls, input: str) -> Self:
        sinput: list[str] = input.split()
        state_str: str = len(sinput) == 0 and "" or sinput[-1]
        return cls.from_str(state_str)

    @classmethod
    def read_laptop_lid_state(cls, acpi_path: str | Path = "/proc/acpi/button/lid/LID0/state") -> Self:
        lid_state_str: str = ""
        with open(acpi_path) as f:
            lid_state_str = f.readline()
        return cls.from_acpi_str(lid_state_str)

def ac_is_connected(acpi_path: str | Path = "/sys/class/power_supply/AC/online") -> bool:
    connected: bool = False
    with open(acpi_path) as f:
        connected = bool(int(f.read(1)))
    return connected


def main():
    laptop_is_closed = LidState.read_laptop_lid_state() == LidState.CLOSED
    res = not int(ac_is_connected() and laptop_is_closed)
    exit(res)

main()
