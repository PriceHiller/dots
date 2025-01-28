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
          enabled = true;
        };
        AlwaysTrust = {
          domain = true;
          enabled = true;
          file = true;
        };
        AnonymiseFileNames = {
          anonymiseByDefault = false;
          consistent = "image";
          enabled = true;
          method = 0;
          randomisedLength = 7;
        };
        BetterGifAltText = {
          enabled = true;
        };
        BetterGifPicker = {
          enabled = true;
        };
        BetterUploadButton = {
          enabled = true;
        };
        CallTimer = {
          enabled = true;
          format = "stopwatch";
        };
        ChatInputButtonAPI = {
          enabled = true;
        };
        ClearURLs = {
          enabled = true;
        };
        CommandsAPI = {
          enabled = true;
        };
        ForceOwnerCrown = {
          enabled = true;
        };
        GifPaste = {
          enabled = true;
        };
        ImageZoom = {
          enabled = true;
          invertScroll = true;
          nearestNeighbour = false;
          saveZoomValues = true;
          size = 100;
          square = false;
          zoom = 1;
          zoomSpeed = 0.5;
        };
        MemberCount = {
          enabled = true;
          memberList = true;
          toolTip = true;
        };
        MemberListDecoratorsAPI = {
          enabled = true;
        };
        MentionAvatars = {
          enabled = true;
          showAtSymbol = true;
        };
        MessageAccessoriesAPI = {
          enabled = true;
        };
        MessageClickActions = {
          enableDeleteOnClick = true;
          enableDoubleClickToEdit = false;
          enableDoubleClickToReply = false;
          enabled = true;
          requireModifier = false;
        };
        MessageDecorationsAPI = {
          enabled = true;
        };
        MessageEventsAPI = {
          enabled = true;
        };
        MessageLogger = {
          collapseDeleted = false;
          deleteStyle = "overlay";
          enabled = true;
          ignoreBots = true;
          ignoreChannels = "";
          ignoreGuilds = "";
          ignoreSelf = true;
          ignoreUsers = "";
          logDeletes = true;
          logEdits = true;
        };
        MessageUpdaterAPI = {
          enabled = true;
        };
        NewGuildSettings = {
          enabled = true;
        };
        NoProfileThemes = {
          enabled = true;
        };
        NoScreensharePreview = {
          enabled = true;
        };
        NormalizeMessageLinks = {
          enabled = true;
        };
        PlatformIndicators = {
          badges = true;
          colorMobileIndicator = true;
          enabled = true;
          list = true;
          messages = true;
        };
        PreviewMessage = {
          enabled = true;
        };
        ReadAllNotificationsButton = {
          enabled = true;
        };
        ReplyTimestamp = {
          enabled = true;
        };
        RevealAllSpoilers = {
          enabled = true;
        };
        SendTimestamps = {
          enabled = true;
          replaceMessageContents = true;
        };
        ServerListAPI = {
          enabled = true;
        };
        ShikiCodeblocks = {
          bgOpacity = 59.9132;
          customTheme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/refs/heads/main/packages/tm-themes/themes/catppuccin-mocha.json";
          enabled = true;
          theme = "https://raw.githubusercontent.com/shikijs/shiki/0b28ad8ccfbf2615f2d9d38ea8255416b8ac3043/packages/shiki/themes/vitesse-dark.json";
          tryHljs = "ALWAYS";
          useDevIcon = "COLOR";
        };
        ShowHiddenThings = {
          disableDisallowedDiscoveryFilters = true;
          disableDiscoveryFilters = true;
          enabled = true;
          showInvitesPaused = true;
          showModView = true;
          showTimeouts = true;
        };
        SilentTyping = {
          contextMenu = true;
          enabled = true;
          isEnabled = true;
          showIcon = false;
        };
        TypingIndicator = {
          enabled = true;
          includeBlockedUsers = true;
          includeCurrentChannel = true;
          includeMutedChannels = true;
          indicatorMode = 3;
        };
        TypingTweaks = {
          alternativeFormatting = true;
          enabled = true;
          showAvatars = true;
          showRoleColors = true;
        };
        Unindent = {
          enabled = true;
        };
        UserSettingsAPI = {
          enabled = true;
        };
        UserVoiceShow = {
          enabled = true;
          showInMemberList = true;
          showInMessages = true;
          showInUserProfileModal = true;
        };
        WebScreenShareFixes = {
          enabled = true;
        };
      };
    };
  };
}
