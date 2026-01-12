{
  lib,
  pkgs,
  config,
  ...
}:
{
  networking.firewall.enable = false;
  services.opensnitch = {
    enable = true;
    settings = {
      Firewall = config.networking.firewall.backend;
    };
    rules =
      let
        allowProg = name: progPath: {
          inherit name;
          enabled = true;
          created = "2026-01-08T13:25:44-06:00";
          updated = "2026-01-08T13:25:44-06:00";
          action = "allow";
          duration = "always";
          precendence = false;
          nolog = false;
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = progPath;
            list = [ ];
          };
        };
      in
      [
        (allowProg "git" "${lib.getExe pkgs.git}")
        (allowProg "nsncd" "${lib.getExe pkgs.nsncd}")
        (allowProg "dnscrypt-proxy" "${lib.getExe config.services.dnscrypt-proxy.package}")
        (allowProg "dnsmasq" "${lib.getExe config.services.dnsmasq.package}")
        (allowProg "ssh" "${lib.getExe pkgs.openssh}")
        (allowProg "system-nix" "${lib.getExe config.nix.package}")
        (allowProg "nix" "${lib.getExe pkgs.nix}")
        (allowProg "mullvad" "${lib.getExe config.services.mullvad-vpn.package}")
        (allowProg "dig" "${lib.getExe pkgs.dig}")
        (allowProg "fwupd" "${lib.getExe pkgs.fwupd}")
        (allowProg "spotify" "${lib.getExe pkgs.spotify}")
        (allowProg "strawberry" "${lib.getExe pkgs.strawberry}")
        (allowProg "spotify" "${lib.getExe pkgs.equibop}")
        (allowProg "systemd-timesyncd" "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd")
        (allowProg "avahi-daemon" "${lib.getExe' config.services.avahi.package "avahi-daemon"} ")
        (allowProg "avahi-resolve" "${lib.getExe' config.services.avahi.package "avahi-resolve"} ")
        (allowProg "avahi-browse" "${lib.getExe' config.services.avahi.package "avahi-browse"} ")
        (allowProg "avahi-dnsconfd" "${lib.getExe' config.services.avahi.package "avahi-dnsconfd"} ")
        (allowProg "avahi-publish" "${lib.getExe' config.services.avahi.package "avahi-publish"} ")
        (allowProg "avahi-autoipd" "${lib.getExe' config.services.avahi.package "avahi-autoipd"} ")
        (allowProg "avahi-set-host-name" "${lib.getExe' config.services.avahi.package "avahi-set-host-name"} ")
        {
          created = "2023-07-05T10:46:47.904024069+01:00";
          updated = "2023-07-05T10:46:47.921828104+01:00";
          name = "000-allow-localhost";
          enabled = true;
          precedence = true;
          action = "allow";
          duration = "always";
          operator = "dest.network";
          type = "network";
          nolog = false;
          operand = "dest.network";
          sensitive = false;
          data = "127.0.0.0/8";
          list = [ ];
        }
        {
          created = "2024-05-31T23:39:28+02:00";
          updated = "2024-05-31T23:39:28+02:00";
          name = "000-block-ld-preload";
          description = "";
          action = "reject";
          duration = "always";
          enabled = true;
          precedence = true;
          nolog = false;
          operator = {
            operand = "process.env.LD_PRELOAD";
            data = "^(\\.|/).*";
            type = "regexp";
            sensitive = false;
          };
        }
      ]
      |> builtins.foldl' (acc: prog: acc // { ${prog.name} = prog; }) { };
  };

  environment.persistence.ephemeral.directories = [
    "/etc/opensnitchd/rules/"
  ];
}