{
  pkgs,
  lib,
  ...
}:
let
  mkNodeBwrap =
    name:
    pkgs.mkBwrapper {
      imports = [ pkgs.bwrapperPresets.devshell ./../../presets/fixExitTrap.nix ];
      app = {
        # mkBwrapper names the output binary after app.package.pname, not runScript.
        # Override pname so the wrapper lands at $out/bin/${name} as expected.
        package = pkgs.nodejs_latest.overrideAttrs (_: { pname = name; });
        runScript = name;
      };

      sockets = {
        wayland = false;
        x11 = false;
        pipewire = false;
        pulseaudio = false;
      };
      dbus.enable = lib.mkForce false;
      flatpak.enable = lib.mkForce false;

      mounts = {
        readWrite = [
          "\${XDG_STATE_HOME:-$HOME/.config}/npm"
          "\${XDG_CACHE_HOME:-$HOME/.cache}/npm"
          "\${XDG_DATA_HOME:-$HOME/.local/share}/npm"
          "\${XDG_CONFIG_HOME:-$HOME/.local/share}/npm"
        ];
      };
    };

  # Discover every file/symlink in nodejs_latest's bin directory.
  binaryNames = builtins.attrNames (builtins.readDir "${pkgs.nodejs_latest}/bin");

  # Build a wrapped derivation for each binary.
  wrappedBins = lib.genAttrs binaryNames (name: mkNodeBwrap name);
in
pkgs.symlinkJoin {
  name = "node";
  # Keep the entire original package as the base so we get lib/, include/,
  # share/bash-completion, share/fish, man pages, etc. automatically.
  paths = [ pkgs.nodejs_latest ];
  postBuild = ''
    # Override every binary with its bwrapped version.
    ${lib.concatMapStrings (
      name:
      let
        wrapped = wrappedBins.${name};
      in
      ''
        rm -f $out/bin/${name}
        ln -s ${wrapped}/bin/${name} $out/bin/${name}
      ''
    ) binaryNames}

    # npm (and npx) resolve their own code via lib/node_modules/npm,
    # so make sure that points at the wrapped npm's copy too.
    ${lib.optionalString (wrappedBins ? "npm") ''
      rm -rf $out/lib/node_modules/npm
      mkdir -p $out/lib/node_modules
      ln -s ${wrappedBins.npm}/lib/node_modules/npm $out/lib/node_modules/npm
    ''}
  '';
}
