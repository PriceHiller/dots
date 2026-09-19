{ inputs, ... }:
{
  additions =
    final: _prev:
    import ../pkgs {
      pkgs = final;
      lib = _prev.lib;
    };

  modifications =
    final: prev:
    let
      lib = final.lib;
    in
    {
      # TODO: Remove this once https://github.com/NixOS/nixpkgs/pull/533093 hits unstable
      librewolf =
        inputs.nixpkgs-unstable-small.legacyPackages.${final.stdenv.hostPlatform.system}.librewolf;
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
      davfs2 = inputs.nixpkgs-stable.legacyPackages.${final.stdenv.hostPlatform.system}.davfs2;
    }
    // (
      # See https://github.com/NixOS/nixpkgs/issues/548402
      let
        override =
          pkg:
          prev.${pkg}.overrideAttrs (prev: {
            checkFlags = lib.map (
              flag:
              if lib.hasPrefix "CI_SKIP_TESTS=" flag then
                "${flag},"
                + lib.concatStringsSep "," [
                  "test-tls-over-http-tunnel"
                  "test-http-agent-keepalive"
                  "test-https-proxy-request-invalid-char-in-url"
                ]
              else
                flag
            ) (prev.checkFlags or [ ]);
          });
      in
      {
        nodejs-slim = override "nodejs-slim";
        nodejs_latest = prev.nodejs_latest.override {
          nodejs-slim = override "nodejs-slim";
        };
      }
    );
}
