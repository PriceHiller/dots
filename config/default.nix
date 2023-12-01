{ pkgs, config, ... }:
let
  dotsDir = "${config.home.homeDirectory}/.dot_files/dots";
  softLinkDots = dir:
    (builtins.listToAttrs (map
      (n: {
        name = "${dir + "/" + n}";
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${dir}/${n}";
          force = true;
        };
      })
      # HACK: We don't use the absolute path in readDir to respect pure evaluation in nix flakes.
      (builtins.attrNames (builtins.readDir ../dots/${dir}))));
    gtkStyle = "gtk2";
in
{
  programs.home-manager.enable = true;
  home = {
    packages = with pkgs; [
      gcc
      sqlite
      luajit
      imagemagick
      dotnet-sdk_8
      cargo
      rustc
      shellcheck
      openjdk
      go
      nodejs
      poetry
      python3
      ruby
      yamllint
      curl
      llvm
      openssh
      openssl
      pkg-config
      wget
      rsync
      readline
      gnumake
      cmake
      git
      gh
      ffmpeg
      silicon
      man
      jq
      tectonic
      fzf
      eza
      luajit
      ripgrep
      fd
      nixfmt
      qt6Packages.qt6gtk2
      qt6Packages.qt6ct
      libsForQt5.qtstyleplugins
      libsForQt5.qt5ct
      lxappearance
      webcord
      blueman
      gtk-engine-murrine
      opensnitch-ui
    ];

    file =
      {
        ".local/" = {
          source = ../dots/.local;
          recursive = true;
          force = true;
        };
        ".omnisharp" = {
          source = ../dots/.omnisharp;
          force = true;
        };
        ".zshrc" = {
          source = ../dots/.zshrc;
          force = true;
        };
        ".latexmkrc" = {
          source = ../dots/.latexmkrc;
          force = true;
        };
      } // softLinkDots ".config";

    sessionVariables = {
      GTK_THEME = "Kanagawa-Borderless";
      QT_QPA_PLATFORMTHEME = "${gtkStyle}";
    };
  };

  programs = {
    zsh = {
      enable = true;
      initExtra = ''
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      '';
      profileExtra = ''
        export GTK_PATH="$HOME/.nix-profile/lib/gtk-2.0"
      '';
    };
    neovim = {
      enable = true;
      extraPackages = with pkgs; [ sqlite gh ];
      # Magick is required for image.nvim
      extraLuaPackages = lp: [ lp.magick ];
    };
  };

  gtk =
    let
      extraGtkConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-cursor-theme-size = 0;
        gtk-enable-event-sounds = 1;
        gtk-enable-input-feedback-sounds = 1;
        gtk-xft-antialias = 1;
        gtk-xft-hinting = 1;
        gtk-xft-hintstyle = "hintfull";
      };
    in
    {
      enable = true;
      theme = {
        name = "Kanagawa-Borderless";
        package = pkgs.kanagawa-gtk-theme;
      };
      iconTheme = {
        name = "Kanagawa";
        package = pkgs.kanagawa-gtk-theme;
      };
      font = {
        name = "Open Sans";
        size = 11;
        package = pkgs.open-sans;
      };
      gtk3.extraConfig = extraGtkConfig;
      gtk4.extraConfig = extraGtkConfig;
    };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  services.blueman-applet.enable = true;
  systemd.user.services.opensnitch-ui = {
    Unit = {
      Description = "Opensnitch ui";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    environment = {
      QT_QPA_PLATFORMTHEME = "${gtkStyle}";
      PATH = "${config.home.profileDirectory}/bin";
    };
    Service = {
      ExecStart = "${pkgs.opensnitch-ui}/bin/opensnitch-ui";
    };

    Install = { WantedBy = [ "graphical-session.target" ]; };
  };
}
