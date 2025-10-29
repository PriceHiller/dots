{
  config,
  lib,
  ...
}:
let
  cfg = config.ext.logviewer;
in
{
  options.ext.logviewer = {
    enable = lib.options.mkEnableOption "Setup logviewer ACL for system";
    serviceName = lib.options.mkOption {
      description = "The service name to use for creating the log acls";
      default = "setup-logviewer-acls.service";
      type = lib.types.str;
    };
    members = lib.options.mkOption {
      description = "Users to add to the logviewers group";
      type = (lib.types.listOf lib.types.str);
      default = [ ];
    };
    group = lib.options.mkOption {
      description = "The group to use for logviewers";
      type = lib.types.str;
      default = "logviewer";
    };
    paths = lib.options.mkOption {
      description = "Paths to allow read access to for the logviewer group, note that these are recursive";
      type = (lib.types.listOf lib.types.path);
      default = [
        "/var/log"
      ];
    };
  };

  config = lib.mkIf (cfg.enable) {
    users.groups.${cfg.group} = {
      members = cfg.members;
    };

    systemd.tmpfiles.rules =
      cfg.paths
      |> builtins.map (path: [
        "A+ ${path} - - - - group:${cfg.group}:r-x"
        "A+ ${path} - - - - default:group:${cfg.group}:r-x"
      ])
      |> builtins.concatLists;
  };
}
