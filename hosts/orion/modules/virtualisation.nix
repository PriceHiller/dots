{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    docker-compose
    virt-manager
    spice
    virtio-win
    virtiofsd
    win-spice
    adwaita-icon-theme
  ];
  programs = {
    virt-manager.enable = true;
    dconf.enable = true;
  };
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      shutdownTimeout = 30;
      enable = true;
      parallelShutdown = 4;
      onBoot = "ignore";
      qemu = {
        runAsRoot = false;
        swtpm.enable = true;
      };
    };
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
    };
  };
}