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
      gtk2
      lxappearance
      webcord
      gtk-engine-murrine
      opensnitch-ui
      twitter-color-emoji
      open-sans
      noto-fonts
      fira-code
      nerdfonts
      direnv
      passage
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

  systemd.user = {
    targets.compositor = {
      Unit = {
        Description = "Compositor target for WM";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
    };
    services = {
      opensnitch-ui = {
        Unit = {
          Description = "Opensnitch ui";
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
          ConditionEnvironment = [ "WAYLAND_DISPLAY" "HOME" "XDG_RUNTIME_DIR" ];
        };

        Service = {
          ExecStart = "${pkgs.opensnitch-ui}/bin/opensnitch-ui";
        };

        environment = {
          QT_QPA_PLATFORMTHEME = "${gtkStyle}";
          PATH = "${config.home.profileDirectory}/bin";
        };

        Install = { WantedBy = [ "compositor.target" ]; };
      };
    };
  };
}
