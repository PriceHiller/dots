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
  };
  dbus.enable = false;
  flatpak.enable = false;

  mounts = {
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
