{
  pkgs,
  ...
}:
{
  home = {
    packages = with pkgs; [
      neovide
      neovim
      bun
    ];
  };
}
