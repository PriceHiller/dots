{
  config,
  lib,
  clib,
  pkgs,
  osConfig,
  ...
}:
let
  concatComma = list: (lib.concatStringsSep "," list);
  sslKeyLogFilePath = "${config.xdg.cacheHome}/SSLKEYLOGFILE.log";
in
{
  xdg.mimeApps.defaultApplications = lib.mkIf (config.programs.librewolf.enable) {
    "default-web-browser" = [ "librewolf.desktop" ];
    "text/html" = [ "librewolf.desktop" ];
    "x-scheme-handler/http" = [ "librewolf.desktop" ];
    "x-scheme-handler/https" = [ "librewolf.desktop" ];
    "x-scheme-handler/about" = [ "librewolf.desktop" ];
    "x-scheme-handler/unknown" = [ "librewolf.desktop" ];
    "x-scheme-handler/chrome" = [ "librewolf.desktop" ];
    "application/x-extension-htm" = [ "librewolf.desktop" ];
    "application/x-extension-html" = [ "librewolf.desktop" ];
    "application/x-extension-shtml" = [ "librewolf.desktop" ];
    "application/xhtml+xml" = [ "librewolf.desktop" ];
    "application/x-extension-xhtml" = [ "librewolf.desktop" ];
    "application/x-extension-xht" = [ "librewolf.desktop" ];
  };
  home.file.".librewolf/native-messaging-hosts".enable = false;
  home.file.".mozilla/native-messaging-hosts".enable = false;
  home.file.".librewolf/librewolf.overrides.cfg".enable = false;
  xdg.configFile."librewolf/librewolf/librewolf.overrides.cfg".text =
    let
      mkOverridesFile = prefs: ''
        ${lib.concatStrings (
          lib.mapAttrsToList (name: value: ''
            defaultPref("${name}", ${builtins.toJSON value});
          '') prefs
        )}
      '';
    in
    mkOverridesFile config.programs.librewolf.settings;
  programs.firefox.configPath = "${config.xdg.configHome}/mozilla/firefox";
  programs.librewolf = {
    enable = true;
    configPath = "${config.xdg.configHome}/librewolf/librewolf";
    profiles.default = {
      userChrome = (
        pkgs.runCommand "build-scss"
          {
            nativeBuildInputs = [ pkgs.dart-sass ];

          }
          ''
            sass --style expanded ${./userchrome}/style.scss $out
          ''
      );

    };
    # Most preferences are defined in https://searchfox.org/firefox-release/source/modules/libpref/init/StaticPrefList.yaml
    settings =
      clib.attrsToMozillaPref {
        devtools.debugger.remote-enabled = true;
        toolkit.legacyUserProfileCustomizations.stylesheets = true;
        identity.fxaccounts.enabled = true;
        webgl.disabled = false;
        browser = {
          cache = {
            disk.enable = true;
          };
          policies.runOncePerModification = {
            extensionsInstall = [ ];
            removeSearchEngines = [
              "Bing"
              "Amazon.com"
              "eBay"
              "Twitter"
            ];
            extensionsUninstall = [
              "bing@search.mozilla.org"
              "amazondotcom@search.mozilla.org"
              "ebay@search.mozilla.org"
              "twitter@search.mozilla.org"
            ];
          };
        };
        privacy = {
          resistFingerprinting = false;
          fingerprintingProtection = {
            overrides = concatComma [
              "+AllTargets,+JSLocale,+FontVisibilityRestrictGenerics,-CSSPrefersColorScheme"
            ];
            pbmode = true;
            granularOverrides =
              # See
              # https://searchfox.org/firefox-release/source/toolkit/components/resistfingerprinting/FingerprintingWebCompatService.sys.mjs#22
              # for the schema
              #
              # See
              # https://searchfox.org/firefox-main/source/toolkit/components/resistfingerprinting/RFPTargets.inc
              # for the targets (overrides)
              [
                {
                  firstPartyDomain = "utsa.edu";
                  overrides = [
                    "-JSLocale"
                    "-JSDateTimeUTC"
                  ];
                }
                {
                  firstPartyDomain = "instructure.com";
                  overrides = [
                    "-JSLocale"
                    "-JSDateTimeUTC"
                  ];
                }
                {
                  firstPartyDomain = "github.com";
                  overrides = [
                    "-JSLocale"
                    "-JSDateTimeUTC"
                  ];
                }
                {
                  firstPartyDomain = "localhost";
                  overrides = [ "-AllTargets" ];
                }
                {
                  firstPartyDomain = "dnscrypt.localhost";
                  overrides = [ "-AllTargets" ];
                }
                {
                  firstPartyDomain = "print.localhost";
                  overrides = [ "-AllTargets" ];
                }
                {
                  firstPartyDomain = "pricehiller.com";
                  overrides = [ "-AllTargets" ];
                }
              ]
              |> builtins.map (override: override // { overrides = (concatComma override.overrides); })
              |> builtins.toJSON;
            remoteOverrides.enabled = true;
          };
          clearOnShutdown = {
            history = false;
            downloads = false;
            cookies = false;
          };
        };
        sidebar = {
          main.tools = concatComma [
            "syncedtabs"
            "history"
            "bookmarks"
          ];
          "verticalTabs" = true;
          "verticalTabs.dragToPinPromo.dismissed" = true;
          animation = {
            duration-ms = 40;
            enabled = true;
          };
          revamp = true;
        };
        font = {
          default.x-western = "sans-serif";
          minimum-size.x-western = 18;
        };
        network = {
          cookie.lifetimePolicy = 0;
          # We use the local DNS resolver, it should support encryption
          trr =
            let
              dnscryptCfg = osConfig.services.dnscrypt-proxy;
              dohCfg = dnscryptCfg.settings.local_doh;
              dohUri = "https://${(builtins.elemAt dohCfg.listen_addresses 0)}${dohCfg.path}";
            in
            {
              mode = 3;
              uri = dohUri;
              custom_uri = dohUri;
            };
          dns = {
            echconfig.enabled = true;
            use_https_rr_as_altsvc = true;
          };
          # See https://searchfox.org/firefox-release/source/modules/libpref/init/StaticPrefList.yaml#13784
          # We only send the referer iff hosts match
          http.referer.XOriginPolicy = 3;
        };
      }
      // {
        "privacy.fingerprintingProtection" = true;
      };
  };

  home = {
    # SECURITY: Extract this to a general NixOS module and add a audit rule to watch reads of this
    # file. Should also notify the user when an attempt to read this file occurs. Unlikely to be a
    # true security issue, as if an attacker can already read this then it's already game over and
    # they could trivially access important data on the system anyhow.
    sessionVariables = {
      SSLKEYLOGFILE = "${sslKeyLogFilePath}";
    };
    activation.ensureSSLKeyLogFileExists =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          touch  "${sslKeyLogFilePath}" || true
          # Ensure only the curret user has perms to mess with the file
          chmod 0600 "${sslKeyLogFilePath}"
        '';
  };
}
