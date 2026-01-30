{ pkgs, ... }:
{
  environment.persistence.ephemeral.directories = [
    "/var/lib/containers"
    "/var/lib/docker"
  ];

  environment.systemPackages = with pkgs; [
    docker
    podman-compose
  ];

  virtualisation = {
    oci-containers.backend = "podman";
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      autoPrune.enable = true;
    };
  };
}