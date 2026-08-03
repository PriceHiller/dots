{ pkgs, config, ... }:
{
  home = {
    pointerCursor = {
      name = "BreezeX-RosePine-Linux";
      enable = true;
      package = pkgs.rose-pine-cursor;
      gtk.enable = true;
      dotIcons.enable = false;
      size = 28;
    };
    packages = with pkgs; [
      kdePackages.qt6ct
    ];
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
  };

  gtk = {
    enable = true;
    theme = {
      name = "Colloid-Dark-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        tweaks = [ "catppuccin" ];
      };
    };
    iconTheme = {
      name = "Colloid-Catppuccin-Dark";
      package = pkgs.colloid-icon-theme.override {
        schemeVariants = [ "catppuccin" ];
      };
    };
    gtk2.configLocation = "${config.xdg.configHome}/gtk-2.0/gtkrc";
  };
}
