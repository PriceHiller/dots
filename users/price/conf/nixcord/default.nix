{ ... }:
{
  programs.nixcord = {
    enable = true;
    config = {
      themeLinks = [
        "https://catppuccin.github.io/discord/dist/catppuccin-macchiato.theme.css"
      ];
      plugins = {
        alwaysAnimate = {
          enable = true;
        };
        alwaysTrust = {
          domain = true;
          enable = true;
          file = true;
        };
        anonymiseFileNames = {
          enable = true;
          anonymiseByDefault = false;
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
        callTimer = {
          enable = true;
          format = "stopwatch";
        };
        chatInputButtonAPI = {
          enable = true;
        };
        clearURLs = {
          enable = true;
        };
        commandsAPI = {
          enable = true;
        };
        forceOwnerCrown = {
          enable = true;
        };
        gifPaste = {
          enable = true;
        };
        imageZoom = {
          enable = true;
          invertScroll = true;
          nearestNeighbour = false;
          saveZoomValues = true;
          square = false;
          zoom = 1.0;
        };
        memberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
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
        messageClickActions = {
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = false;
          enableDoubleClickToReply = false;
          enable = true;
          requireModifier = false;
        };
        messageDecorationsAPI = {
          enable = true;
        };
        messageEventsAPI = {
          enable = true;
        };
        messageLogger = {
          collapseDeleted = false;
          deleteStyle = "overlay";
          enable = true;
          ignoreBots = true;
          ignoreChannels = "";
          ignoreGuilds = "";
          ignoreSelf = true;
          ignoreUsers = "";
          logDeletes = true;
          logEdits = true;
        };
        messageUpdaterAPI = {
          enable = true;
        };
        newGuildSettings = {
          enable = true;
        };
        noProfileThemes = {
          enable = true;
        };
        normalizeMessageLinks = {
          enable = true;
        };
        platformIndicators = {
          badges = true;
          colorMobileIndicator = true;
          enable = true;
          lists = true;
          messages = true;
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
        sendTimestamps = {
          enable = true;
          replaceMessageContents = true;
        };
        serverListAPI = {
          enable = true;
        };
        shikiCodeblocks = {
          enable = true;
          bgOpacity = 59.9132;
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-mocha.json";
          tryHljs = "ALWAYS";
          useDevIcon = "COLOR";
        };
        showHiddenThings = {
          disableDisallowedDiscoveryFilters = true;
          disableDiscoveryFilters = true;
          enable = true;
          showInvitesPaused = true;
          showModView = true;
          showTimeouts = true;
        };
        silentTyping = {
          contextMenu = true;
          enable = true;
          isEnabled = true;
          showIcon = false;
        };
        typingIndicator = {
          enable = true;
          includeBlockedUsers = true;
          includeCurrentChannel = true;
          includeMutedChannels = true;
          indicatorMode = "animatedDots";
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
        userSettingsAPI = {
          enable = true;
        };
        userVoiceShow = {
          enable = true;
          showInMemberList = true;
          showInMessages = true;
          showInUserProfileModal = true;
        };
        fakeNitro = {
          enable = true;
        };
        webScreenShareFixes = {
          enable = true;
        };
      };
    };
  };
}
