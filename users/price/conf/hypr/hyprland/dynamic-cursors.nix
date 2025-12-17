{ inputs, pkgs, ... }:
{

  wayland.windowManager.hyprland = {
    plugins = [
      inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
    ];
    extraConfig =
      # hyprlang
      ''
        plugin:dynamic-cursors {
          enabled = true
          mode = stretch

          stretch {
            limit = 6000
            function = linear
          }
        }
      '';
  };

}
