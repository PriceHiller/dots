{
  lib ? (import <nixpkgs> { }).lib,
  ...
}:
let
  root-disk = "/dev/nvme0n1";
  persist-dir = "/persist";
in
{
  services = {
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/"
        "/nix"
        "/persist"
      ];
    };
  };

  environment.etc.machine-id = {
    text = "8883d3861851470cbcbc98ed1f91727d";
    mode = "0644";
  };
  environment.persistence.save = {
    hideMounts = true;
    persistentStoragePath = "${persist-dir}/save";
    directories = [
      "/var/log"
    ];
  };
  environment.persistence.ephemeral = {
    persistentStoragePath = "${persist-dir}/ephemeral";
    hideMounts = true;
    directories = [
      "/var/lib"
      # Systemd needs the `/usr` directory to exist on boot -- see
      # https://github.com/nix-community/impermanence/issues/253#issuecomment-2614528056
      "/usr/systemd-placeholder"
    ];
  };

  fileSystems."${persist-dir}".neededForBoot = true;

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
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
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
