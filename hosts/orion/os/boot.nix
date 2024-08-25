{ modulesPath, pkgs, ... }:
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  security.tpm2.enable = true;
  environment.systemPackages = with pkgs; [ tpm2-tss ];

  services.btrfs-rollback = {
    enable = true;
    diskLabel = "NixOS-Primary";
    subvolume = "root";
    snapshot = "root-base";
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "audit=1" ];
    extraModulePackages = [ ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "vmd"
        "nvme"
        "usbhid"
        "rtsx_pci_sdmmc"
      ];
      systemd = {
        enable = true;
        enableTpm2 = true;
      };
    };
  };
}
