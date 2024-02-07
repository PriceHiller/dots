{ pkgs, config, inputs, lib, ... }:
let
  dotsDir = "${config.home.homeDirectory}/.dot_files/dots";
  softLinkDots = dir:
    (builtins.listToAttrs (map (n: {
      name = "${dir + "/" + n}";
      value = {
        source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${dir}/${n}";
        force = true;
      };
    })
    # HACK: We don't use the absolute path in readDir to respect pure evaluation in nix flakes.
      (builtins.attrNames (builtins.readDir ../dots/${dir}))));
  gtkStyle = "gtk2";
in {
  programs.home-manager.enable = true;
  home = {
    packages = with pkgs;
      [
        bob-nvim
        emacs-pgtk
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
        ruby
        yamllint
        curl
        openssh
        openssl
        wget
        rsync
        readline
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
        stylua
        typstfmt
        typst
        hurl
        easyeffects
        egl-wayland
      ] ++ [
        libsForQt5.qtstyleplugins
        libsForQt5.qtcurve
        qt6Packages.qt6gtk2
        gtk-engine-murrine
        gnome.gnome-themes-extra
        gtk_engines
      ] ++ [ ansible ansible-lint ] ++ [
        # gnumake
        # cmake
        # gcc
        # glibc
        # openssl.dev
        # glibc.static
        # llvm
        # llvmPackages.libcxxStdenv
      ];

    file = {
      ".local/share/wallpapers" = {
        source = ../dots/.local/share/wallpapers;
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
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    systemDirs.data = [
      "${config.home.homeDirectory}/.nix-profile/share"
      "/usr/share"
      "/usr/local/share"
    ];
  };

  programs = {
    waybar = {
      enable = true;
      systemd.enable = true;

    };
    zsh = {
      enable = true;
      initExtra = ''
        source "$HOME/.config/zsh/zsh"
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

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  gtk = let
    extraGtkConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-cursor-theme-size = 0;
      gtk-enable-event-sounds = 1;
      gtk-enable-input-feedback-sounds = 1;
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
    };
  in {
    enable = true;
    theme = {
      name = "Kanagawa-BL";
      package = pkgs.kanagawa-gtk-theme;
    };
    iconTheme = {
      name = "Kanagawa";
      package = pkgs.kanagawa-gtk-icon-theme;
    };
    font = {
      name = "Open Sans";
      size = 11;
      package = pkgs.open-sans;
    };
    gtk3.extraConfig = extraGtkConfig;
    gtk4.extraConfig = extraGtkConfig;
  };

  services = {
    cliphist.enable = true;
    easyeffects.enable = true;
    opensnitch-ui.enable = true;
  };

  systemd.user = {
    targets.compositor = {
      Unit = {
        Description = "Unit for DE to launch";
        ConditionEnvironment =
          [ "WAYLAND_DISPLAY" "DISPLAY" ];
      };
    };
    services = {
      waybar = {
        Service.Environment = [
          "GTK_THEME='THIS THEME DOES NOT EXIST!'"
        ];
        Service.ExecStartPre = "env";
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
      opensnitch-ui = {
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" "waybar.service" ];
        };
      };
      easyeffects = {
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
      cliphist = {
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
    };
  };
}
