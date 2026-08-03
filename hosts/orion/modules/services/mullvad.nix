{ ... }:
{
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };
  environment.persistence.ephemeral.directories = [ "/etc/mullvad-vpn" ];
}
