{ config, pkgs, ... }:
{
  services.github-runners = {
    # Run jobs from https://github.com/PriceHiller/nvim-ts-autotag
    nvim-ts-autotag-runner = {
      enable = true;
      url = "https://github.com/PriceHiller/nvim-ts-autotag";
      tokenFile = config.age.secrets.gh-ts-autotag-runner-token.path;
      extraPackages = with pkgs; [
        tree-sitter
        fd
        neovim
        gnumake
        gcc
        curl
        gnutar
        git
        coreutils
      ];
    };
  };
}