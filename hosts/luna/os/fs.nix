{ lib, ... }:
let
  persist-dir = "/persist";
in
{
  environment.persistence.save = {
    hideMounts = true;
    persistentStoragePath = "${persist-dir}/save";
    directories = [
      # Persist log files
      "/var/log"
      "/var/lib/lastlog"
    ];
  };

  environment.persistence.critical = {
    persistentStoragePath = "${persist-dir}/critical";
    hideMounts = true;
    files = [
      # Persist machine id
      # See https://nixos.org/manual/nixos/stable/#sec-machine-id
      "/etc/machine-id"
    ];
    directories = builtins.concatLists [
      [
        # Persist systemd state
        # see https://nixos.org/manual/nixos/stable/#sec-var-systemd
        "/var/lib/systemd"
      ]

      # Persist important state for users
      # see https://nixos.org/manual/nixos/stable/#sec-state-users
      [
        "/var/lib/nixos"
      ]
    ];
  };

  environment.persistence.ephemeral = {
    persistentStoragePath = "${persist-dir}/ephemeral";
    hideMounts = true;

    directories = [
      # Systemd needs the `/usr` directory to exist on boot -- see
      # https://github.com/nix-community/impermanence/issues/253#issuecomment-2614528056
      "/usr/systemd-placeholder"

      # TODO: Remove this and correctly identify all specific directories to persist
      # Generically hang onto state from most services
      "/var/lib"
    ];
  };

  system.activationScripts."var-lib-private-perms" = {
    # Ensure the systemd private directory has the correct permissions set
    #
    # Impermanence will create the outer parent directory and set wrong permissions for it if any
    # path within is persisted, thus we need to set it back to what systemd expects
    deps = [
      "persist-files"
      "createPersistentStorageDirs"
    ];
    text = ''
      mkdir -p /var/lib/private
      chmod 0700 /var/lib/private
    '';
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
  };

  fileSystems."${persist-dir}".neededForBoot = true;

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
