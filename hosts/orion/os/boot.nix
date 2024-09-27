{
  modulesPath,
  pkgs,
  lib,
  ...
}:
let
  pkiBundlePath = "/etc/secureboot";
in
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  security.tpm2.enable = true;
  environment.systemPackages = with pkgs; [
    tpm2-tss
    sbctl
  ];

  services.btrfs-rollback = {
    enable = true;
    diskLabel = "NixOS-Primary";
    subvolume = "root";
    snapshot = "root-base";
  };

  environment.persistence.ephemeral.directories = [
    pkiBundlePath
  ];

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = pkiBundlePath;
    };
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
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