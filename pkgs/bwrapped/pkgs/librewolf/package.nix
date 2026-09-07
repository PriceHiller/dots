{ pkgs, ... }:
pkgs.mkBwrapper {
  app = {
    renameDesktopFile = false;
    overwriteExec = false;
    package = pkgs.librewolf;
    env = {
      DICPATH = "${pkgs.hunspell |> pkgs.lib.getLib}/share";
    };
  };

  fhsenv = {
    performDesktopPostInstall = true;
    opts = {
      unshareNet = false;
    };
  };
  mounts =
    let
      realPath = p: ''$(readlink -f "${p}")'';
    in
    {
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
      readWrite = [
        "\${XDG_CONFIG_HOME:-$HOME/.config}/librewolf"
        "\${XDG_CACHE_HOME:-$HOME/.cache}/librewolf"
        "\${HOME}/Downloads/"
      ];
      read = [
        # Needed for GPU acceleration
        "/sys"
        # For themeing support
        (realPath "/etc/profiles/per-user/$USER/share/themes")
        (realPath "/etc/profiles/per-user/$USER/share/icons")
        (realPath "\${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0")
        (realPath "\${XDG_CONFIG_HOME:-$HOME/.config}/gtk-4.0")
        (realPath "\${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0")
        (realPath "\${XDG_CONFIG_HOME:-$HOME/.config}/Kvantum")
        (realPath "\${XDG_CONFIG_HOME:-$HOME/.config}/gtkrc-2.0")
        # Needed for smart card support
        (realPath "/run/pcscd/pcscd.comm")
        # Speech Support
        (realPath "$XDG_RUNTIME_DIR/speech-dispatcher/speechd.sock")
        # For reading mime handlers
        ''$(readlink -f "$XDG_CONFIG_HOME/mimeapps.list")''
      ];
    };

  flatpak.enable = true;
  dbus = {
    enable = true;
    session = {
      talks = [
        "org.freedesktop.Notifications"
        "com.canonical.AppMenu.Registrar"
        "com.canonical.Unity.LauncherEntry"
        "org.freedesktop.ScreenSaver"
        "com.canonical.indicator.application"
        "org.kde.StatusNotifierWatcher"
        "org.freedesktop.portal.Documents"
        "org.freedesktop.portal.Flatpak"
        "org.freedesktop.portal.Desktop"
        "org.freedesktop.portal.Notifications"
        "org.freedesktop.portal.FileChooser"
        "org.freedesktop.FileManager1"
        "org.freedesktop.UDisks2"
        "org.freedesktop.UPower"
        "org.a11y.Bus"
        "com.canonical.AppMenu.Registrar"
        "org.gnome.SessionManager"
        "org.a11y.Bus"
        "org.gtk.vfs.*"
      ];
      calls = [
        "org.freedesktop.portal.*=*@/org/freedesktop/portal/desktop"
      ];
      broadcasts = [
        "org.freedesktop.portal.Desktop=*@/org/freedesktop/portal/desktop"
      ];
      owns = [
        "io.gitlab.librewolf.*"
        "io.gitlab.firefox.*"
        "org.mpris.MediaPlayer2.firefox.*"
      ];
    };
    system = {
      talks = [
        "com.canonical.AppMenu.Registrar"
        "com.canonical.Unity.LauncherEntry"
        "org.freedesktop.NetworkManager"
      ];
    };
  };
  sockets = {
    cups = true;
    pipewire = true;
    pulseaudio = true;
    wayland = true;
    x11 = true;
  };
}
