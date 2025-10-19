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
    kernelParams = [
      "intel_iommu=on"
    ];
    kernelModules = [
      # More virtualization features
      "kvm"
      "kvm_intel"

    ];
    extraModprobeConfig = builtins.concatStringsSep "\n" [
      # Allow nested virtualization
      "options kvm_intel nested=1"
      # Ignore messages due to guest operating systems having a fit
      "options kvm ignore_msrs=1"
    ];
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
        tpm2.enable = true;
        enable = true;
      };
    };
  };
}