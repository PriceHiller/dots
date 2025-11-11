{
  pkgs,
  config,
  lib,
  ...
}:
let
  npm_paths = {
    prefix = "${config.xdg.dataHome}/npm";
    cache = "${config.xdg.cacheHome}/npm";
    logs-dir = "${config.xdg.stateHome}/npm/logs";
  };
in
{
  xdg =
    let
      placeholder = {
        enable = true;
        recursive = true;
        force = true;
        text = "created by nix home-manager to ensure dir exists";
      };
    in
    {
      cacheFile."${npm_paths.cache}/.hm-dir" = placeholder;
      stateFile."${npm_paths.logs-dir}/.hm-dir" = placeholder;
      dataFile = {
        "${npm_paths.prefix}/lib/.hm-dir" = placeholder;
      }
      # "${npm_paths.prefix}/lib/node_modules/@vue/typescript-plugin" =
      #   {
      #     source = "${pkgs.vue-language-server}/lib/node_modules/@vue/language-server";
      #     recursive = true;
      #   }

      # Install some global npm packages via Nix
      //
        lib.attrsets.mapAttrs'
          (name: value: {
            name = "${npm_paths.prefix}/lib/node_modules/${name}";
            value = {
              source = "${value}";
            };
          })
          {
            "@vue/typescript-plugin" =
              "${pkgs.vue-language-server}/lib/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin";
          };
    };

  home = {
    packages = with pkgs; [
      nodePackages_latest.nodejs
      typescript
      typescript-language-server
      oxlint
      eslint
      firebase-tools
    ];

    sessionPath = [
      "${npm_paths.prefix}/bin"
    ];

    sessionVariables = {
      NPM_CONFIG_USERCONFIG = pkgs.writeText "npm_user_config" ''
        prefix=${npm_paths.prefix}
        cache=${npm_paths.cache}
        logs-dir=${npm_paths.logs-dir}
      '';
    };
  };
}
