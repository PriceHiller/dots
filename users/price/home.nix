{
  pkgs,
  config,
  lib,
  clib,
  ...
}:
let
  dotsDir = "${config.home.homeDirectory}/.config/home-manager/users/price/dots";
  softLinkDots =
    dir:
    (builtins.listToAttrs (
      map (n: {
        name = "${dir + "/" + n}";
        value = {
          source = config.lib.file.mkOutOfStoreSymlink "${dotsDir}/${dir}/${n}";
          force = true;
        };
      }) (builtins.attrNames (builtins.readDir ./dots/${dir}))
    ));
in
{
  imports = (clib.recurseFilesInDirs [ ./conf ] ".nix");
  programs.home-manager.enable = true;
  nixpkgs = {
    config.allowUnfree = true;
  };
  home = {
    language.base = "en_US.UTF-8";
    packages =
      with pkgs;
      [
        typescript
        deno
        powershell
        vesktop
        vimiv-qt
        kooha
        libreoffice-fresh
        zathura
        pulseaudio
        nix-prefetch-scripts
        mako
        wl-clipboard
        grim
        slurp
        unzip
        Fmt
        starship
        nodePackages.prettier
        cargo
        rustc
        rustfmt
        python3
        shfmt
        bob-nvim
        neovide
        wezterm
        fontconfig
        sqlite
        swaylock-effects
        luajit
        imagemagick
        shellcheck
        openjdk
        nodejs
        poetry
        ruby
        yamllint
        curl
        openssh
        gradle
        maven
        pavucontrol
        openssl
        wget
        rsync
        readline
        gh
        ffmpeg
        silicon
        man
        thunderbird
        jq
        tectonic
        fzf
        delta
        eza
        ripgrep
        fd
        playerctl
        nixfmt-rfc-style
        lxappearance
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
        mullvad-vpn
        easyeffects
        egl-wayland
        helvum
        brightnessctl
        keyd
        tidal-hifi
        nix-output-monitor
        sops
        ungoogled-chromium
        tree-sitter
        qt6Packages.qt6gtk2
        qt6Packages.qt6ct
        libsForQt5.qt5ct
      ]
      ++ [
        age
        age-plugin-yubikey
        passage
      ]
      ++ [
        ansible
        ansible-lint
      ]
      ++ [
        gnumake
        cmake
        gcc
        glibc
        glibc.static
        llvm
        llvmPackages.libcxxStdenv
        pkg-config
        openssl.dev
        curl.dev
      ]
      ++ [ rust-analyzer ];

    file = {
      ".local/share/wallpapers" = {
        source = ./dots/.local/share/wallpapers;
        force = true;
      };
    } // softLinkDots ".config";

    sessionVariables = {
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      TERMINFO_DIRS = "${config.home.homeDirectory}/.nix-profile/share/terminfo";
      WSLENV = "TERMINFO_DIRS";
      LD_LIBRARY_PATH = lib.strings.makeLibraryPath [
        "${config.home.homeDirectory}/.nix-profile/"
        "${pkgs.sqlite.out}"
      ];
      PKG_CONFIG_PATH = "${config.home.homeDirectory}/.nix-profile/lib/pkgconfig";
      GTK_PATH = "${pkgs.gtk-engine-murrine}/lib/gtk-2.0";
    };
    sessionPath = [ "${config.xdg.dataHome}/bin" ];
  };

  fonts.fontconfig.enable = true;

  xdg = {
    enable = true;
    mime.enable = true;
    systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/" ];
    mimeApps = {
      enable = true;
      associations.added = {
        "x-scheme-handler/http" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/https" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox-devedition.desktop" ];
        "text/html" = [ "firefox-devedition.desktop" ];
        "application/x-extension-htm" = [ "firefox-devedition.desktop" ];
        "application/x-extension-html" = [ "firefox-devedition.desktop" ];
        "application/x-extension-shtml" = [ "firefox-devedition.desktop" ];
        "application/xhtml+xml" = [ "firefox-devedition.desktop" ];
        "application/x-extension-xhtml" = [ "firefox-devedition.desktop" ];
        "application/x-extension-xht" = [ "firefox-devedition.desktop" ];
      };
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        "x-scheme-handler/http" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/https" = [ "firefox-devedition.desktop" ];
        "x-scheme-handler/chrome" = [ "firefox-devedition.desktop" ];
        "text/html" = [ "firefox-devedition.desktop" ];
        "application/x-extension-htm" = [ "firefox-devedition.desktop" ];
        "application/x-extension-html" = [ "firefox-devedition.desktop" ];
        "application/x-extension-shtml" = [ "firefox-devedition.desktop" ];
        "application/xhtml+xml" = [ "firefox-devedition.desktop" ];
        "application/x-extension-xhtml" = [ "firefox-devedition.desktop" ];
        "application/x-extension-xht" = [ "firefox-devedition.desktop" ];
      };
    };
    configFile = {
      "hypr/hyprland.conf".enable = false;
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
    };
  };

  programs = {
    eclipse = {
      enable = true;
      package = pkgs.eclipses.eclipse-java;
    };
    man = {
      enable = true;
      generateCaches = true;
    };
    emacs = {
      enable = true;
      extraPackages = (
        epkgs:
        (with epkgs; [
          treesit-grammars.with-all-grammars
          melpaPackages.pdf-tools
        ])
      );
    };
    wofi.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-devedition;
    };
    waybar = {
      enable = true;
      systemd.enable = true;
    };
    git = {
      enable = true;
      userName = "Price Hiller";
      userEmail = "price@orion-technologies.io";
      aliases = {
        unstage = "reset HEAD --";
      };
      extraConfig = {
        init.defaultBranch = "main";
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
        key = null;
      };
      delta = {
        enable = true;
        options = {
          navigate = true;
          features = "interactive decorations";
          interactive = {
            keep-plus-minus-markers = false;
          };
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
    style = {
      name = "gtk2";
      package = pkgs.libsForQt5.breeze-qt5;
    };
    platformTheme.name = "gtk";
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.gnome.adwaita-icon-theme;
    size = 24;
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
        name = "Kanagawa-BL";
        package = pkgs.kanagawa-gtk-theme;
      };
      iconTheme = {
        name = "Kanagawa";
        package = pkgs.kanagawa-icon-theme;
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
    # blueman-applet.enable = true;
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
          modifiers = [
            "CONTROL"
            "SHIFT"
          ];
        }
        {
          device = "default";
          color = "blue";
          arrowSize = 5;
          modifiers = [
            "CONTROL"
            "SHIFT"
            "2"
          ];
        }
        {
          device = "default";
          color = "yellow";
          arrowSize = 5;
          modifiers = [
            "CONTROL"
            "SHIFT"
            "3"
          ];
        }
      ];
    };
    cliphist.enable = true;
    easyeffects.enable = true;
  };

  systemd.user = {
    startServices = "sd-switch";
    targets.compositor = {
      Unit = {
        Description = "Unit for DE to launch";
        ConditionEnvironment = [
          "WAYLAND_DISPLAY"
          "DISPLAY"
        ];
      };
    };
    services = {
      swww-daemon = {
        Service =
          let
            cleanup-socket-script = pkgs.writeShellScript "swww-daemon-cleanup-socket" ''
              # Remove the existing swww.socket if it exists, avoids some issues with swww-daemon
              # startup where swww-daemon claims the address is already in use
              if [[ -w "$XDG_RUNTIME_DIR/swww.socket" ]]; then
                rm -f $XDG_RUNTIME_DIR/swww.socket || exit 1
              fi
            '';
          in
          {
            RestartSec = 3;
            PassEnvironment = [ "XDG_RUNTIME_DIR" ];
            ExecStartPre = "${cleanup-socket-script}";
            ExecStopPost = "${cleanup-socket-script}";
            ExecStart = "${pkgs.swww}/bin/swww-daemon";
          };
        Install.WantedBy = [ "compositor.target" ];
        Unit = {
          Description = "Wayland Wallpaper Service";
          PartOf = [ "compositor.target" ];
          After = [ "compositor.target" ];
        };
      };
      swww-wallpapers = {
        Service = {
          RestartSec = 3;
          Type = "oneshot";
          Environment = [
            "SWWW_TRANSITION_FPS=120"
            "SWWW_TRANSITION_STEP=30"
            "SWWW_TRANSITION_DURATION=0.75"
          ];
          ExecStart =
            let
              wallpaper-dir = "${dotsDir}/.local/share/wallpapers";
            in
            [
              "${pkgs.swww}/bin/swww img -t random ${wallpaper-dir}/Nebula.jpg"
              "${pkgs.swww}/bin/swww img -t wipe --transition-angle 40 -o eDP-1 ${wallpaper-dir}/Autumn-Leaves.jpg"
            ];
        };
        Install.WantedBy = [ "swww-daemon.service" ];
        Unit = {
          Description = "Wayland Wallpaper Service";
          PartOf = [ "swww-daemon.service" ];
          After = [ "swww-daemon.service" ];
        };
      };
      keyd-application-mapper = {
        Unit = {
          Description = "Keyd - Linux Keyboard Remapper";
          PartOf = [ "keyd.service" ];
        };
        Service = {
          ExecStart = "${pkgs.keyd}/bin/keyd-application-mapper";
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
      gromit-mpx.Service.ExecStart = lib.mkForce "echo 'Disabled, managed by WM'";
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
      polkit-gnome-authentication-agent-1 = {
        Unit = {
          Description = "Gnome Polkit authentication agent";
          Documentation = "https://gitlab.freedesktop.org/polkit/polkit/";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "always";
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
