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
            description = "";
            action = "reject";
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
