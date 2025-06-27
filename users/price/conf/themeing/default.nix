{ pkgs, config, ... }:
{
  home = {
    pointerCursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      gtk.enable = true;
      dotIcons.enable = false;
      size = 28;
    };
    packages = with pkgs; [
      kdePackages.qt6ct
      libsForQt5.qt5ct
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "kvantum";
  };

  xdg.configFile =
    let
      themeName = "rose-pine-moon-rose";
    in
    {
      "Kvantum/kvantum.kvconfig".text = ''
        [General]
        theme=${themeName}
      '';

      "Kvantum/${themeName}".source =
        "${pkgs.rose-pine-kvantum}/share/Kvantum/themes/${themeName}/${themeName}.kvconfig";
    };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "default";
  };

  gtk = {
    enable = true;
    theme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-gtk-theme;
    };
    iconTheme = {
      name = "rose-pine-moon";
      package = pkgs.rose-pine-icon-theme;
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
