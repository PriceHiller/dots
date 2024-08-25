# TODO: Allow the rollback of multiple different subvolumes. Probably utilizing service templates (https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html#Service%20Templates)
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.services.btrfs-rollback;
in
{
  options.services.btrfs-rollback = {
    enable = lib.mkEnableOption "BTRFS Rollback on boot";
    diskLabel = lib.mkOption {
      description = "The disk with the given label to rollback";
      type = lib.types.str;
    };
    subvolume = lib.mkOption {
      description = "The subvolume to rollback";
      type = lib.types.str;
    };
    snapshot = lib.mkOption {
      description = "The base snapshot to restore on rollback";
      type = lib.types.str;
    };
    searchAttempts = lib.mkOption {
      description = ''
        The number of attempts that should be made to locate the labeled disk.

        This may need to be increased if the given disk does in fact exist, but the rollback is
        failing.
      '';
      type = lib.types.ints.unsigned;
      default = 50;
    };
  };

  config = lib.mkIf (cfg.enable && config.boot.initrd.systemd.enable) {
    boot.initrd.systemd = {
      initrdBin = with pkgs; [
        libuuid
        gawk
      ];
      services.rollback = {
        description = "Rollback btrfs root subvolume";
        wantedBy = [ "initrd.target" ];
        before = [ "sysroot.mount" ];
        after = [ "initrd-root-device.target" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = # bash
          ''
            mkdir -p /mnt
            DISK_LABEL="${cfg.diskLabel}"
            FOUND_DISK=0
            SEARCH_ATTEMPTS="${builtins.toString cfg.searchAttempts}"
            printf "Attempting to find disk with label '%s'\n" "$DISK_LABEL"
            while ((SEARCH_ATTEMPTS > 0)); do
              if findfs LABEL="$DISK_LABEL"; then
                FOUND_DISK=1
                printf "Found disk!\n"
                break;
              fi
              ((SEARCH_ATTEMPTS--))
              sleep .1
              printf "Remaining disk discovery attempts: %s\n" "$SEARCH_ATTEMPTS"
            done

            if (( FOUND_DISK == 0 )); then
              printf "Discovery of disk with label '%s' failed! Cannot rollback!\n" "$DISK_LABEL" >&2
              exit 1
            fi

            mount -t btrfs -o subvol=/ $(findfs LABEL="$DISK_LABEL") /mnt
            btrfs subvolume list -to "/mnt/${cfg.subvolume}" \
              | awk 'NR>2 { printf $4"\n" }' \
              | while read subvol; do
              printf "Removing Subvolume: %s\n" "$subvol";
              btrfs subvolume delete "/mnt/$subvol"
            done

            printf "Removing ${cfg.subvolume} subvolume\n"
            btrfs subvolume delete "/mnt/${cfg.subvolume}"

            printf "Restoring base ${cfg.subvolume} subvolume from snapshot ${cfg.snapshot}\n"
            btrfs subvolume snapshot "/mnt/${cfg.snapshot}" "/mnt/${cfg.subvolume}"

            umount /mnt
          '';
      };
    };
  };
}
