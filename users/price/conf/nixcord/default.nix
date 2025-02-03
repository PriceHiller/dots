{ ... }:
{
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    discord.vencord.unstable = true;
    vesktopConfig = {
      themeLinks = [
        "https://catppuccin.github.io/discord/dist/catppuccin-macchiato.theme.css"
      ];
      plugins = {
        AlwaysAnimate = {
          enable = true;
        };
        AlwaysTrust = {
          domain = true;
          enable = true;
          file = true;
        };
        AnonymiseFileNames = {
          anonymiseByDefault = false;
          consistent = "image";
          enable = true;
          method = 0;
          randomisedLength = 7;
        };
        BetterGifAltText = {
          enable = true;
        };
        BetterGifPicker = {
          enable = true;
        };
        BetterUploadButton = {
          enable = true;
        };
        CallTimer = {
          enable = true;
          format = "stopwatch";
        };
        ChatInputButtonAPI = {
          enable = true;
        };
        ClearURLs = {
          enable = true;
        };
        CommandsAPI = {
          enable = true;
        };
        ForceOwnerCrown = {
          enable = true;
        };
        GifPaste = {
          enable = true;
        };
        ImageZoom = {
          enable = true;
          invertScroll = true;
          nearestNeighbour = false;
          saveZoomValues = true;
          size = 100;
          square = false;
          zoom = 1;
          zoomSpeed = 0.5;
        };
        MemberCount = {
          enable = true;
          memberList = true;
          toolTip = true;
        };
        MemberListDecoratorsAPI = {
          enable = true;
        };
        MentionAvatars = {
          enable = true;
          showAtSymbol = true;
        };
        MessageAccessoriesAPI = {
          enable = true;
        };
        MessageClickActions = {
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = false;
          enableDoubleClickToReply = false;
          enable = true;
          requireModifier = false;
        };
        MessageDecorationsAPI = {
          enable = true;
        };
        MessageEventsAPI = {
          enable = true;
        };
        MessageLogger = {
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
        MessageUpdaterAPI = {
          enable = true;
        };
        NewGuildSettings = {
          enable = true;
        };
        NoProfileThemes = {
          enable = true;
        };
        NoScreensharePreview = {
          enable = true;
        };
        NormalizeMessageLinks = {
          enable = true;
        };
        PlatformIndicators = {
          badges = true;
          colorMobileIndicator = true;
          enable = true;
          list = true;
          messages = true;
        };
        PreviewMessage = {
          enable = true;
        };
        ReadAllNotificationsButton = {
          enable = true;
        };
        ReplyTimestamp = {
          enable = true;
        };
        RevealAllSpoilers = {
          enable = true;
        };
        SendTimestamps = {
          enable = true;
          replaceMessageContents = true;
        };
        ServerListAPI = {
          enable = true;
        };
        ShikiCodeblocks = {
          bgOpacity = 59.9132;
          customTheme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-mocha.json";
          enable = true;
          theme = "https://raw.githubusercontent.com/shikijs/shiki/0b28ad8ccfbf2615f2d9d38ea8255416b8ac3043/packages/shiki/themes/vitesse-dark.json";
          tryHljs = "ALWAYS";
          useDevIcon = "COLOR";
        };
        ShowHiddenThings = {
          disableDisallowedDiscoveryFilters = true;
          disableDiscoveryFilters = true;
          enable = true;
          showInvitesPaused = true;
          showModView = true;
          showTimeouts = true;
        };
        SilentTyping = {
          contextMenu = true;
          enable = true;
          isEnabled = true;
          showIcon = false;
        };
        TypingIndicator = {
          enable = true;
          includeBlockedUsers = true;
          includeCurrentChannel = true;
          includeMutedChannels = true;
          indicatorMode = 3;
        };
        TypingTweaks = {
          alternativeFormatting = true;
          enable = true;
          showAvatars = true;
          showRoleColors = true;
        };
        Unindent = {
          enable = true;
        };
        UserSettingsAPI = {
          enable = true;
        };
        UserVoiceShow = {
          enable = true;
          showInMemberList = true;
          showInMessages = true;
          showInUserProfileModal = true;
        };
        WebScreenShareFixes = {
          enable = true;
        };
        FakeNitro = {
          enable = true;
        };
      };
    };
  };
}
