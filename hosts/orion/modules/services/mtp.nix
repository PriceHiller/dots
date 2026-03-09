{ pkgs, ... }:
{
  # MTP support
  programs.fuse = {
    userAllowOther = true;
  };
  environment.systemPackages = with pkgs; [
    jmtpfs
  ];
  services.udev.packages = with pkgs; [
    libmtp
  ];
  services.gvfs.enable = true;
}
