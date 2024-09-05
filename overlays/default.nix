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
    # TODO: Remove this when Zathura's update for 0.5.8 hits nixpkgs-unstable,
    # see status of https://nixpk.gs/pr-tracker.html?pr=337383
    zathura = inputs.nixpkgs-master.legacyPackages.${final.system}.pkgs.zathura;
    wezterm = inputs.wezterm.packages.${final.system}.default;
    opensnitch-ui = prev.opensnitch-ui.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ prev.python311Packages.qt-material ];
    });
    age-plugin-yubikey = prev.age-plugin-yubikey.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
      postInstall =
        oldAttrs.postInstall or ""
        + ''
          wrapProgram $out/bin/age-plugin-yubikey --prefix LD_LIBRARY_PATH : ${final.pcsclite.lib}/lib
        '';
    });
  };
}
