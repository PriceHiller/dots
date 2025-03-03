{ lib, ... }:
let
  root-disk = "/dev/nvme0n1";
  persist-dir = "/persist";
in
{
  environment.etc.machine-id.source = "${persist-dir}/ephemeral/etc/machine-id";
  environment.persistence.save = {
    hideMounts = true;
    persistentStoragePath = "${persist-dir}/save";
  };
  environment.persistence.ephemeral = {
    persistentStoragePath = "${persist-dir}/ephemeral";
    hideMounts = true;
    directories = [
      "/var/lib"
    ];
  };
  services = {
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/"
        "/nix"
        "${persist-dir}"
      ];
    };
    snapper = {
      configs.persist = {
        SUBVOLUME = "${persist-dir}";
      };
    };
  };

  fileSystems."${persist-dir}".neededForBoot = true;

  disko.devices = {
    disk.${lib.removePrefix "/dev/" root-disk} = {
      type = "disk";
      device = "${root-disk}";
      content = {
        type = "gpt";
        partitions = {
          esp =
            let
              label = "NixOS-Boot";
            in
            {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                extraArgs = [
                  "-n ${label}"
                  "-F 32"
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
          root =
            let
              label = "NixOS-Primary";
            in
            {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-f"
                  "--label ${label}"
                ];
                postCreateHook = ''
                  MOUNT="$(mktemp -d)"
                  mount "/dev/disk/by-label/${label}" "$MOUNT" -o subvol=/
                  trap 'umount $MOUNT; rm -rf $MOUNT' EXIT
                  btrfs subvolume snapshot -r "$MOUNT/root" "$MOUNT/root-base"
                '';
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                  };
                  "/var-log" = {
                    mountpoint = "/var/log";
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
                  "${persist-dir}" = {
                    mountpoint = "${persist-dir}";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "${persist-dir}/.snapshots" = {
                    mountpoint = "${persist-dir}/.snapshots";
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
}
