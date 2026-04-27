{
  pkgs,
  lib,
  ...
}:
pkgs.mkBwrapper {
  imports = [ pkgs.bwrapperPresets.devshell ];

  app = {
    package = pkgs.bun;
  };

  mounts = {
    readWrite = [
      "\${XDG_CONFIG_HOME:-$HOME/.config}/.bunfig.toml"
      "\${XDG_CONFIG_HOME:-$HOME/.config}/bunfig.toml"
      "\${XDG_CACHE_HOME:-$HOME/.cache}/bun"
      "\${XDG_CACHE_HOME:-$HOME/.cache}/.bun"
      "\${XDG_DATA_HOME:-$HOME/.local/share}/bun"
      "\${XDG_DATA_HOME:-$HOME/.local/share}/.bun"
    ];

    # Read-only binds.
    read = [
      # Global git config / ignore / attributes, so `opencode`-driven git
      # operations use the user's identity. (XDG path per git's own rules.)
      "\${XDG_CONFIG_HOME:-$HOME/.config}/git"
      "\${HOME}/.gitconfig"
    ];
  };

  sockets = {
    wayland = false;
    x11 = false;
    pipewire = false;
    pulseaudio = false;
  };
  dbus.enable = lib.mkForce false;
  flatpak.enable = lib.mkForce false;
}
