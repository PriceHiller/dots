{
  pkgs,
  ...
}:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
  environment.systemPackages = with pkgs; [ bluez ];

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [
      "network.target"
      "sound.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  security.polkit.extraConfig = ''
    /* Allow users in wheel group to use blueman feature requiring root without authentication */
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.blueman.network.setup" ||
            action.id == "org.blueman.dhcp.client" ||
            action.id == "org.blueman.rfkill.setstate" ||
            action.id == "org.blueman.pppd.pppconnect") &&
            subject.isInGroup("wheel")) {

            return polkit.Result.YES;
        }
    });
  '';
}
