#!/usr/bin/env -S nix shell nixpkgs#python3 nixpkgs#nix-prefetch-git --command python3

import argparse
import json
import subprocess
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from threading import Lock
from typing import Any, TypedDict, cast


class FetchedJson(TypedDict):
    url: str
    rev: str
    date: str
    path: str
    sha256: str
    hash: str
    fetchLFS: bool
    fetchSubmodules: bool
    deepClone: bool
    leaveDotGit: bool


class ExternalDepVals(TypedDict):
    url: str
    rev: str
    hash: str


ExternalDep = dict[str, ExternalDepVals]
Deps = dict[str, str]

parser = argparse.ArgumentParser(
    description="Fetch Nix hashes for Skia external dependencies from a rust-skia/skia ref."
)
_ = parser.add_argument(
    "--ref",
    required=True,
    metavar="REF",
    help="rust-skia/skia git ref to fetch DEPS from (e.g. m148-0.97.0)",
)
args = parser.parse_args()


def fetch_upstream_deps(ref: str) -> Deps:
    url = f"https://raw.githubusercontent.com/rust-skia/skia/{ref}/DEPS"
    print(f"Fetching DEPS from '{url}'...", file=sys.stderr)
    with urllib.request.urlopen(url) as resp:
        content = resp.read().decode()
    ns: dict[str, Any] = {}

    def var(x: str) -> str:
        return cast(dict[str, str], ns.get("vars", {})).get(x, "")

    ns["Var"] = var
    exec(content, ns)
    raw_deps = cast(dict[str, Any], ns.get("deps", {}))
    return {
        path: dep
        for path, dep in raw_deps.items()
        if isinstance(dep, str) and path.startswith("third_party/externals/")
    }


def fetch_dep(url: str, rev: str) -> ExternalDepVals:
    out = subprocess.run(["nix-prefetch-git", url, "--rev", rev], capture_output=True)

    if out.returncode != 0:
        print(
            f"Failed to fetch: '{url}@{rev}'!",
            "======== Error ========",
            out.stderr.decode(),
            "=======================",
            sep="\n",
            file=sys.stderr,
        )
    out.check_returncode()

    fetched_json: FetchedJson = json.loads(out.stdout)
    return {
        "url": fetched_json["url"],
        "rev": fetched_json["rev"],
        "hash": fetched_json["hash"],
    }


deps: Deps = fetch_upstream_deps(args.ref)

_print_lock = Lock()


def fetch_one(dep_item: tuple[str, str]) -> tuple[str, ExternalDepVals]:
    dep_path, dep_url = dep_item
    dep_name = dep_path.split("/")[-1]
    url, rev = dep_url.split("@")
    with _print_lock:
        print(
            f"Fetching Skia External '{dep_name}':\n  URL: '{url}'\n  REV: '{rev}'",
            file=sys.stderr,
        )
    result = fetch_dep(url, rev)
    with _print_lock:
        print(f"Finished fetching Skia External '{dep_name}'", file=sys.stderr)
    return dep_name, result


with ThreadPoolExecutor() as executor:
    output: ExternalDep = dict(executor.map(fetch_one, deps.items()))

print(json.dumps(output, indent=2))
