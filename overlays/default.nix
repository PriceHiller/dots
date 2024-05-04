{ inputs, ... }:
{
  additions = final: _prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: {
    waybar = inputs.waybar.packages.${final.system}.default;
    lxappearance = prev.lxappearance.overrideAttrs (oldAttrs: {
      postInstall = ''
        wrapProgram $out/bin/lxappearance --prefix GDK_BACKEND : x11
      '';
    });
    wezterm = inputs.wezterm.packages.${final.system}.default;
    opensnitch-ui = prev.opensnitch-ui.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ prev.python311Packages.qt-material ];
    });
  };
}
