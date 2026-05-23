{ config, ... }:
let
  luaDir = "${config.home.homeDirectory}/.config/home-manager/users/price/conf/hypr/hyprland/lua";
in
{
  # All Hyprland configuration lives in `./lua/`. The legacy nix-defined
  # configs (`./appearance.nix`, `./bindings.nix`, `./monitors.nix`,
  # `./window-rules.nix`) are retained for reference but no longer imported.
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    extraConfig = ''require("./lua")'';
  };

  xdg.configFile."hypr/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink "${luaDir}";
    force = true;
  };
}
