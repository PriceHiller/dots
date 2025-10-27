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
    ];
    sessionVariables = {
      GTK_THEME = "${config.gtk.theme.name}";
    };
  };

  qt = {
    enable = true;
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
