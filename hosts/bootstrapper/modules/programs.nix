{ pkgs, ... }:
{
  ext.basePrograms.enable = true;
  environment = {
    systemPackages = with pkgs; [
      nixos-facter
    ];
  };
}
