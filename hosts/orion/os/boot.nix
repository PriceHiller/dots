{ modulesPath, pkgs, ... }:
{

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelModules = [ "kvm-intel" ];
    kernelParams = [ "audit=1" ];
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
        initrdBin = [
          pkgs.libuuid
          pkgs.gawk
        ];
        services.rollback = {
          description = "Rollback btrfs root subvolume";
          wantedBy = [ "initrd.target" ];
          before = [ "sysroot.mount" ];
          after = [ "initrd-root-device.target" ];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt
            DISK_LABEL="NixOS-Primary"
            FOUND_DISK=0
            ATTEMPTS=50
            printf "Attempting to find disk with label '%s'\n" "$DISK_LABEL"
            while ((ATTEMPTS > 0)); do
              if findfs LABEL="$DISK_LABEL"; then
                FOUND_DISK=1
                printf "Found disk!\n"
                break;
              fi
              ((ATTEMPTS--))
              sleep .1
              printf "Remaining disk discovery attempts: %s\n" "$ATTEMPTS"
            done
            if (( FOUND_DISK == 0 )); then
              printf "Discovery of disk with label '%s' failed! Cannot rollback!\n" "$DISK_LABEL"
              exit 1
            fi

            mount -t btrfs -o subvol=/ $(findfs LABEL="$DISK_LABEL") /mnt
            btrfs subvolume list -to /mnt/root \
              | awk 'NR>2 { printf $4"\n" }' \
              | while read subvol; do
              printf "Removing Subvolume: %s\n" "$subvol";
              btrfs subvolume delete "/mnt/$subvol"
            done

            printf "Removing /root subvolume\n"
            btrfs subvolume delete /mnt/root

            printf "Restoring base /root subvolume\n"
            btrfs subvolume snapshot /mnt/root-base /mnt/root

            umount /mnt
          '';
        };
      };
    };
  };
}
