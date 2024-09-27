{ lib, config, ... }:
{
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  services.fstrim.enable = true;
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1
  '';
  services.hardware.bolt.enable = true;
}
