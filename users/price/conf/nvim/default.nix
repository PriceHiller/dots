{
  pkgs,
  lib,
  ...
}:
{
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
