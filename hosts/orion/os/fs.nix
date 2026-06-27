{
  lib ? (import <nixpkgs> { }).lib,
  config,
  ...
}:
let
  root-disk = "/dev/nvme0n1";
  persistDir = config.ext.persistence.persistDir;
in
{
  services = {
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/"
      ];
    };
  };

  ext.persistence.enable = true;

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 128 * 1024;
      priority = 10;
    }
  ];

  disko.devices = {
    disk.${lib.removePrefix "/dev/" root-disk} = {
      type = "disk";
      device = "${root-disk}";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            priority = 1;
            size = "512M";
            type = "EF00";
            content = {
              extraArgs = [
                "-n 'NixOS-Boot'"
              ];
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "umask=0077"
                "defaults"
              ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "-L NixOS-Primary"
                ];
                preUnmountHook = ''
                  btrfs subvolume snapshot -r "root" "root-base"
                '';
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "${persistDir}" = {
                    mountpoint = "${persistDir}";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "noatime"
                      "nodatacow"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
