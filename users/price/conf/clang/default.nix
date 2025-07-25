{ pkgs, ... }:
{
  home.packages = with pkgs; [
    llvmPackages_20.clang
    llvmPackages_20.clang-tools
    llvmPackages_20.libstdcxxClang
    llvmPackages_20.libcxx
    ninja
    meson
  ];
}
