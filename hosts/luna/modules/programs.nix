{ ... }:
{
  ext.basePrograms.enable = true;
  environment.sessionVariables = {
    DO_NOT_TRACK = 1;
  };
  nixpkgs.config.allowUnfree = true;

  system.userActivationScripts.zshrc = "touch .zshrc";
}
