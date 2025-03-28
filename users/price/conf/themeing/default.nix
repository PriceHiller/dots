{ pkgs, config, ... }:
{
  home = {
    pointerCursor = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-cursor;
      gtk.enable = true;
      x11.enable = true;
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

      "Kvantum/${themeName}".source = "${
        pkgs.stdenv.mkDerivation {
          name = "Rose-Pine-Kvantum";
          src = builtins.fetchGit {
            name = "rose-pine-kvantum";
            url = "https://github.com/rose-pine/kvantum.git";
            rev = "5a51f5892ba752088dee062a6188b9f0bb59324b";
          };
          installPhase = ''
            runHook preInstall
            mkdir -p "$out/share/Kvantum"
            for tar_archive in dist/*; do
              tar -C "$out/share/Kvantum" -xf "$tar_archive"
            done
          '';
        }
      }/share/Kvantum/${themeName}";
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
