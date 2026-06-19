{
  pkgs,
  ...
}:
pkgs.mkBwrapper {
  app = {
    package = pkgs.prismlauncher;
    renameDesktopFile = true;
    overwriteExec = true;
  };

  fhsenv = {
    performDesktopPostInstall = true;
    opts = {
      unshareNet = false;
    };
  };

  sockets = {
    wayland = true;
    pipewire = true;
    x11 = true;
  };
  flatpak.enable = true;
  dbus = {
    enable = true;
    session = {
      broadcasts = [
        "org.freedesktop.portal.Desktop=*@/org/freedesktop/portal/desktop"
      ];
      talks = [
        "org.freedesktop.portal.Desktop"
        "org.freedesktop.portal.Documents"
        "org.freedesktop.portal.FileChooser"
        "org.freedesktop.UDisks2"
        "org.freedesktop.UPower"
        "org.a11y.Bus"
        "com.canonical.AppMenu.Registrar"
        "org.gnome.SessionManager"
      ];
      calls = [
        "org.freedesktop.portal.*=*@/org/freedesktop/portal/desktop"
      ];
    };
  };

  mounts = {
    read = [
      # Needed for GPU acceleration
      "/sys"
      # For themeing support
      ''$(readlink -f "/etc/profiles/per-user/$USER/share/themes")''
      ''$(readlink -f "/etc/profiles/per-user/$USER/share/icons")''
      ''$(readlink -f "$XDG_CONFIG_HOME/qt5ct/")''
      ''$(readlink -f "$XDG_CONFIG_HOME/qt6ct/")''

      # For reading mime handlers
      ''$(readlink -f "$XDG_CONFIG_HOME/mimeapps.list")''
    ];
    readWrite = [
      "$XDG_CACHE_HOME/PrismLauncher"
      "$XDG_DATA_HOME/PrismLauncher"
    ];
    sandbox = [
      {
        name = "config";
        path = "$HOME/.config";
      }
      {
        name = "local";
        path = "$HOME/.local";
      }
      {
        name = "cache";
        path = "$HOME/.cache";
      }
    ];
  };
}
