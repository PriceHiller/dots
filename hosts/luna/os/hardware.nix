{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  facter.reportPath = ./facter.json;
}
