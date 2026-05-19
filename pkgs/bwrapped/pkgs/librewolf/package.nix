{ pkgs, ... }:
pkgs.mkBwrapper {
  imports = [ pkgs.bwrapperPresets.desktop ];
  app.package = pkgs.librewolf;
  sockets = {
    pipewire = true;
  };
  flatpak.manifestFile = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/flathub/io.gitlab.librewolf-community/05944558333309709fcb2408d01780fc95c13711/io.gitlab.librewolf-community.json";
    hash = "sha256-W6Lt4MCKewFa7dIGgxQ6ScnH3G8L1rxYGmkm5OZG8u4=";
  };
}
