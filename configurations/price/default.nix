{ config, pkgs, ... }:


let
  dots = config.home.homeDirectory + "/.config/home-manager/configurations/price/dots";
  xdg_config = "${dots}/xdg/config";
  xdg_local = "${dots}/xdg/config";
  dotf = configPath:
    let
      dot_file = "${configPath}";
    in
    {
      source = config.lib.file.mkOutOfStoreSymlink dot_file;
      recursive = builtins.pathExists ("${dot_file}" + "/.");
    };
in
{

  nixpkgs.config.allowUnfree = true;
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sam";
  home.homeDirectory = "/home/sam";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    hyprland
    waybar
    neovim-nightly
    nixd
    wezterm
    git
    udiskie
    openssh
    eza
    mullvad-vpn
    firefox-devedition
    swww
    twitter-color-emoji
    swaylock-effects
    zathura
    mako
    jq
    inotify-tools
    wf-recorder
    ffmpeg
    ungoogled-chromium
    man
    man-pages
    man-pages-posix
    pavucontrol
    playerctl
    slurp
    grim
    feh
    wireshark
    thunderbird
    wl-clipboard
    gh
    libfido2
    python3
    lua
    silicon
    mpv
    yarn
    bat
    ripgrep
    delta
    sqlite
    glibc
    gifski
    tlp
    thermald
    lxappearance
    ccache
    qt6ct
    qt5ct
    gtk-engine-murrine
    fuse
    imagemagick
    tectonic
    virt-manager
    python-qt
    ansible
    ansible-lint
    xwaylandvideobridge
    spotify
    feh

    # Fonts
    liberation_ttf
    fira-code-nerdfont
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    meslo-lgs-nf
    roboto
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  services = {
    opensnitch-ui.enable = true;
  };

  xdg.configFile = {
    "nvim" = dotf "${xdg_config}/nvim";
    "chrome-flags.conf" = dotf "${xdg_config}/chrome-flags.conf";
    "chromium-flags.conf" = dotf "${xdg_config}/chromium-flags.conf";
    "mimeapps.list" = dotf "${xdg_config}/mimeapps.list";
    "stylua.toml" = dotf "${xdg_config}/stylua.toml";
    "Trolltech.conf" = dotf "${xdg_config}/Trolltech.conf";
    "zathura" = dotf "${xdg_config}/zathura";
    "bat" = dotf "${xdg_config}/bat";
    "zsh" = dotf "${xdg_config}/zsh";
    "hypr" = dotf "${xdg_config}/hypr";
    "mako" = dotf "${xdg_config}/mako";
    "mpv" = dotf "${xdg_config}/mpv";
    "waybar" = dotf "${xdg_config}/waybar";
    "silicon" = dotf "${xdg_config}/silicon";
    "powershell" = dotf "${xdg_config}/powershell";
    "wezterm" = dotf "${xdg_config}/wezterm";
    "wofi" = dotf "${xdg_config}/wofi";
    "kitty" = dotf "${xdg_config}/kitty";
    "git" = dotf "${xdg_config}/git";
    "gtk-3.0" = dotf "${xdg_config}/gtk-3.0";
    "gtk-4.0" = dotf "${xdg_config}/gtk-4.0";
    "fontconfig" = dotf "${xdg_config}/fontconfig";
    "emacs" = dotf "${xdg_config}/emacs";
  };

  home.file = {
    ".omnisharp" = dotf "${dots}/.omnisharp";
    ".latexmkrc" = dotf "${dots}/.latexmkrc";
    ".zshrc" = dotf "${dots}/.zshrc";
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc" = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sam/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "nvim";
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
