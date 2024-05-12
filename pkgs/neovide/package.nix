{
  lib,
  rustPlatform,
  clangStdenv,
  fetchFromGitHub,
  linkFarm,
  fetchgit,
  runCommand,
  gn,
  neovim,
  ninja,
  makeWrapper,
  pkg-config,
  python3,
  removeReferencesTo,
  xcbuild,
  SDL2,
  fontconfig,
  xorg,
  stdenv,
  darwin,
  libglvnd,
  libxkbcommon,
  enableWayland ? stdenv.isLinux,
  wayland,
}:

rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } rec {
  pname = "neovide";
  version = "0.12.2";

  src = fetchFromGitHub {
    owner = "neovide";
    repo = "neovide";
    rev = "35ea46a3fef7f9938830dd8e294b696dfe24af56";
    sha256 = "sha256-wsMNYwkYtW8MbK+ZD1dX2dxy7Elu8BA9ptta9rQZJuo=";
  };

  cargoHash = "sha256-y3zcx6wucjkbzHGm/ameElFoDazhQ8OSUcxKTx+86TY=";

  SKIA_SOURCE_DIR =
    let
      repo = fetchFromGitHub {
        owner = "rust-skia";
        repo = "skia";
        # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
        rev = "d0410d4e6f703f06f6adc2b3793b284aeb23b0e9";
        sha256 = "sha256-zlHUJUXukE4CsXwwmVl3KHf9mnNPT8lC/ETEE15Gb4s=";
      };
      # The externals for skia are taken from skia/DEPS
      externals = linkFarm "skia-externals" (
        lib.mapAttrsToList (name: value: {
          inherit name;
          path = fetchgit value;
        }) (lib.importJSON ./skia-externals.json)
      );
    in
    runCommand "source" { } ''
      cp -r ${repo} $out
      chmod -R +w $out
      ln -s ${externals} $out/third_party/externals
    '';

  SKIA_GN_COMMAND = "${gn}/bin/gn";
  SKIA_NINJA_COMMAND = "${ninja}/bin/ninja";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    python3 # skia
    removeReferencesTo
  ] ++ lib.optionals stdenv.isDarwin [ xcbuild ];

  nativeCheckInputs = [ neovim ];

  buildInputs = [
    SDL2
    fontconfig
    rustPlatform.bindgenHook
  ] ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.AppKit ];

  postFixup =
    let
      libPath = lib.makeLibraryPath (
        [
          libglvnd
          libxkbcommon
          xorg.libXcursor
          xorg.libXext
          xorg.libXrandr
          xorg.libXi
        ]
        ++ lib.optionals enableWayland [ wayland ]
      );
    in
    ''
      # library skia embeds the path to its sources
      remove-references-to -t "$SKIA_SOURCE_DIR" \
        $out/bin/neovide

      wrapProgram $out/bin/neovide \
        --prefix LD_LIBRARY_PATH : ${libPath}
    '';

  postInstall = ''
    for n in 16x16 32x32 48x48 256x256; do
      install -m444 -D "assets/neovide-$n.png" \
        "$out/share/icons/hicolor/$n/apps/neovide.png"
    done
    install -m444 -Dt $out/share/icons/hicolor/scalable/apps assets/neovide.svg
    install -m444 -Dt $out/share/applications assets/neovide.desktop
  '';

  disallowedReferences = [ SKIA_SOURCE_DIR ];

  meta = with lib; {
    description = "This is a simple graphical user interface for Neovim.";
    mainProgram = "neovide";
    homepage = "https://github.com/neovide/neovide";
    changelog = "https://github.com/neovide/neovide/releases/tag/${version}";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ ck3d ];
    platforms = platforms.all;
  };
}
