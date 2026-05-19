{
  pkgs,
  lib,
  ...
}:
pkgs.mkBwrapper {
  imports = [ pkgs.bwrapperPresets.devshell ];

  app = {
    package = pkgs.opencode;
  };

  mounts = {
    readWrite = [
      "$PWD"
      "\${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
      "\${XDG_CACHE_HOME:-$HOME/.cache}/opencode"
      "\${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
      "\${XDG_STATE_HOME:-$HOME/.local/state}/opencode"
      "\${XDG_STATE_HOME:-$HOME/.local/cache}/nix"
      "\${XDG_STATE_HOME:-$HOME/.local/share}/nix"
      "\${XDG_STATE_HOME:-$HOME/.local/state}/nix"
    ];

    # Read-only binds.
    read = [
      # Global git config / ignore / attributes, so `opencode`-driven git
      # operations use the user's identity. (XDG path per git's own rules.)
      "\${XDG_CONFIG_HOME:-$HOME/.config}/git"
      "\${HOME}/.gitconfig"
      "$SSH_AUTH_SOCK"
      "/nix/var"
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
