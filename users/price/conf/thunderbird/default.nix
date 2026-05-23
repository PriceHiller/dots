{
  pkgs,
  config,
  lib,
  clib,
  ...
}:
let
  colors = clib.kcolors;
  hx = colors.hex;
in
{
  programs.thunderbird = {
    enable = true;
    package = pkgs.thunderbird.override {
      extraPolicies.ExtensionSettings = {
        "markdown-here-revival@xul.calypsoblue.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.thunderbird.net/user-media/addons/_attachments/988035/markdown_here_revival-4.0.7-tb.xpi";
        };
      };
    };
    settings = clib.attrsToMozillaPref {
      intl.date_time.pattern_override.time_short = "h:mm aaaa";
      mail = {
        threadpane.listview = 1;
        cloud_files.enabled = false;
      };
      mailnews = {
        tags =
          lib.mapAttrs' (name: value: (lib.nameValuePair (lib.toLower name) (value // { tag = "${name}"; })))
          <| {
            Github.color = "#${hx.sakuraPink}";
            USAA.color = "#${hx.crystalBlue}";
            Personal.color = "#${hx.peachRed}";
            Finance.color = "#${hx.carpYellow}";
            College.color = "#${hx.surimiOrange}";
            Monitoring.color = "#${hx.springGreen}";
          };
        headers = {
          showSender = true;
          showUserAgent = true;
          sendUserAgent = false;
        };
        sanitize_date_header = true;
        suppress_content_language = true;
        display = {
          date_senders_timezone = true;
        };
      };
      # Isolate cookies
      network.cookie.cookieBehavior = 5;
      browser.aboutConfig.showWarning = false;

      # === Disable Telemetry === #
      datareporting = {
        usage.uploadEnabled = false;
        healthreport.uploadEnabled = false;
        policy = {
          dataSubmissionEnabled = false;
          dataSubmissionPolicyBypassNotification = true;
        };
      };
      dom.security.unexpected_system_load_telemetry_enabled = false;
      privacy.trackingprotection.origin_telemetry.enabled = false;
      telemetry.origin_telemetry_test_mode.enabled = false;
      toolkit = {
        coverage = {
          opt-out = true;
          endpoint.base = "";
        };
        telemetry = {
          server = "http://no-telemetry.pricehiller.com";
          enabled = false;
          rejected = true;
          prompted = 2;
          archive.enabled = false;
          bhrPing.enabled = false;
          ecosystemtelemetry.enabled = false;
          firstShutdownPing.enabled = false;
          newProfilePing.enabled = false;
          shutdownPingSender.enabled = false;
          shutdownPingSender.enabledFirstSession = false;
          updatePing.enabled = false;
          unified = false;
          coverage.opt-out = true;
        };
      };
      app = {
        shield.optoutstudies.enabled = false;
        normandy = {
          enabled = false;
          api_url = "";
        };
        donation.eoy.version.viewed = 999;
      };
      breakpad.reportURL = "";
      browser = {
        crashReports.unsubmittedCheck.autoSubmit2 = false;
        tabs.crashReporting.sendReport = false;
        urlbar = {
          quicksuggest.enabled = false;
          suggest.quicksuggest = {
            nonsponsored = false;
            sponsored = false;
          };
        };
      };
      captivedetect.canonicalURL = "";
      network = {
        trr.confirmation_telemetry_enabled = false;
        captive-portal-service.enabled = false;
        connectivity-service.enabled = false;
        prefetch-next = false;
        predictor = {
          enabled = false;
          enable-prefetch = false;
          http.speculative-parallel-limit = 0;
        };
      };
      mail = {
        rights.override = true;
        instrumentation = {
          postUrl = "";
          askUser = false;
          userOptedIn = false;
        };
      };
      geo.provider.use_geoclue = false;
      extensions.htmlaboutaddons.recommendations.enabled = false;
      # === Disable Telemetry === #

      # Enable user Chrome
      toolkit.legacyUserProfileCustomizations.stylesheets = true;
    };
    profiles = {
      "default" = {
        isDefault = true;
        withExternalGnupg = true;
        userChrome = lib.mkMerge [
          # css
          ''
            .calendar-task-tree > treechildren::-moz-tree-row(inprogress, selected, focus) {
              background-color: #00ff0050 !important;
            }

            /* Month calendar colors for days */
            calendar-day-label {
              &[relation="today"] {
                color: #${hx.peachRed} !important;
              }
            }

            .calendar-month-day-box-current-month[relation="today"],
            .calendar-month-day-box-day-off[relation="today"],
            .calendar-month-day-box-other-month[relation="today"] {
              background-color: #${hx.sakuraPink}20 !important;
              border: 1px solid #${hx.sakuraPink} !important;
            }

            .calendar-month-day-box-current-month[selected="true"],
            .calendar-month-day-box-day-off[selected="true"],
            .calendar-month-day-box-other-month[selected="true"] {
              background-color: #${hx.crystalBlue}20 !important;
              border: 1px solid #${hx.crystalBlue} !important;
            }
          ''
        ];

        accountsOrder = [
          "price@pricehiller.com"
          "price.hiller@my.utsa.edu"
          "price@price-hiller.com"
          "monitor@pricehiller.com"
          "philler3138@gmail.com"
        ];
      };
    };
  };
  xdg = {
    desktopEntries.thunderbird = {
      name = "thunderbird";
      exec = "${pkgs.thunderbird}/bin/thunderbird";
      icon = "${pkgs.thunderbird}/share/icons/hicolor/128x128/apps/thunderbird.png";
    };
    mimeApps = {
      associations.added = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "text/calendar" = [ "thunderbird.desktop" ];
      };
      defaultApplications = {
        "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
        "text/calendar" = [ "thunderbird.desktop" ];
      };
    };
  };
  accounts = {
    calendar = {
      accounts = {
        "Calendar" =
          let
            emailCfg = config.accounts.email.accounts."price@pricehiller.com";
          in
          {
            primary = true;
            primaryCollection = "17807AC1-891A-4418-A189-DB3CA6BF4D0D";
            thunderbird.enable = true;
            remote = {
              url = "https://purelymail.com";
              type = "caldav";
              userName = emailCfg.userName;
              passwordCommand = emailCfg.passwordCommand;
            };
          };
      };
    };
    email =
      let
        thunderbirdFilters = [
          {
            name = "Tag USAA Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "usaa";
            condition = "OR (all addresses,contains,usaa) OR (subject,contains,usaa) OR (subject,contains,USAA)";
          }
          {
            name = "Tag Github Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "github";
            condition = "AND (all addresses,contains,github)";
          }
          {
            name = "Tag Capital One Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "finance";
            condition = "AND (all addresses,contains,capitalone.com)";
          }
          {
            name = "Tag Monitoring Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "monitoring";
            condition = "AND (to,contains,pricehiller.com) AND (from,contains,pricehiller.com)";
          }
          {
            name = "Tag Personal Emails";
            enabled = true;
            type = "81";
            action = "AddTag";
            actionValue = "personal";
            condition = "OR (all addresses,contains,jhiller@ccn-law.com) OR (all addresses,contains,samovepros@live.com) OR (all addresses,contains,avidgolfer@me.com) OR (all addresses,contains,sunnydays352@yahoo.com)";
          }
        ];
      in
      {
        maildirBasePath = "${config.xdg.dataHome}/mail/";
        accounts =
          let
            setReplyLocation = id: {
              "mail.identity.id_${id}.reply_on_top" = 1;
              "mail.identity.id_${id}.sig_bottom" = false;
            };
          in
          {
            "price@pricehiller.com" = rec {
              realName = "Price Hiller";
              address = "price@pricehiller.com";
              userName = address;
              primary = true;
              gpg = {
                key = "C3FADDE7A8534BEB";
                signByDefault = true;
              };
              thunderbird = {
                enable = true;
                messageFilters = thunderbirdFilters;
                settings = id: (setReplyLocation id);
              };
              imap = {
                host = "imap.purelymail.com";
                port = 993;
              };
              smtp = {
                host = "smtp.purelymail.com";
                port = 465;
              };
              passwordCommand = "cat ${config.age.secrets."mail-price--pricehiller.com".path}";
            };
            "price@price-hiller.com" = rec {
              realName = "Price Hiller";
              address = "price@price-hiller.com";
              userName = address;
              gpg = {
                key = "C3FADDE7A8534BEB";
                signByDefault = true;
              };
              thunderbird = {
                enable = true;
                messageFilters = thunderbirdFilters;
                settings = id: (setReplyLocation id);
              };
              imap = {
                host = "imap.purelymail.com";
                port = 993;
              };
              smtp = {
                host = "smtp.purelymail.com";
                port = 465;
              };
              passwordCommand = "cat ${config.age.secrets."mail-price--price-hiller.com".path}";
            };
            "monitor@monitoring.pricehiller.com" = rec {
              realName = "Monitor";
              address = "monitor@monitoring.pricehiller.com";
              userName = address;
              thunderbird = {
                enable = true;
                messageFilters = thunderbirdFilters;
                settings = id: (setReplyLocation id);
              };
              imap = {
                host = "imap.purelymail.com";
                port = 993;
              };
              smtp = {
                host = "smtp.purelymail.com";
                port = 465;
              };
              passwordCommand = "cat ${config.age.secrets."mail-monitor--monitoring.pricehiller.com".path}";
            };
            "philler3138@gmail.com" = rec {
              realName = "Price Hiller";
              address = "philler3138@gmail.com";
              userName = address;
              flavor = "gmail.com";
              passwordCommand = "cat ${config.age.secrets."mail-philler3138--gmail.com".path}";
              thunderbird = {
                enable = true;
                messageFilters = thunderbirdFilters;
                settings = id: (setReplyLocation id);
              };
            };
            "price.hiller@my.utsa.edu" = rec {
              realName = "Price Hiller";
              address = "price.hiller@my.utsa.edu";
              userName = address;
              flavor = "outlook.office365.com";
              passwordCommand = "cat ${config.age.secrets."mail-price.hiller--my.utsa.edu".path}";
              thunderbird = {
                enable = true;
                settings =
                  id:
                  {
                    # Set OAuth2 as the authentication method in Thunderbird
                    "mail.server.server_${id}.authMethod" = 10;
                    "mail.smtpserver.smtp_${id}.authMethod" = 10;
                  }
                  // (setReplyLocation id);
                messageFilters = [
                  {
                    name = "Tag College Emails";
                    enabled = true;
                    type = "81";
                    action = "AddTag";
                    actionValue = "college";
                    condition = "ALL";
                  }
                ];
              };
              imap = {
                host = "outlook.office365.com";
                port = 993;
              };
              smtp = {
                host = "smtp.office365.com";
              };
            };
          };
      };
  };
}
