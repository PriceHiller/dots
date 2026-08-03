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
      LogLevel = 1;
      Rules = {
        EnableChecksums = true;
      };
      Stats = {
        MaxEvents = 1000000;
        MaxStats = 1000000;
      };
      Ebpf = {
        QueueEventsSize = 200;
      };
      ProcMonitorMethod = "ebpf";
      Firewall = config.networking.firewall.backend;
      FwOptions.MonitorInterval = "5s";
    };
    rules =
      let
        resolveSymlink =
          _path:
          let
            pathStr = builtins.toString _path;
            fileType = builtins.readFileType pathStr;
          in
          if fileType == "symlink" then
            lib.strings.trim (
              builtins.readFile (
                pkgs.runCommand "resolved-path" { } ''
                  readlink -f ${_path} > $out
                ''
              )
            )
          else
            pathStr;

        ruleProg = action: _name: progPath: {
          name = "000-${action}-${_name}";
          inherit action;
          enabled = true;
          created = "2026-01-08T13:25:44-06:00";
          updated = "2026-01-08T13:25:44-06:00";
          duration = "always";
          precedence = true;
          nolog = false;
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = (lib.strings.trim progPath);
          };
        };
        rulePathRecursive =
          action: _name:
          let
            name = "000-${action}-path-recursive-${_name}";
          in
          _path: {
            inherit name;
            inherit action;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            duration = "always";
            precedence = true;
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
          rulePathRecursive "allow" name (lib.getBin package);

        allowPackage' =
          name-suffix: package:
          let
            name = "${(lib.getName package)}--${name-suffix}";
          in
          rulePathRecursive "allow" name (lib.getBin package);

        allowExe =
          package:
          let
            name = lib.getName package;
          in
          ruleProg "allow" name ((lib.getExe package) |> resolveSymlink);

        allowExe' =
          package: exeName:
          let
            name = "${(lib.getName package)}-${exeName}";
          in
          ruleProg "allow" name ((lib.getExe' package exeName) |> resolveSymlink);

        mkDestHostsOperator =
          hosts:
          let
            hostsList = if builtins.isList hosts then hosts else [ hosts ];
          in
          if builtins.length hostsList == 1 then
            {
              operand = "dest.host";
              data = builtins.elemAt hostsList 0;
              type = "regexp";
              sensitive = false;
            }
          else
            {
              operand = "dest.host";
              data = "^(${lib.concatStringsSep "|" hostsList})$";
              type = "regexp";
              sensitive = false;
            };

        rulePathRecursiveToHost =
          action: _name:
          let
            name = "000-${action}-path-recursive-${_name}";
          in
          _path: hosts: {
            inherit name;
            inherit action;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            duration = "always";
            precedence = true;
            nolog = false;
            operator = {
              type = "list";
              operand = "list";
              sensitive = false;
              list = [
                (mkDestHostsOperator hosts)
                {
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
                  type = "regexp";
                  sensitive = false;
                }
              ];
            };
          };

        rulePackageToHost =
          action: package: hosts:
          let
            name = lib.getName package;
          in
          rulePathRecursiveToHost action name (lib.getBin package) hosts;

        allowPackageToHost = rulePackageToHost "allow";

        denyPackageToHost = rulePackageToHost "deny";

        rulePathRecursiveToHostRegex =
          _name:
          let
            name = "000-allow-path-recursive-${_name}";
          in
          _path: hostRegex: {
            inherit name;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            action = "allow";
            duration = "always";
            precedence = true;
            nolog = false;
            operator = {
              type = "list";
              operand = "list";
              sensitive = false;
              list = [
                {
                  operand = "dest.host";
                  data = hostRegex;
                  type = "regexp";
                  sensitive = false;
                }
                {
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
                  type = "regexp";
                  sensitive = false;
                }
              ];
            };
          };

        allowPackageToHostRegex =
          package: hostRegex:
          let
            name = "${(lib.getName package)}-regex";
          in
          rulePathRecursiveToHostRegex name (lib.getBin package) hostRegex;

        ruleProgToHostRegex =
          action: progPath: hostRegex:
          let
            progName = builtins.baseNameOf (builtins.toString progPath);
          in
          {
            name = "000-allow-${progName}-to-host-regex";
            inherit action;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            duration = "always";
            precedence = true;
            nolog = false;
            operator = {
              type = "list";
              sensitive = false;
              list = [
                {
                  operand = "dest.host";
                  data = hostRegex;
                  type = "regexp";
                  sensitive = false;
                }
                {
                  operand = "process.path";
                  data = (lib.strings.trim progPath);
                  type = "simple";
                  sensitive = false;
                }
              ];
            };
          };

        ruleProgToHost =
          action: progPath: hosts:
          let
            progName = builtins.baseNameOf (builtins.toString progPath);
          in
          {
            name = "000-allow-${progName}-to-${lib.concatStringsSep "-" hosts}";
            inherit action;
            enabled = true;
            created = "2026-01-08T13:25:44-06:00";
            updated = "2026-01-08T13:25:44-06:00";
            duration = "always";
            precedence = true;
            nolog = false;
            operator = {
              type = "list";
              sensitive = false;
              list = [
                (mkDestHostsOperator hosts)
                {
                  operand = "process.path";
                  data = (lib.strings.trim progPath);
                  type = "simple";
                  sensitive = false;
                }
              ];
            };
          };
      in
      # Mapped with an index so ordering below can be used to decide priority -- since the rules
      # above generally enable precedence ORDERING matters
      #
      # This enables explictly allowing access to only the specified domains and then explicitly
      # disallowing all other domains via a pattern like `allow .*some.host` and then afterwards
      # `dissalow .*`
      lib.imap1
        (
          idx: rule:
          let
            ruleNum = builtins.toString idx;
          in
          rule
          // {
            name =
              if rule.name != null then
                "${ruleNum}-${rule.name}"
              else
                let
                  fallbackName = "${ruleNum}-UNKNOWN-RULE-NAME";
                in
                builtins.warn "No name defined for rule, using a default of ${fallbackName}" fallbackName;

          }
        )
        [
          (allowPackageToHost pkgs.spotify [
            ".*\.spotify\.com"
            ".*\.spotifycdn\.com"
            ".*\.scdn\.co"
          ])
          (denyPackageToHost pkgs.spotify [
            ".*"
          ])

          (allowPackage pkgs.thunderbird)
          (allowPackageToHostRegex pkgs.nodejs_latest ".*.npmjs.org$")
          (allowPackage pkgs.git)
          (allowPackage pkgs.librewolf)
          (allowPackage pkgs.ungoogled-chromium)
          (allowExe pkgs.nsncd)
          (allowExe config.services.dnscrypt-proxy.package)
          (allowExe config.services.dnsmasq.package)
          (allowExe pkgs.openssh)
          # Have to use `nix-cli` as the top level package is symlinked to it,
          # opensnitch wants the resolved path, not the symlink
          (allowPackage config.nix.package.nix-cli)
          (allowPackage config.services.mullvad-vpn.package)
          (allowExe pkgs.dig)
          (allowPackage pkgs.fwupd)
          (allowExe pkgs.strawberry)
          (ruleProg "allow" "systemd-timesyncd" "${lib.getBin pkgs.systemd}/lib/systemd/systemd-timesyncd")
          (allowPackage config.services.avahi.package)
          (allowPackageToHostRegex pkgs.fwupd ".*\.fwupd\.org$")
          (allowPackageToHost pkgs.gh (lib.strings.escapeRegex "api.github.com"))
          (allowPackageToHost pkgs.davfs2 (map lib.strings.escapeRegex [ "fs.pricehiller.com" ]))
          (allowPackageToHost pkgs.sone ".*\.tidal\.com")
          {
            created = "2025-04-09T23:21:35-06:00";
            updated = "2025-04-09T23:21:35-06:00";
            name = "000-allow-localhost-ipv4";
            description = "Allow connections to localhost via IPv4";
            action = "allow";
            duration = "always";
            operator = {
              type = "network";
              operand = "dest.network";
              data = "127.0.0.1/8";
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
            name = "0000-allow-${user}-nix-build-user";
            description = "Allow All Connections for Nix Build Users `nixbld*`";
            action = "allow";
            duration = "always";
            enabled = true;
            precedence = true;
            nolog = false;
            operator = {
              type = "simple";
              operand = "user.id";
              # Needs to be a string, not a number for the match
              data = config.users.users.${user}.uid |> builtins.toString;
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
