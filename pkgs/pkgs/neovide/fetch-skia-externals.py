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


# NOTE: copied from https://github.com/rust-skia/skia/blob/37e26f9cc16e89c8f28d386e6748e43475f7e4a9/DEPS#L33C2-L46C159
# These dependencies should be updated on every Neovide update
deps: Deps = {
    "third_party/externals/brotli": "https://skia.googlesource.com/external/github.com/google/brotli.git@6d03dfbedda1615c4cba1211f8d81735575209c8",
    "third_party/externals/d3d12allocator": "https://skia.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/D3D12MemoryAllocator.git@169895d529dfce00390a20e69c2f516066fe7a3b",
    "third_party/externals/expat": "https://chromium.googlesource.com/external/github.com/libexpat/libexpat.git@8e49998f003d693213b538ef765814c7d21abada",
    "third_party/externals/freetype": "https://chromium.googlesource.com/chromium/src/third_party/freetype2.git@b91f75bd02db43b06d634591eb286d3eb0ce3b65",
    "third_party/externals/harfbuzz": "https://chromium.googlesource.com/external/github.com/harfbuzz/harfbuzz.git@31695252eb6ed25096893aec7f848889dad874bc",
    "third_party/externals/icu": "https://chromium.googlesource.com/chromium/deps/icu.git@364118a1d9da24bb5b770ac3d762ac144d6da5a4",
    "third_party/externals/libjpeg-turbo": "https://chromium.googlesource.com/chromium/deps/libjpeg_turbo.git@e14cbfaa85529d47f9f55b0f104a579c1061f9ad",
    "third_party/externals/libpng": "https://skia.googlesource.com/third_party/libpng.git@4e3f57d50f552841550a36eabbb3fbcecacb7750",
    "third_party/externals/libwebp": "https://chromium.googlesource.com/webm/libwebp.git@845d5476a866141ba35ac133f856fa62f0b7445f",
    "third_party/externals/vulkanmemoryallocator": "https://chromium.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator@a6bfc237255a6bac1513f7c1ebde6d8aed6b5191",
    "third_party/externals/spirv-cross": "https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Cross@b8fcf307f1f347089e3c46eb4451d27f32ebc8d3",
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
