{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ docker-compose ];

  programs.virt-manager.enable = true;
  virtualisation = {
    libvirtd.enable = true;
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
    };
  };
}
