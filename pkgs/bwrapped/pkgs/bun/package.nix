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
  };

  sockets = {
    wayland = false;
    x11 = false;
    pipewire = false;
    pulseaudio = false;
  };
  dbus.enable = lib.mkForce false;
  flatpak.enable = lib.mkForce false;

  fhsenv.extraInstallCmds = ''
    for dir in share/bash-completion/completions share/fish/vendor_completions.d share/zsh/site-functions; do
      if [ -d "${pkgs.bun}/$dir" ] && [ "$(ls -A "${pkgs.bun}/$dir")" ]; then
        mkdir -p "$out/$dir"
        for f in "${pkgs.bun}/$dir"/*; do
          ln -sf "$f" "$out/$dir/$(basename "$f")"
        done
      fi
    done
  '';
}
