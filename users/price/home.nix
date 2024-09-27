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
    config = {
      allowUnfree = true;
    };
  };
  home = {
    language.base = "en_US.UTF-8";
    packages =
      with pkgs;
      [
        lsof
        strace
        ltrace
        iotop
        iftop
        usbutils
        nmap
        zip
        killall
        nixd
        inkscape
        sqlx-cli
        postgresql
        htop
        devenv
        plantuml
        libnotify
        graphviz
        gcolor3
        typescript
        deno
        powershell
        vesktop
        kooha
        libreoffice-fresh
        nix-prefetch-scripts
        mako
        wl-clipboard
        grim
        slurp
        unzip
        Fmt
        screen-cap
        nodePackages.prettier
        cargo
        clippy
        rustc
        rustfmt
        python3
        shfmt
        bob-nvim
        neovide
        wezterm
        kitty
        sqlite
        swaylock-effects
        luajit
        luarocks
        imagemagick
        shellcheck
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
        man
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
        direnv
        swappy
        stylua
        typstyle
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
        chromium
        tree-sitter
        qt6Packages.qt6gtk2
        qt6Packages.qt6ct
        libsForQt5.qt5ct
        strawberry
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
        clang-tools
        clang
        nasm
        asm-lsp
        ninja
        ccache
        llvm
        llvmPackages.libcxxStdenv
        pkg-config
        openssl.dev
        curl.dev
      ]
      ++ [ rust-analyzer ];

    file = softLinkDots ".config";

    sessionVariables = {
      _ZL_DATA = "${config.xdg.cacheHome}/zlua";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      TERMINFO_DIRS = "${config.home.profileDirectory}/share/terminfo";
      WSLENV = "TERMINFO_DIRS";
      LD_LIBRARY_PATH = lib.strings.makeLibraryPath [
        "${config.home.profileDirectory}"
        "${pkgs.sqlite.out}"
      ];
      PKG_CONFIG_PATH = "${config.home.profileDirectory}/lib/pkgconfig";
      GTK_PATH = "${pkgs.gtk-engine-murrine}/lib/gtk-2.0";
      ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
      ANSIBLE_HOME = "${config.xdg.dataHome}/ansible";
      CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot='${config.xdg.configHome}/java'";
    };
    sessionPath = [ "${config.xdg.dataHome}/bin" ];
  };

  xdg = {
    enable = true;
    mime.enable = true;
    systemDirs.data = [ "${config.home.profileDirectory}/share/" ];
    cacheHome = "${config.home.homeDirectory}/.local/cache";
    mimeApps.enable = true;
    configFile = {
      "hypr/hyprland.conf".enable = false;
    };
  };

  programs = {
    nix-index.enable = true;
    wofi.enable = true;
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
    package = pkgs.adwaita-icon-theme;
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
      gtk3.extraConfig = extraGtkConfig;
      gtk4.extraConfig = extraGtkConfig;
    };

  services = {
    blueman-applet.enable = true;
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
