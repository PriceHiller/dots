{
  pkgs,
  ...
}:
let
  domain = "webtech.pricehiller.com";
in
{
  systemd.timers.check-webtech-up = {
    description = "Trigger domain check for `${domain}`";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:15";
      OnActiveSec = 0;
    };
  };
  systemd.services.check-webtech-up = {
    description = "Check if `${domain}` is up and send an email when it's not";

    after = [
      "network.target"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.curl
      pkgs.msmtp
      pkgs.bash
      pkgs.coreutils
      pkgs.util-linux
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.writeShellScriptBin "check-up" (builtins.readFile ./check.bash)}/bin/check-up '${domain}'";
    };
  };
}
