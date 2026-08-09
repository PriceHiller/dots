{
  lib,
  rustPlatform,
  clangStdenv,
  fetchFromGitHub,
  linkFarm,
  fetchgit,
  runCommand,
  gn,
  ninja,
  makeWrapper,
  pkg-config,
  python3,
  removeReferencesTo,
  cctools,
  SDL2,
  fontconfig,
  libXcursor,
  libXext,
  libXrandr,
  libXi,
  stdenv,
  libglvnd,
  libxkbcommon,
  enableWayland ? stdenv.hostPlatform.isLinux,
  wayland,
}:

rustPlatform.buildRustPackage.override { stdenv = clangStdenv; } rec {
  pname = "neovide";
  version = "0.16.x";

  src = fetchFromGitHub {
    owner = "neovide";
    repo = "neovide";
    rev = "b56abb653ae7e4836a125a11c0a02afb0e59b7af";
    hash = "sha256-6jvwz4mcUo+hmGH88OPB2EGjA5QL+x4Tbiyft3f1LIE=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  SKIA_SOURCE_DIR =
    let
      repo = fetchFromGitHub {
        owner = "rust-skia";
        repo = "skia";
        # see rust-skia:skia-bindings/Cargo.toml#package.metadata skia
        tag = "m148-0.97.0";
        hash = "sha256-uFnYX6ZDg+cJwLyCe6IGB6M3aCyI/+q2aYP4JfHm544=";
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
      cp -R ${repo} $out
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
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools.libtool
  ];

  doCheck = false;
  # nativeCheckInputs = [ neovim ];

  buildInputs = [
    SDL2
    fontconfig
    rustPlatform.bindgenHook
  ];

  postFixup =
    let
      libPath = lib.makeLibraryPath (
        [
          libglvnd
          libxkbcommon
          libXcursor
          libXext
          libXrandr
          libXi
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

  postInstall =
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p $out/Applications
      cp -r extra/osx/Neovide.app $out/Applications
      ln -s $out/bin $out/Applications/Neovide.app/Contents/MacOS
    ''
    + lib.optionalString stdenv.hostPlatform.isLinux ''
      for n in 16x16 32x32 48x48 256x256; do
        install -m444 -D "assets/neovide-$n.png" \
          "$out/share/icons/hicolor/$n/apps/neovide.png"
      done
      install -m444 -Dt $out/share/icons/hicolor/scalable/apps assets/neovide.svg
      install -m444 -Dt $out/share/applications assets/neovide.desktop
    '';

  disallowedReferences = [ SKIA_SOURCE_DIR ];

  meta = {
    description = "Neovide is a simple, no-nonsense, cross-platform graphical user interface for Neovim";
    mainProgram = "neovide";
    homepage = "https://neovide.dev/";
    changelog = "https://github.com/neovide/neovide/releases/tag/${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ck3d ];
    platforms = lib.platforms.unix;
  };
}
