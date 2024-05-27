{ pkgs, ... }: {
  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };
  environment.persistence.ephemeral.directories = [
    "/etc/mullvad-vpn"
  ];
}