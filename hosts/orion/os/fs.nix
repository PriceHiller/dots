{
  lib,
  root-disk,
  persist-dir,
  ...
}:
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
    snapper = {
      # NOTE: According to `snapper-config(5)` the default timeline count for all timelines is 10
      # (see TIMELINE_LIMIT_HOURLY, ...DAILY, etc.)
      configs.persist = {
        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;
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
                type = "luks";
                name = "crypted";
                settings = {
                  allowDiscards = true;
                };
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
