# polkit/default.nix
{ config, lib, ... }:

let
  cfg = config.ext.polkit;

  ruleSubmodule = lib.types.submodule (
    { ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to install this polkit rule.";
        };

        text = lib.mkOption {
          type = lib.types.lines;
          description = ''
            Text of the polkit rule

            See https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html#polkit-rules
          '';
        };
      };
    }
  );

  ruleType = lib.types.coercedTo lib.types.lines (text: { inherit text; }) ruleSubmodule;
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
        The attribute name is used as the file name (with `.rules` appended).
        A value may be a plain string (the rule text) or an attrset
        `{ enable, text }`.
      '';
    };
  };

  config = (lib.mkIf config.security.polkit.enable) {
    environment.etc =
      cfg.rules
      |> lib.filterAttrs (_: r: r.enable)
      |> lib.mapAttrs' (name: r: lib.nameValuePair "polkit-1/rules.d/${name}.rules" { text = r.text; });
  };
}
