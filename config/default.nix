{ self, pkgs, config, inputs, lib, ... }:
let
  dotsDir = "${config.home.homeDirectory}/.config/home-manager/dots";
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
  nixGLWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';
in {
  programs.home-manager.enable = true;
  home = {
    packages = with pkgs;
      [
        bob-nvim
        (nixGLWrap neovide)
        (nixGLWrap wezterm)
        emacs-pgtk
        sqlite
        luajit
        imagemagick
        dotnet-sdk_8
        shellcheck
        openjdk
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
        opensnitch-ui
        twitter-color-emoji
        open-sans
        noto-fonts
        fira-code
        nerdfonts
        direnv
        swappy
        stylua
        typstfmt
        typst
        hurl
        easyeffects
        egl-wayland
        helvum
        brightnessctl
      ] ++ [ go (lib.hiPrio gotools) ] ++ [ age age-plugin-yubikey passage ]
      ++ [
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

    sessionVariables = {
      TERMINFO_DIRS = "${config.home.homeDirectory}/.nix-profile/share/terminfo";
      WSLENV = "TERMINFO_DIRS";
    };
    sessionPath = [
      "${config.xdg.dataHome}/bin"
    ];
  };

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/http" = [ "firefoxdeveloperedition.desktop" ];
        "x-scheme-handler/https" = [ "firefoxdeveloperedition.desktop" ];
        "x-scheme-handler/chrome" = [ "firefoxdeveloperedition.desktop" ];
        "text/html" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-htm" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-html" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-shtml" = [ "firefoxdeveloperedition.desktop" ];
        "application/xhtml+xml" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-xhtml" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-xht" = [ "firefoxdeveloperedition.desktop" ];

      };
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "x-scheme-handler/http" = [ "firefoxdeveloperedition.desktop" ];
        "x-scheme-handler/https" = [ "firefoxdeveloperedition.desktop" ];
        "x-scheme-handler/chrome" = [ "firefoxdeveloperedition.desktop" ];
        "text/html" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-htm" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-html" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-shtml" = [ "firefoxdeveloperedition.desktop" ];
        "application/xhtml+xml" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-xhtml" = [ "firefoxdeveloperedition.desktop" ];
        "application/x-extension-xht" = [ "firefoxdeveloperedition.desktop" ];

      };
    };
    systemDirs.data = [
      "${config.home.homeDirectory}/.nix-profile/share"
      "/usr/share"
      "/usr/local/share"
    ];
    configFile."bob/config.toml".text = ''
      installation_location = "${config.xdg.dataHome}/bin"
    '';
  };

  programs = {
    wofi.enable = true;
    gpg = {
      enable = true;
      scdaemonSettings = {
        pcsc-driver = "/usr/lib/libpcsclite.so";
        disable-ccid = true;
      };
    };
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
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
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      maxCacheTtl = 14400;
      maxCacheTtlSsh = 14400;
      sshKeys = [ "530D3EC95C32AB9EC33714AAF865738D6E77680A" ];
      extraConfig = ''
        pinentry-program /usr/bin/pinentry-gtk-2
        allow-loopback-pinentry
      '';
    };
  };

  systemd.user = {
    targets.compositor = {
      Unit = {
        Description = "Unit for DE to launch";
        ConditionEnvironment = [ "WAYLAND_DISPLAY" "DISPLAY" ];
      };
    };
    services = {
      waybar = {
        Service = {
          Environment = [ "GTK_THEME='THIS THEME DOES NOT EXIST!'" ];
          RestartSec = 3;
        };
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
      opensnitch-ui = {
        Service.RestartSec = 3;
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
        Service.RestartSec = 3;
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
    };
  };
}
