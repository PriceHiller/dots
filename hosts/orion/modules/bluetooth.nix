{
  pkgs,
  ...
}:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman = {
    enable = true;
    # Waiting on https://github.com/NixOS/nixpkgs/issues/514705 to be resolved
    withApplet = false;
  };
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

  ext.polkit.rules."20-blueman" =
    # javascript
    ''
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
