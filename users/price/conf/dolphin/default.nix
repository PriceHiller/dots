{
  lib,
  pkgs,
  config,
  ...
}:
{
  # Thanks
  # - https://github.com/rumboon/dolphin-overlay/issues/2#issuecomment-3844942348
  # - https://github.com/NixOS/nixpkgs/issues/409986#issuecomment-3826168101
  xdg = {
    systemDirs.data = [ "${pkgs.libsForQt5.kservice}/etc/xdg" ];
    configFile = {
      "menus/applications.menu" = {
        source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
        recursive = true;
      };
    };
    mimeApps.defaultApplications =
      let
        dolphin-desktop = "org.kde.dolphin.desktop";
        mimeTypes = [
          "inode/directory"
          "inode/mount-point"
        ];
        dolpinDefaultMimes =
          mimeTypes
          |> builtins.map (mimeType: {
            name = mimeType;
            value = [ dolphin-desktop ];
          })
          |> builtins.listToAttrs;

      in
      dolpinDefaultMimes;

  };
  home = {
    activation = {
      kdeBuildMimeCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.kdePackages.kservice}/bin/kbuildsycoca6 --noincremental
      '';
      kdeTerminalConfig =
        # TODO: Make this take in an attrset that maps to a kconfig write
        let
          kdeGlobalsFilePath = "${config.xdg.configHome}/kdeglobals";
          kconfig = lib.getExe' pkgs.kdePackages.kconfig "kwriteconfig6";
        in
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          # bash
          ''
            ${kconfig} \
              --file "${kdeGlobalsFilePath}" \
              --group "General" \
              --key "TerminalApplication" \
              "neovide-terminal"

            ${kconfig} \
              --file "${kdeGlobalsFilePath}" \
              --group "General" \
              --key "TerminalService" \
              "neovide-terminal.desktop"
          '';
    };
    packages = with pkgs; [
      # For icons
      kdePackages.qtsvg
      kdePackages.dolphin
      # To support network shares and more
      kdePackages.kio
      kdePackages.kio-fuse
      kdePackages.kio-extras
      kdePackages.audiocd-kio
      # Support for compressing/decompressing archives
      kdePackages.ark
      # Support for Git and more
      kdePackages.dolphin-plugins
      # To show previews for images, PDFs, etc.
      kdePackages.kdesdk-thumbnailers
      kdePackages.kdegraphics-thumbnailers
      kdePackages.ffmpegthumbs
      resvg
      taglib
      kdePackages.qtimageformats
      kdePackages.kimageformats
      icoutils
      libappimage
    ];
  };
}
