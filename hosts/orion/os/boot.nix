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
        dbus.enable = true;
        emergencyAccess = true;
        storePaths = [
          "${pkgs.ncurses}/share/terminfo"
        ];
        managerEnvironment = {
          TERM = "linux";
          TERMINFO = "${pkgs.ncurses}/share/terminfo";
        };
        network.enable = true;
        initrdBin = with pkgs; [
          # Filesystem & Disk
          coreutils
          findutils
          dosfstools # fsck.vfa
          e2fsprogs # fsck.ext4, tune2fs
          btrfs-progs
          parted

          # Search & Navigation
          less
          ripgrep
          fzf

          # Networking
          iproute2
          iputils # ping
          curl
          wpa_supplicant

          # Editing
          neovim

          # Hardware Debugging
          pciutils # lspci
          usbutils # lsusb

          # Process Debugging
          strace
        ];
      };
    };
  };
}
