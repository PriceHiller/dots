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
        allowProg = _name: progPath: {
          name = "000-allow-${_name}";
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
            data = (lib.strings.trim progPath);
          };
        };
        allowPathRecursive =
          _name:
          let
            name = "000-allow-path-recursive-${_name}";
          in
          _path: {
            inherit name;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            action = "allow";
            duration = "always";
            precendence = false;
            nolog = false;
            operator = {
              type = "regexp";
              sensitive = false;
              operand = "process.path";
              data = "^(${
                (
                  _path
                  |> builtins.toString
                  |> lib.strings.trim
                  |> lib.strings.removeSuffix "/"
                  |> lib.strings.escapeRegex
                )
              })/.*";
            };
          };
        allowPackage =
          package:
          let
            name = lib.getName package;
          in
          allowPathRecursive name (lib.getBin package);

        allowExe =
          package:
          let
            name = lib.getName package;
          in
          allowProg name (lib.getExe package);

        allowExe' =
          package: exeName:
          let
            name = "${(lib.getName package)}-${exeName}";
          in
          allowProg name (lib.getExe' package exeName);
      in
      [
        (allowPackage pkgs.git)
        (allowPackage pkgs.spotify)
        (allowPackage pkgs.thunderbird)
        (allowPackage pkgs.git)
        (allowExe pkgs.nsncd)
        (allowExe config.services.dnscrypt-proxy.package)
        (allowExe config.services.dnsmasq.package)
        (allowExe pkgs.openssh)
        (allowPackage pkgs.nix)
        (allowPackage config.nix.package)
        (allowPackage config.services.mullvad-vpn.package)
        (allowExe pkgs.dig)
        (allowPackage pkgs.fwupd)
        (allowExe pkgs.strawberry)
        (allowPackage pkgs.equibop)
        (allowProg "systemd-timesyncd" "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd")
        (allowPackage config.services.avahi.package)
        {
          created = "2025-04-09T23:21:35-06:00";
          updated = "2025-04-09T23:21:35-06:00";
          name = "000-allow-localhost-ipv4";
          description = "Allow connections to localhost via IPv4";
          action = "allow";
          duration = "always";
          operator = {
            operand = "dest.ip";
            data = "127.0.0.1";
            type = "simple";
            list = [ ];
            sensitive = false;
          };
          enabled = true;
          precedence = true;
          nolog = false;
        }
        {
          created = "2025-04-09T23:17:39-06:00";
          updated = "2025-04-09T23:17:39-06:00";
          name = "000-allow-localhost6";
          description = "Allow connections to localhost via IPv6";
          action = "allow";
          duration = "always";
          operator = {
            operand = "dest.network";
            data = "::1/128";
            type = "network";
            list = [ ];
            sensitive = false;
          };
          enabled = true;
          precedence = true;
          nolog = false;
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
      # Allow all connections for nix builds `nixbld*` users
      ++ (
        config.nix.nrBuildUsers
        |> builtins.genList (
          num:
          let
            # Users start from `nixbld1`
            user = "nixbld${builtins.toString (num + 1)}";
          in
          {
            created = "2024-05-31T23:39:28+02:00";
            updated = "2024-05-31T23:39:28+02:00";
            name = "000-allow-${user}-user";
            description = "Allow All Connections for Nix Build Users `nixbld*`";
            action = "allow";
            duration = "always";
            enabled = true;
            precedence = true;
            nolog = false;
            operator = {
              type = "simple";
              operand = "user.uid";
              data = config.users.users.${user}.uid;
              sensitive = false;
            };
          }
        )
      )
      |> builtins.foldl' (acc: prog: acc // { ${prog.name} = prog; }) { };
  };

  environment.persistence.ephemeral.directories = [
    "/etc/opensnitchd/rules/"
  ];
}
