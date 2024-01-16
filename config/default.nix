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
      bob-nvim
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
      delta
      eza
      nixd
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
      swappy
    ] ++ [
      # gcc
      # glibc
      # libgccjit
      # openssl.dev
      # glibc.static
      # llvm
      # llvmPackages.libcxxStdenv
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
        ".latexmkrc" = {
          source = ../dots/.latexmkrc;
          force = true;
        };
      } // softLinkDots ".config";

    sessionVariables = {
      GTK_THEME = "Kanagawa-Borderless";
      QT_QPA_PLATFORMTHEME = "${gtkStyle}";
      # LD_LIBRARY_PATH = "${config.home.homeDirectory}/.nix-profile/lib";
      # PKG_CONFIG_PATH = "${config.home.homeDirectory}/.nix-profile/lib/pkgconfig";
    };
  };

  xdg = {
    enable = true;
    mime.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      initExtra = ''
        source "$HOME/.config/zsh/zsh"
        export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
        __HM_SESS_VARS_SOURCED= source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
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
          ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
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
