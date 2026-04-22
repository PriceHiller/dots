# polkit/default.nix
{ config, lib, ... }:

let
  cfg = config.ext.polkit;

  ruleSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to install this polkit rule.";
      };

      text = lib.mkOption {
        type = lib.types.lines;
        description = "JavaScript source of the polkit rule.";
      };
    };
  };

  ruleType = lib.types.coercedTo lib.types.lines (text: { inherit text; }) ruleSubmodule;

  enabledRules = lib.filterAttrs (_: r: r.enable) cfg.rules;

  # attr name -> /etc path used as the environment.etc key
  etcPathFor = name: "polkit-1/rules.d/${name}.rules";
in
{
  options.ext.polkit = {
    rules = lib.mkOption {
      type = lib.types.attrsOf ruleType;
      default = { };
      example = lib.literalExpression ''
        {
          "10-wheel-nopasswd" = '''
            polkit.addRule(function(action, subject) {
              if (subject.isInGroup("wheel")) return polkit.Result.YES;
            });
          ''';
          "20-disabled-rule" = {
            enable = false;
            text = "/* not installed */";
          };
        }
      '';
      description = ''
        Polkit rules to install under /etc/polkit-1/rules.d/.
        Only takes effect when `security.polkit.enable` is true.
      '';
    };
  };

  config = (lib.mkIf config.security.polkit.enable) {
    environment.etc =
      enabledRules |> lib.mapAttrs' (name: r: lib.nameValuePair (etcPathFor name) { text = r.text; });

    systemd.services.polkit.reloadTriggers =
      enabledRules |> lib.attrNames |> map (name: config.environment.etc.${etcPathFor name}.source);
  };
}
