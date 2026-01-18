{ lib, config, ... }:
{
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.fstrim.enable = true;
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=1
  '';
  services.hardware.bolt.enable = true;
  facter.reportPath = ./facter.json;
}
