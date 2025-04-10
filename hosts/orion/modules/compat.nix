{ pkgs, ... }:
{
  services.envfs.enable = true;
  programs = {
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        sqlite
        stdenv.cc.cc
        glibc.static
        glibc
        openssl
        libssh
        libsodium
        systemd
        zlib
        zstd
        curl
        attr
        bzip2
        acl
        util-linux
        xz
      ];
    };
  };
}