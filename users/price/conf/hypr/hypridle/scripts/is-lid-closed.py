#!/usr/bin/env python

import json
from enum import Enum
from pathlib import Path
from typing import Self, override

class LidState(Enum):
    OPEN = 1
    UNKNOWN = 2
    CLOSED = 0

    @classmethod
    def from_str(cls, input: str) -> Self:
        if input in ("OPEN", "CLOSED"):
            return cls[input]
        return cls["UNKNOWN"]

    @override
    def __str__(self) -> str:
        return self.name

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


    def to_dict(self) -> dict[str, str]:
        return {"lid-state": str(self)}

def main():
    lid_state = LidState.read_laptop_lid_state()
    print(json.dumps(lid_state.to_dict()))
    laptop_is_closed = lid_state == LidState.CLOSED
    res = not laptop_is_closed
    exit(res)

main()
