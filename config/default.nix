{ pkgs, ... }: {
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
    ];
    file = {
      ".config/" = { source = ../dots/.config; recursive = true; force = true; };
      ".local/" = { source = ../dots/.local; recursive = true; force = true; };
      ".omnisharp" = { source = ../dots/.omnisharp; force = true; };
      ".zshrc" = { source = ../dots/.zshrc; force = true; };
      ".latexmkrc" = { source = ../dots/.latexmkrc; force = true; };
    };
  };

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      sqlite
      gh
    ];
    # Magick is required for image.nvim
    extraLuaPackages = lp: [ lp.magick ];
  };

}
