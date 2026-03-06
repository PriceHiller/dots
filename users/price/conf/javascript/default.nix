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

  programs.bun = {
    enable = true;
    settings = {
      telemetry = false;
      install =
        let
          hours = 60 * 60;
          days = 24 * hours;
        in
        {
          minimumReleaseAge = 14 * days;
          minimumReleaseAgeExcludes = [ "@types/bun" ];
          globalBinDir = "${config.xdg.dataHome}/bun/bin";
          globalDir = "${config.xdg.dataHome}/bun/packages";
          cache.dir = "${config.xdg.cacheHome}/bun/install";
        };
    };
  };

  home = {
    packages = with pkgs; [
      nodejs_latest
      pnpm
      biome
      typescript
      typescript-language-server
      oxlint
      eslint
    ];

    sessionPath = [
      "${npm_paths.prefix}/bin"
      config.programs.bun.settings.install.globalBinDir
    ];

    sessionVariables = {
      ASTRO_TELEMETRY_DISABLED = 1;
      NODE_REPL_HISTORY = "${config.xdg.stateHome}/node_repl_history";
      NPM_CONFIG_USERCONFIG = pkgs.writeText "npm_user_config" ''
        prefix=${npm_paths.prefix}
        cache=${npm_paths.cache}
        logs-dir=${npm_paths.logs-dir}
      '';
    };
  };
}
