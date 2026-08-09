{
  pkgs,
  ...
}:
pkgs.stdenv.mkDerivation {
  name = "apple-emoji-ttf";
  src = builtins.fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260722-484daf4e/AppleColorEmoji-Linux.ttf";
    sha256 = "0vsihaj3vxjp8lrl70vfjvcpd9q9c7l6bg2pdnps1i2s4vv7lz73";
  };
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm644 "$src" \
      "$out/share/fonts/truetype/AppleColorEmoji-Linux.ttf"
    runHook postInstall
  '';
}
