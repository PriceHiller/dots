{ ... }:
{
  additions = final: _prev: import ../pkgs { pkgs = final; };

  modifications = final: prev: {
    equicord = prev.equicord.overrideAttrs (oldAttrs: {
      name = "equicord-with-user-plugins";
      patchPhase = (oldAttrs.patchPhase or "") + ''
        ls -alh
        ls -alh src
        mkdir -p ./src/userplugins
        cp -r ${./equicord/userplugins}/* ./src/userplugins/
      '';
    });
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
  };
}
