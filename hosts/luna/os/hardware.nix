{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    graphics.enable = true;
  };
  facter.reportPath = ./facter.json;
}
