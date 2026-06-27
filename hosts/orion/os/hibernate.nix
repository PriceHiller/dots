{ ... }:

{
  # Resume from hibernation via the btrfs swapfile on the LUKS-mapped device.
  # With systemd-based initrd, systemd-hibernate-resume runs after
  # systemd-cryptsetup.target, so the mapper device is available at resume time.
  boot.resumeDevice = "/dev/mapper/crypted";

  # Physical byte offset of /swap/swapfile on the btrfs filesystem.
  # This value is specific to the current swapfile allocation and must be
  # updated if the swapfile is ever deleted and recreated (e.g. after a
  # disko reinstall). Regenerate with:
  #   sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
  boot.kernelParams = [ "resume_offset=60040448" ];
}
