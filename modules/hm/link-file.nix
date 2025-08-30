{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = lib.filterAttrs (_: conf: conf.enable) config.link;
in
{
  options = {
    link = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, value, ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
                description = "Link the source to the target";
              };
              source = lib.mkOption {
                type = lib.types.oneOf [
                  lib.types.nonEmptyStr
                  lib.types.Path
                ];
                default = "${value}";
                description = "The path (optionally with unexpanded variables) to link from";
              };
              target = lib.mkOption {
                type = lib.types.oneOf [
                  lib.types.nonEmptyStr
                  lib.types.Path
                ];
                default = "${name}";
                description = "The (optionally with unexpanded variables) path to link to";
              };
              svc-name = lib.mkOption {
                type = lib.types.str;
                default =
                  let
                    replaceNonAlnum =
                      rep: str:
                      (builtins.foldl' (x: y: if builtins.isString y then x + y else x + rep) "" (
                        builtins.split "[^[:alnum:]]" str
                      ));
                    mkLinkName = targetPath: "hm-link-${(replaceNonAlnum "-" targetPath)}";
                  in
                  mkLinkName name;
                description = "The full systemd service name.";
                readOnly = true;
              };
            };
          }
        )
      );
    };
  };

  config =
    let
      eachEnabledLink = f: lib.mapAttrs' (_: config: lib.nameValuePair config.svc-name (f config)) cfg;
    in
    {
      systemd.user.targets.hm-link-files = {
        Unit = {
          Description = "Target to trigger symlink job for home manager";
          Requires = [
            "default.target"
            "agenix.service"
          ];
          After = [
            "default.target"
            "agenix.service"
          ];
        };
        Install.WantedBy = [ "default.target" ];
      };
      systemd.user.services = eachEnabledLink (cfg: {
        Unit = {
          Description = "Link '${cfg.source}' -> '${cfg.target}' after expanding shell variables";
        };
        Service = {
          Type = "oneshot";
          ExecStart =
            let
              source = cfg.source;
              target = cfg.target;
            in
            "${pkgs.writeShellScriptBin "link" ''
              mkdir -p "$(${pkgs.coreutils}/bin/dirname "${target}")/" 2>/dev/null || true
              if ! [[ -L '${target}' ]]; then
                mv '${target}' "${target}.$(${pkgs.coreutils}/bin/date +'%y-%d-%m').old" 2>/dev/null || true
              fi
              echo "Linking '${source}' to '${target}'"
              ${pkgs.coreutils}/bin/ln -sf "${source}" "${target}"
            ''}/bin/link";
        };
        Install.WantedBy = [ "hm-link-files.target" ];
      });
    };
}
