{ config, ... }:
let
  persist-dir = config.ext.persistence.persistDir;
in
{
  ext.persistence.enable = true;

  services = {
    fstrim.enable = true;
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/"
        "/mnt/Store-1"
        "/mnt/Store-2"
      ];
    };
  };

  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Viper_M.2_VP4100_6D12070B19A292144980";
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
                    "-F"
                    "32"
                    "-n"
                    label
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
              content =
                let
                  label = "NixOS-Primary";
                  base-snapshot = "root-base";
                  base-subvol = "root";
                in
                {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "--label"
                    "NixOS-Primary"
                  ];
                  postCreateHook = ''
                    MOUNT="$(mktemp -d)"
                    mount "/dev/disk/by-label/${label}" "$MOUNT" -o subvol=/
                    trap 'umount $MOUNT; rm -rf $MOUNT' EXIT
                    btrfs subvolume snapshot -r "$MOUNT/${base-subvol}" "$MOUNT/${base-snapshot}"
                  '';
                  subvolumes = {
                    "/${base-subvol}" = {
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
                    "${persist-dir}" = {
                      mountpoint = "${persist-dir}";
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
      s970 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S59ANM0R211712J";
        content = {
          type = "gpt";
          partitions = {
            store-1 =
              let
                label = "Store-1";
              in
              {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "--label"
                    "${label}"
                  ];
                  postCreateHook = ''
                    MOUNT="$(mktemp -d)"
                    mount "/dev/disk/by-label/${label}" "$MOUNT" -o subvol=/
                    trap 'umount $MOUNT; rm -rf $MOUNT' EXIT
                    btrfs subvolume snapshot -r "$MOUNT/root" "$MOUNT/root-base"
                  '';
                  subvolumes =
                    let
                      baseMount = "/mnt/${label}";
                    in
                    {
                      "/root" = {
                        mountpoint = "${baseMount}";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "${persist-dir}" = {
                        mountpoint = "${baseMount}/${persist-dir}";
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
      s960 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_960_EVO_1TB_S3ETNX0HB06408W";
        content = {
          type = "gpt";
          partitions = {
            store-1 =
              let
                label = "Store-2";
              in
              {
                size = "100%";
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "--label"
                    "${label}"
                  ];
                  postCreateHook = ''
                    MOUNT="$(mktemp -d)"
                    mount "/dev/disk/by-label/${label}" "$MOUNT" -o subvol=/
                    trap 'umount $MOUNT; rm -rf $MOUNT' EXIT
                    btrfs subvolume snapshot -r "$MOUNT/root" "$MOUNT/root-base"
                  '';
                  subvolumes =
                    let
                      baseMount = "/mnt/${label}";
                    in
                    {
                      "/root" = {
                        mountpoint = "${baseMount}";
                        mountOptions = [
                          "compress=zstd"
                          "noatime"
                        ];
                      };
                      "${persist-dir}" = {
                        mountpoint = "${baseMount}/${persist-dir}";
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
