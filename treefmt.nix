# treefmt.nix
{ pkgs, ... }:
{
  projectRootFile = "flake.nix";
  programs.stylua.enable = true;
  programs.nixfmt.enable = true;
  programs.yamlfmt.enable = true;
  programs.black.enable = true;
  programs.ruff-format.enable = true;
}
