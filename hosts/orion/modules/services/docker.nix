{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation = {
    oci-containers.backend = "docker";
    containers.enable = true;
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      autoPrune.enable = true;
      package = pkgs.docker;
    };
  };
}
