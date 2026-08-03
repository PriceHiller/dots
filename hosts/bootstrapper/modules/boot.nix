{ ... }:
{
  hardware.enableAllHardware = true;
  services.hardware.bolt.enable = true;

  boot = {
    # Silence warning from NixOS mod
    zfs.forceImportRoot = false;
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    loader.systemd-boot.enable = true;
    initrd = {
      systemd.enable = true;
      allowMissingModules = true;
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "uas"
        "sd_mod"
        "wl"
      ];
    };
  };
}
