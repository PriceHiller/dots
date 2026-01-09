{
  pkgs,
  lib,
  config,
  ...
}:
let
  # TODO: Integrate the below to use custom user plugins
  # in equibop
  mergeScript =
    pkgs.writeShellApplication {
      name = "merge-json";
      runtimeInputs = with pkgs; [
        jq
      ];
      text = ''
        merge_json() {
        	local file="$1"
        	local new_json="$2"

        	if [ -f "$file" ]; then
        		jq ". * $new_json" "$file" >tmp.json && mv tmp.json "$file"
        	else
        		echo "$new_json" | jq '.' >"$file"
        	fi
        }

        merge_json "$@"
      '';
    }
    |> lib.getExe;
  nixcordCfg = config.programs.nixcord;
  updatedState = builtins.toJSON {
    firstLaunch = false;
    equicordDir = nixcordCfg.discord.equicord.package.overrideAttrs (o: {
      patchPhase = (o.patchPhase or "") + ''
        ls -alh
        ls -alh src
        mkdir -p ./src/userplugins
        cp -r ${./userplugins}/* ./src/userplugins/
      '';
    });
  };
in
{
  home = {
    activation.writeEquibopEquicordDirectory =
      lib.hm.dag.entryAfter [ "writeBoundary" ]
        # bash
        ''
          run echo "Got merge as '${updatedState}'"
          run ${mergeScript} "${config.xdg.configHome}/equibop/state.json" '${updatedState}'
        '';
    packages = [
      pkgs.equibop
    ];
  };

  programs.nixcord = {
    enable = true;
    discord = {
      vencord.enable = false;
    };
    config = {
      themeLinks = [
        "https://mwittrien.github.io/BetterDiscordAddons/Themes/EmojiReplace/base/Apple.css"
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-catppuccin-mocha.theme.css"
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-catppuccin-macchiato.theme.css"
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-rose-pine.theme.css"
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-rose-pine-moon.theme.css"
        "https://raw.githubusercontent.com/refact0r/midnight-discord/refs/heads/master/themes/flavors/midnight-tokyo-night.theme.css"
        "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/latte.theme.css"
        "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/frappe.theme.css"
        "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/macchiato.theme.css"
        "https://raw.githubusercontent.com/catppuccin/discord/refs/heads/main/themes/mocha.theme.css"
      ];
      themes = {
        catpuccin-latte = ./themes/catpuccin-latte.css;
        apple-emoji-replace = ./themes/apple-emoji-replace.css;
      };
      enabledThemes = [
        "catpuccin-latte.css"
        "apple-emoji-replace.css"
      ];
    };
    equibop = {
      enable = true;
      package = null;
    };

    equibopConfig = {
      plugins = {
        allCallTimers = {
          enable = true;
          showWithoutHover = true;
          watchLargeGuilds = false;
        };
        alwaysAnimate = {
          enable = true;
          icons = true;
          nameplates = true;
          roleGradients = true;
          serverBanners = true;
          statusEmojis = true;
        };
        alwaysExpandRoles = {
          enable = true;
          hideArrow = false;
        };
        alwaysTrust = {
          domain = true;
          enable = true;
          file = true;
          noDeleteSafety = true;
        };
        anammox = {
          billing = true;
          dms = true;
          emojiList = true;
          enable = true;
          gift = true;
          serverBoost = true;
        };
        anonymiseFileNames = {
          anonymiseByDefault = false;
          consistent = "image";
          enable = true;
          method = 0;
          randomisedLength = 7;
          spoilerMessages = false;
        };
        badgeAPI = {
          enable = true;
        };
        betterAudioPlayer = {
          enable = true;
        };
        betterCommands = {
          allowNewlinesInCommands = true;
          autoFillArguments = true;
          enable = true;
        };
        betterGifAltText = {
          enable = true;
        };
        betterGifPicker = {
          enable = true;
        };
        betterUploadButton = {
          enable = true;
        };
        biggerStreamPreview = {
          enable = true;
        };
        blockKrisp = {
          enable = true;
        };
        characterCounter = {
          colorEffects = true;
          enable = true;
        };
        chatInputButtonAPI = {
          enable = true;
        };
        clearUrls = {
          enable = true;
        };
        commandsAPI = {
          enable = true;
        };
        contextMenuAPI = {
          enable = true;
        };
        copyFileContents = {
          enable = true;
        };
        crashHandler = {
          attemptToNavigateToHome = false;
          attemptToPreventCrashes = true;
          enable = true;
        };
        disableDeepLinks = {
          enable = true;
        };
        dontFilterMe = {
          enable = true;
        };
        equicordHelper = {
          disableCreateDMButton = false;
          disableDMContextMenu = false;
          enable = true;
          noMirroredCamera = false;
          removeActivitySection = false;
        };
        fakeNitro = {
          disableEmbedPermissionCheck = false;
          emojiSize = 48;
          enableEmojiBypass = true;
          enableStickerBypass = true;
          enableStreamQualityBypass = true;
          enable = true;
          hyperLinkText = "{{NAME}}";
          stickerSize = 160;
          transformCompoundSentence = false;
          transformEmojis = true;
          transformStickers = true;
          useEmojiHyperLinks = false;
          useStickerHyperLinks = false;
        };
        favoriteEmojiFirst = {
          enable = true;
        };
        favoriteGifSearch = {
          enable = true;
          searchOption = "hostandpath";
        };
        favoriteImage = {
          enable = true;
        };
        findReply = {
          enable = true;
          hideButtonIfNoReply = true;
          includeAuthor = false;
          includePings = false;
        };
        forceOwnerCrown = {
          enable = true;
        };
        fullSearchContext = {
          enable = true;
        };
        gifPaste = {
          enable = true;
        };
        homeTyping = {
          enable = true;
        };
        iLoveSpam = {
          enable = true;
        };
        imageFilename = {
          enable = true;
          showFullUrl = false;
        };
        imgToGif = {
          enable = true;
        };
        memberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };
        memberListDecoratorsAPI = {
          enable = true;
        };
        mentionAvatars = {
          enable = true;
          showAtSymbol = true;
        };
        messageAccessoriesAPI = {
          enable = true;
        };
        messageDecorationsAPI = {
          enable = true;
        };
        messageEventsAPI = {
          enable = true;
        };
        messageLogger = {
          collapseDeleted = false;
          deleteStyle = "text";
          enable = true;
          ignoreBots = false;
          ignoreChannels = "";
          ignoreGuilds = "";
          ignoreSelf = false;
          ignoreUsers = "";
          inlineEdits = true;
          logDeletes = true;
          logEdits = true;
          separatedDiffs = false;
          showEditDiffs = false;
        };
        messageLoggerEnhanced = {
          ShowLogsButton = true;
          ShowWhereMessageIsFrom = false;
          alwaysLogCurrentChannel = true;
          alwaysLogDirectMessages = true;
          attachmentFileExtensions = "png,jpg,jpeg,gif,webp,mp4,webm,mp3,ogg,wav";
          attachmentSizeLimitInMegabytes = 50;
          blacklistedIds = "";
          cacheLimit = 100000;
          cacheMessagesFromServers = false;
          enable = true;
          hideMessageFromMessageLoggers = false;
          hideMessageFromMessageLoggersDeletedMessage = "redacted eh";
          ignoreBots = false;
          ignoreMutedCategories = false;
          ignoreMutedChannels = false;
          ignoreMutedGuilds = false;
          ignoreSelf = true;
          ignoreWebhooks = false;
          imageCacheDir = "/home/price/.config/equibop/MessageLoggerData/savedImages";
          logsDir = "/home/price/.config/equibop/MessageLoggerData";
          messageLimit = -1;
          messagesToDisplayAtOnceInLogs = 1000;
          saveImages = true;
          saveMessages = true;
          sortNewest = true;
          whitelistedIds = "";
        };
        messageUpdaterAPI = {
          enable = true;
        };
        newGuildSettings = {
          enable = true;
          events = true;
          everyone = true;
          guild = true;
          highlights = true;
          messages = 3;
          mobilePush = true;
          role = true;
          showAllChannels = true;
          voiceChannels = false;
        };
        newPluginsManager = {
          enable = true;
        };
        nicknameIconsAPI = {
          enable = true;
        };
        noTrack = {
          disableAnalytics = true;
          enable = true;
        };
        noUnblockToJump = {
          enable = true;
        };
        onePingPerDm = {
          allowEveryone = true;
          allowMentions = true;
          alwaysPlaySound = false;
          channelToAffect = "both_dms";
          enable = true;
          ignoreUsers = "";
        };
        permissionsViewer = {
          enable = true;
          permissionsSortOrder = 0;
        };
        pinDMs = {
          canCollapseDmSection = false;
          enable = true;
          pinOrder = 0;
          userBasedCategoryList = {
            "970871319497424936" = [ ];
          };
        };
        platformIndicators = {
          ConsoleIcon = "equicord";
          colorMobileIndicator = true;
          enable = true;
          list = true;
          messages = true;
          profiles = true;
          showBots = false;
        };
        previewMessage = {
          enable = true;
        };
        readAllNotificationsButton = {
          enable = true;
        };
        replyTimestamp = {
          enable = true;
        };
        revealAllSpoilers = {
          enable = true;
        };
        reverseImageSearch = {
          enable = true;
        };
        roleColorEverywhere = {
          chatMentions = true;
          colorChatMessages = false;
          enable = true;
          memberList = true;
          messageSaturation = 30;
          pollResults = true;
          reactorsList = true;
          voiceUsers = true;
        };
        sendTimestamps = {
          enable = true;
          replaceMessageContents = true;
        };
        serverListAPI = {
          enable = true;
        };
        settings = {
          enable = true;
          settingsLocation = "aboveNitro";
        };
        showHiddenThings = {
          enable = true;
          showInvitesPaused = true;
          showModView = true;
          showTimeouts = true;
        };
        sidebarChat = {
          enable = true;
          patchCommunity = true;
          persistSidebar = true;
        };
        silentTyping = {
          chatContextMenu = true;
          chatIcon = true;
          chatIconLeftClickAction = "channel";
          chatIconMiddleClickAction = "settings";
          chatIconRightClickAction = "global";
          defaultHidden = true;
          disabledLocations = "";
          enable = true;
          enableGlobally = true;
          enableLocations = "";
          hideChatBoxTypingIndicators = false;
          hideMembersListTypingIndicators = false;
        };
        splitLargeMessages = {
          disableFileConversion = true;
          enable = true;
          hardSplit = false;
          maxLength = 0;
          sendDelay = 1;
          slowmodeMax = 5;
        };
        supportHelper = {
          enable = true;
        };
        teX = {
          enable = true;
        };
        timezones = {
          "24h Time" = false;
          "Show Own Timezone" = true;
          askedTimezone = true;
          databaseUrl = "https://timezone.creations.works";
          enable = true;
          preferDatabaseOverLocal = true;
          showMessageHeaderTime = true;
          showProfileTime = true;
          showTimezoneInfo = true;
          useDatabase = true;
        };
        typingIndicator = {
          enable = true;
          includeBlockedUsers = false;
          includeCurrentChannel = true;
          includeIgnoredUsers = true;
          includeMutedChannels = true;
          indicatorMode = 3;
        };
        typingTweaks = {
          alternativeFormatting = true;
          enable = true;
          showAvatars = true;
          showRoleColors = true;
        };
        unindent = {
          enable = true;
        };
        unreadCountBadge = {
          enable = true;
          notificationCountLimit = true;
          showOnMutedChannels = false;
        };
        userSettingsAPI = {
          enable = true;
        };
        userVoiceShow = {
          enable = true;
          showInMemberList = true;
          showInMessages = true;
          showInUserProfileModal = true;
        };
        vCSupport = {
          enable = true;
        };
        webContextMenus = {
          enable = true;
        };
        webKeybinds = {
          enable = true;
        };
        webScreenShareFixes = {
          enable = true;
        };
        whosWatching = {
          enable = true;
        };
      };
    };
  };
}
