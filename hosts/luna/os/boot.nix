{ ... }:
{
  services.btrfs-rollback = {
    enable = true;
    diskLabel = "NixOS-Primary";
    subvolume = "root";
    snapshot = "root-base";
  };

  boot = {
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
    };
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "audit=1" ];
    initrd = {
      systemd.enable = true;
    };
  };
}
