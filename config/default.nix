{ pkgs, config, ... }:
let
  dotsDir = "${config.home.homeDirectory}/.dot_files/dots";
  softLinkDots = dir:
    (builtins.listToAttrs (map
      (n: {
        name = "${dir + "/" + n}";
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${dir}/${n}";
          force = true;
        };
      })
      # HACK: We don't use the absolute path in readDir to respect pure evaluation in nix flakes.
      (builtins.attrNames (builtins.readDir ../dots/${dir}))));
in
{
  programs.home-manager.enable = true;

  home = {
    packages = with pkgs; [
      gcc
      sqlite
      luajit
      imagemagick
      dotnet-sdk_8
      cargo
      rustc
      shellcheck
      openjdk
      go
      nodejs
      poetry
      python3
      ruby
      yamllint
      curl
      llvm
      openssh
      openssl
      pkg-config
      wget
      rsync
      readline
      gnumake
      cmake
      git
      gh
      ffmpeg
      silicon
      man
      jq
      tectonic
      fzf
      eza
      luajit
      ripgrep
      fd
      nixfmt
    ];
    file =
      {
        ".local/" = {
          source = ../dots/.local;
          recursive = true;
          force = true;
        };
        ".omnisharp" = {
          source = ../dots/.omnisharp;
          force = true;
        };
        ".zshrc" = {
          source = ../dots/.zshrc;
          force = true;
        };
        ".latexmkrc" = {
          source = ../dots/.latexmkrc;
          force = true;
        };
      } // softLinkDots ".config";
  };

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [ sqlite gh ];
    # Magick is required for image.nvim
    extraLuaPackages = lp: [ lp.magick ];
  };
}
