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
    stateVersion = "24.11";
    language.base = "en_US.UTF-8";
    packages =
      with pkgs;
      [
        dig
        nethogs
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
        python3
        shfmt
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
        spotify
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
        asmfmt
        ninja
        ccache
        llvm
        pkg-config
      ];

    file = softLinkDots ".config";

    sessionVariables = {
      _ZL_DATA = "${config.xdg.cacheHome}/zlua";
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
      NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
      PKG_CONFIG_PATH = "${config.home.profileDirectory}/lib/pkgconfig";
      GTK_PATH = "${pkgs.gtk-engine-murrine}/lib/gtk-2.0";
      ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
      ANSIBLE_HOME = "${config.xdg.dataHome}/ansible";
      CUDA_CACHE_PATH = "${config.xdg.cacheHome}/nv";
      DOCKER_CONFIG = "${config.xdg.configHome}/docker";
      GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
      _JAVA_OPTIONS = "-Djava.util.prefs.userRoot='${config.xdg.configHome}/java'";
    };
    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
    ];
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
      polkit-hyprpolkitagent = {
        Unit = {
          Description = "Hyprland Polkit authentication agent";
          Documentation = "https://wiki.hyprland.org/Hypr-Ecosystem/hyprpolkitagent/";
          After = [ "graphical-session.target" ];
        };

        Service = {
          ExecStart = "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent";
          Restart = "always";
          RestartSec = 2;
          TimeoutStopSec = 10;
        };

        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
