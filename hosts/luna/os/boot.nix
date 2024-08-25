{ modulesPath, ... }:
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  services.btrfs-rollback = {
    enable = true;
    diskLabel = "NixOS-Primary";
    subvolume = "root";
    snapshot = "root-base";
  };

  boot = {
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "audit=1" ];
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "uas"
        "sd_mod"
      ];
      kernelModules = [ ];
      systemd.enable = true;
    };
  };
}
