#!/usr/bin/env -S nix shell nixpkgs#python3 nixpkgs#nix-prefetch-git --command python3

import subprocess
import sys
import json
from typing import TypedDict


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


# NOTE: copied from https://github.com/rust-skia/skia/blob/adf3a68b5e8424137861d61eae0b97bc2e528bbb/DEPS#L33-L46
# These dependencies should be updated on every Neovide update
deps: Deps = {
    "third_party/externals/expat": "https://chromium.googlesource.com/external/github.com/libexpat/libexpat.git@624da0f593bb8d7e146b9f42b06d8e6c80d032a3",
    "third_party/externals/harfbuzz": "https://chromium.googlesource.com/external/github.com/harfbuzz/harfbuzz.git@a070f9ebbe88dc71b248af9731dd49ec93f4e6e6",
    "third_party/externals/icu": "https://chromium.googlesource.com/chromium/deps/icu.git@364118a1d9da24bb5b770ac3d762ac144d6da5a4",
    "third_party/externals/libjpeg-turbo": "https://chromium.googlesource.com/chromium/deps/libjpeg_turbo.git@ccfbe1c82a3b6dbe8647ceb36a3f9ee711fba3cf",
    "third_party/externals/libpng": "https://skia.googlesource.com/third_party/libpng.git@ed217e3e601d8e462f7fd1e04bed43ac42212429",
    "third_party/externals/wuffs": "https://skia.googlesource.com/external/github.com/google/wuffs-mirror-release-c.git@e3f919ccfe3ef542cfc983a82146070258fb57f8",
    "third_party/externals/zlib": "https://chromium.googlesource.com/chromium/src/third_party/zlib@646b7f569718921d7d4b5b8e22572ff6c76f2596",
}

output: ExternalDep = {}

for dep_path, dep_url in deps.items():
    dep_name = dep_path.split("/")[-1]
    url, rev = dep_url.split("@")
    print(
        f"Fetching Skia External '{dep_name}':\n  URL: '{url}'\n  REV: '{rev}'",
        file=sys.stderr,
    )
    fetched_json = fetch_dep(url, rev)
    external_dep: ExternalDep = {dep_name: fetched_json}
    output |= external_dep

print(json.dumps(output, indent=2))
