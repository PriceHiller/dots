{ pkgs, lib, ... }:
let
  nixGLWrap =
    pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';
in
{
  imports = [ ../price/home.nix ];
  xdg.systemDirs.data = [ "/usr/share" ];
  home = {
    packages = with pkgs; [
      (lib.hiPrio (nixGLWrap neovide))
      (lib.hiPrio (nixGLWrap wezterm))
    ];
  };
}
