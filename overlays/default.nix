{ inputs, ... }:
{
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      lib = _prev.lib;
    };

  modifications = final: prev: {
    lxappearance = prev.lxappearance.overrideAttrs (oldAttrs: {
      postInstall = ''
        wrapProgram $out/bin/lxappearance --prefix GDK_BACKEND : x11
      '';
    });
    opensnitch-ui = prev.opensnitch-ui.overrideAttrs (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ prev.python3Packages.qt-material ];
    });
    age-plugin-yubikey = prev.age-plugin-yubikey.overrideAttrs (oldAttrs: {
      nativeBuildInputs = oldAttrs.nativeBuildInputs or [ ] ++ [ final.makeWrapper ];
      postInstall = oldAttrs.postInstall or "" + ''
        wrapProgram $out/bin/age-plugin-yubikey --prefix LD_LIBRARY_PATH : ${final.pcsclite.lib}/lib
      '';
    });
    unblob = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.unblob;
    davfs2 = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.davfs2;
  };
}
