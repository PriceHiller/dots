{
  pkgs,
  lib,
  ...
}:
let
  # Compose the latest Node package directly to avoid nodejs_latest's
  # deprecation warnings for forwarded attributes.
  nodejsSlimLatest = pkgs.nodejs-slim_latest;
  nodejsPackage = pkgs.symlinkJoin {
    pname = "nodejs";
    inherit (nodejsSlimLatest) version;
    paths = [
      nodejsSlimLatest
      nodejsSlimLatest.npm
    ]
    ++ lib.lists.optional (builtins.hasAttr "corepack" nodejsSlimLatest) nodejsSlimLatest.corepack;
  };

  nodeDispatcher = pkgs.writeShellScript "nodejs-dispatch" ''
    exec "$@"
  '';

  # A single sandbox wrapper dispatches to the requested command inside the
  # sandbox. Per-command launchers below pass their own basename to it.
  nodeBwrapper = pkgs.mkBwrapper {
    imports = [
      pkgs.bwrapperPresets.devshell
      ./../../presets/fixExitTrap.nix
    ];
    app = {
      package = nodejsPackage.overrideAttrs (_: {
        pname = "nodejs-bwrap";
      });
      runScript = "${nodeDispatcher}";
    };

    sockets = {
      wayland = false;
      x11 = false;
      pipewire = false;
      pulseaudio = false;
    };
    dbus.enable = lib.modules.mkForce false;
    flatpak.enable = lib.modules.mkForce false;

    mounts.readWrite = [
      "\${XDG_STATE_HOME:-$HOME/.local/state}/npm"
      "\${XDG_CACHE_HOME:-$HOME/.cache}/npm"
      "\${XDG_DATA_HOME:-$HOME/.local/share}/npm"
      "\${XDG_CONFIG_HOME:-$HOME/.config}/npm"
    ];
  };
in
pkgs.symlinkJoin {
  pname = "node";
  inherit (nodejsSlimLatest) version meta;
  # Keep the entire original package as the base so we get lib/, include/,
  # share/bash-completion, share/fish, man pages, etc. automatically.
  paths = [ nodejsPackage ];
  postBuild = ''
    # Discover every entry at build time so new upstream binaries are wrapped
    # automatically without requiring evaluation-time access to the store path.
    for binary in "$out"/bin/*; do
      [ -e "$binary" ] || [ -L "$binary" ] || continue
      [ -d "$binary" ] && continue
      [ -x "$binary" ] || continue

      rm -f "$binary"
      cat > "$binary" <<'EOF'
    #!${pkgs.runtimeShell}
    binary_name="''${0##*/}"
    exec ${nodeBwrapper}/bin/nodejs-bwrap "$binary_name" "$@"
    EOF
      chmod +x "$binary"
    done
  '';
}
