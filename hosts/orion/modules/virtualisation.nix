{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker-compose
    virt-manager
    spice
    virtio-win
    win-spice
    adwaita-icon-theme
  ];
  programs = {
    virt-manager.enable = true;
    dconf.enable = true;
  };
  virtualisation = {
    libvirtd = {
      enable = true;
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
