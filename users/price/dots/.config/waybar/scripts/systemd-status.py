#!/usr/bin/env -S nix shell nixpkgs#python3 nixpkgs#nix-prefetch-git --command python3

from enum import Enum
import subprocess
import json
from typing import NotRequired, TypedDict


class SystemUnitStatus(str, Enum):
    Ok = "ok"
    Degraded = "degraded"


WaybarJsonRet = TypedDict(
    "WaybarJsonRet",
    {
        "text": str,
        "class": SystemUnitStatus,
        "alt": NotRequired[str],
        "tooltip": NotRequired[str],
        "percentage": NotRequired[str],
    },
)


class FailedUnit(TypedDict):
    unit: str
    load: str
    active: str
    sub: str
    description: str


def get_failed_units(extra_args: list[str] | None = None) -> list[FailedUnit]:
    extra_args = extra_args or []
    args = ["systemctl", "--state=failed", "--output=json"]
    args.extend(extra_args)

    units_proc = subprocess.run(args, capture_output=True)
    units_proc.check_returncode()
    failed_units: list[FailedUnit] = json.loads(units_proc.stdout)

    return failed_units


system_failed_units = get_failed_units()
user_failed_units = get_failed_units(["--user"])
total_units_failed = len(system_failed_units) + len(user_failed_units)

status: SystemUnitStatus = SystemUnitStatus.Ok
text = ""
failed_units_tooltip: list[str] = []

if total_units_failed > 0:
    text = f" Degraded Units: {total_units_failed}"
    status = SystemUnitStatus.Degraded
    failed_units_tooltip.extend(
        map(
            lambda unit: f"<b><span color='#FFA066'>System</span> <span color='#FF5D62'>></span> {unit["unit"]}</b>",
            system_failed_units,
        )
    )
    failed_units_tooltip.extend(
        map(
            lambda unit: f"<b><span color='#FFA066'>User</span>   <span color='#FF5D62'>></span> {unit["unit"]}</b>",
            user_failed_units,
        )
    )


out: WaybarJsonRet = {
    "text": text,
    "class": status,
    "tooltip": "\r\n".join(failed_units_tooltip),
}

print(json.dumps(out))
