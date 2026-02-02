{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  fs = lib.fileset;
in
{
  home.packages = with pkgs; [
    fontconfig
    inputs.apple-emoji-linux.packages.${pkgs.stdenv.hostPlatform.system}.default
    overpass
    maple-mono.variable
    nerd-fonts.overpass
    lexend
    poly
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
    fira-code
    ibm-plex
    open-sans
    noto-fonts
    twitter-color-emoji
    vista-fonts
    roboto
  ];
  fonts = {
    fontconfig = {
      enable = true;
      configFile =
        ./configs
        |> fs.fileFilter (file: file.hasExt "conf")
        |> fs.toList
        |> lib.map (file: {
          name = file |> builtins.baseNameOf |> lib.strings.removeSuffix ".conf";
          value = {
            enable = true;
            source = file;
          };
        })
        |> builtins.listToAttrs;
      defaultFonts = {
        sansSerif = [
          "Lexend"
          "Noto Sans"
          "Apple Color Emoji"
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
        serif = [
          "Poly"
          "Noto Serif"
          "Apple Color Emoji"
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
        monospace = [
          "Maple Mono"
          "Fira Code"
          "Noto Sans Mono"
          "Apple Color Emoji"
          "Twitter Color Emoji"
          "Symbols Nerd Font Mono"
        ];
        emoji = [
          "Apple Color Emoji"
          "Twitter Color Emoji"
          "Symbols Nerd Font"
        ];
      };
    };
  };
}
