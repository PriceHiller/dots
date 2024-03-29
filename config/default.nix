{ pkgs, config, lib, ... }:
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
        Fmt
        nodePackages.prettier
        shfmt
        bob-nvim
        (nixGLWrap neovide)
        (nixGLWrap wezterm)
        fontconfig
        emacs
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
        gh
        ffmpeg
        silicon
        man
        jq
        tectonic
        fzf
        delta
        eza
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
        keyd
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
      TERMINFO_DIRS =
        "${config.home.homeDirectory}/.nix-profile/share/terminfo";
      WSLENV = "TERMINFO_DIRS";
      LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    };
    sessionPath = [ "${config.xdg.dataHome}/bin" ];
  };

  fonts.fontconfig.enable = true;

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
    configFile = {
      "fontconfig/fonts.conf".text = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <alias>
            <family>sans-serif</family>
            <prefer>
              <family>Noto Sans</family>
              <family>Fira Code</family>
            </prefer>
          </alias>
          <alias>
            <family>serif</family>
            <prefer>
              <family>Noto Serif</family>
              <family>Fira Code</family>
            </prefer>
          </alias>
          <alias>
            <family>monospace</family>
            <prefer>
              <family>Fira Code</family>
              <family>FiraCode Nerd Font</family>
              <family>Noto Sans Mono</family>
            </prefer>
          </alias>
          <alias>
            <family>emoji</family>
            <prefer>
              <family>Twemoji</family>
              <family>Noto Color Emoji</family>
            </prefer>
          </alias>
        </fontconfig>
      '';
      "bob/config.toml".text = ''
        installation_location = "${config.xdg.dataHome}/bin"
      '';
    };
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
        __HM_SESS_VARS_SOURCED= source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        source "$HOME/.config/zsh/zsh"
      '';
    };
    git = {
      enable = true;
      userName = "Price Hiller";
      userEmail = "price@orion-technologies.io";
      aliases = { unstage = "reset HEAD --"; };
      extraConfig = {
        init.defaultBranch = "Development";
        merge.conflictstyle = "zdiff3";
        branch.autosetupmerge = "always";
        remote.pushDefault = "origin";
        am.threeWay = true;
        apply.ignoreWhitespace = "change";
        # SEC: Integrate https://github.com/git-ecosystem/git-credential-manager with GPG to improve
        # security stance around the credential store
        credential.helper = "store";
        pull.rebase = true;
        commit.gpgsign = true;
        transfer.fsckObjects = true;
        receive.fsckObjects = true;
        status.submoduleSummary = true;
        submodule.recurse = true;
        fetch = {
          fsckObjects = true;
          prune = true;
          prunetags = true;
        };
        rebase = {
          autosquash = true;
          autostash = true;
          updateRefs = true;
        };
        log = {
          abbrevCommit = true;
          decorate = "short";
          date = "iso";
        };
        rerere = {
          enabled = true;
          autoUpdate = true;
        };
        core = {
          ignorecase = false;
          quotePath = false;
        };
        diff = {
          colorMoved = "default";
          submodule = "log";
          tool = "nvimdiff";
        };
        push = {
          autoSetupRemote = true;
          default = "current";
        };
      };
      signing = {
        signByDefault = true;
        key = "C3FADDE7A8534BEB";
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          features = "interactive decorations";
          interactive = { keep-plus-minus-markers = false; };
          decorations = {
            commit-decoration-style = "bold box ul";
            dark = true;
            file-style = "omit";
            hunk-header-decoration-style = ''"#022b45" box ul'';
            hunk-header-file-style = ''"#999999"'';
            hunk-header-style = "file line-number syntax";
            line-numbers = true;
            line-numbers-left-style = ''"#022b45"'';
            minus-emph-style = ''normal "#80002a"'';
            minus-style = ''normal "#330011"'';
            plus-emph-style = ''syntax "#003300"'';
            plus-style = ''syntax "#001a00"'';
            syntax-theme = "Solarized (dark)";
          };
        };
      };
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
    gromit-mpx = {
      enable = true;
      tools = [
        {
          device = "default";
          type = "pen";
          size = 5;
          color = "red";
        }
        {
          device = "default";
          type = "pen";
          size = 5;
          color = "blue";
          modifiers = [ "SHIFT" ];
        }
        {
          device = "default";
          type = "pen";
          size = 5;
          color = "yellow";
          modifiers = [ "CONTROL" ];
        }
        {
          device = "default";
          type = "pen";
          size = 6;
          color = "green";
          arrowSize = 1;
          modifiers = [ "2" ];
        }
        {
          device = "default";
          type = "eraser";
          size = 75;
          modifiers = [ "3" ];
        }
        {
          device = "default";
          color = "red";
          arrowSize = 5;
          modifiers = [ "CONTROL" "SHIFT" ];
        }
        {
          device = "default";
          color = "blue";
          arrowSize = 5;
          modifiers = [ "CONTROL" "SHIFT" "2" ];
        }
        {
          device = "default";
          color = "yellow";
          arrowSize = 5;
          modifiers = [ "CONTROL" "SHIFT" "3" ];
        }
      ];
    };
    cliphist.enable = true;
    easyeffects.enable = true;
    opensnitch-ui.enable = true;
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentryPackage = pkgs.pinentry-qt;
      maxCacheTtl = 14400;
      maxCacheTtlSsh = 14400;
      sshKeys = [ "530D3EC95C32AB9EC33714AAF865738D6E77680A" ];
      extraConfig = ''
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
      keyd-application-mapper = {
        Unit = {
          Description = "Keyd - Linux Keyboard Remapper";
          PartOf = [ "keyd.service" ];
        };
        Service = {
          ExecStart = "keyd-application-mapper";
          RestartSec = 3;
        };
        Install.WantedBy = [ "compositor.target" ];
      };
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
      gromit-mpx.Service.ExecStart =
        lib.mkForce "echo 'Disabled, managed by WM'";
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
