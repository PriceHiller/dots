{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
    extraPackages = (
      epkgs:
      (with epkgs; [
        treesit-grammars.with-all-grammars
        melpaPackages.pdf-tools
        vterm
      ])
    );
  };
}
