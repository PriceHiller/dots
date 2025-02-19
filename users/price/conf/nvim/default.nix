{
  pkgs,
  lib,
  ...
}:
{
  systemd.user =
    let
      svc-orgmode-name = "nvim-orgmode-notify";
    in
    {
      timers.${svc-orgmode-name} = {
        Unit = {
          Description = "Launch nvim orgmode notification service";
        };
        Timer = {
          Unit = "${svc-orgmode-name}.service";
          AccuracySec = "1s";
          OnCalendar = "*:*:00";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      services.${svc-orgmode-name} = {
        Unit = {
          Description = "Display Nvim Orgmode Notifications via `notify-send`";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = ''${pkgs.neovim}/bin/nvim --headless -c 'lua require("orgmode").cron()' '';
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraWrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        pkgs.sqlite
      ]}"
      "--suffix"
      "LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.zlib
      ]}"
      "--suffix"
      "PKG_CONFIG_PATH"
      ":"
      "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        pkgs.stdenv.cc.cc
        pkgs.zlib
      ]}"
    ];
  };
  home = {
    packages = with pkgs; [
      neovide
      bun
      nil
      sqlfluff
    ];
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "neovide.desktop" ];
    "inode/directory" = [ "neovide.desktop" ];
  };
}
