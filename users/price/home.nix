{
  pkgs,
  config,
  lib,
  osConfig,
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
  age = {
    identityPaths = [
      "${config.home.homeDirectory}/.ssh/age-key"
      "${config.home.homeDirectory}/.ssh/id_ed25519"
    ];
  };
  imports = [ ./conf ];
  programs.home-manager.enable = true;
  home = {
    stateVersion = "${osConfig.system.stateVersion}";
    language.base = "en_US.UTF-8";
    preferXdgDirectories = true;
    packages =
      with pkgs;
      [
        prismlauncher
        ciscoPacketTracer9
        anki
        terraform
        imhex
        obs-studio
        xdg-utils
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
        plantuml
        graphviz
        libnotify
        graphviz
        gcolor3
        typescript
        deno
        powershell
        kooha
        libreoffice-fresh
        nix-prefetch-scripts
        wl-clipboard
        grim
        slurp
        unzip
        Fmt
        screen-cap
        shfmt
        wezterm
        kitty
        sqlite
        swaylock-effects
        luajit
        luarocks
        imagemagick
        shellcheck
        ruby
        yamllint
        curl
        openssh
        gradle
        maven
        pwvucontrol
        openssl
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
        dust
        fd
        playerctl
        nixfmt
        lxappearance
        stylua
        typstyle
        typst
        mullvad-vpn
        easyeffects
        egl-wayland
        brightnessctl
        spotify
        nix-output-monitor
        sops
        tree-sitter
        strawberry
        d2
        rustdesk-flutter
      ]
      ++ [
        age
        age-plugin-yubikey
        passage
      ]
      ++ [
        gnumake
        cmake
        nasm
        asm-lsp
        asmfmt
        ninja
        ccache
        llvm
        pkg-config
        meson
        muon
        cmake-language-server
      ];

    file = softLinkDots ".config";

    sessionVariables = {
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
      PKG_CONFIG_PATH = "${config.home.profileDirectory}/lib/pkgconfig";
      ANDROID_USER_HOME = "${config.xdg.dataHome}/android";
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
    systemDirs.data = [
      "${config.home.profileDirectory}/share/"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
    ];
    cacheHome = "${config.home.homeDirectory}/.local/cache";
    mimeApps.enable = true;
  };

  # This ensures that all activation scripts pick up desired `XDG` environment variables
  home.activation.setXdgEnv =
    lib.hm.dag.entryBefore [ "writeBoundary" ]
      # bash
      ''
        export XDG_CACHE_HOME="${config.xdg.cacheHome}"
        export XDG_CONFIG_HOME="${config.xdg.configHome}"
        export XDG_DATA_HOME="${config.xdg.dataHome}"
        export XDG_STATE_HOME="${config.xdg.stateHome}"
      '';

  programs = {
    nix-index.enable = true;
    wofi.enable = true;
    waybar = {
      enable = true;
      systemd.enable = true;
    };
  };

  services = {
    blueman-applet.enable = true;
    easyeffects.enable = true;
    opensnitch-ui.enable = true;
  };

  systemd.user = {
    startServices = "sd-switch";
    services = {
      waybar = {
        Service = {
          RestartSec = 3;
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Unit = {
          PartOf = [ "graphical-session.target" ];
        };
      };
      gromit-mpx.Service.ExecStart = lib.mkForce "${pkgs.coreutils}/bin/echo 'Disabled, managed by WM'";
      easyeffects = {
        Install.WantedBy = [ "graphical-session.target" ];
        Unit = {
          PartOf = [ "graphical-session.target" ];
        };
      };
      polkit-hyprpolkitagent = {
        Unit = {
          Description = "Hyprland Polkit authentication agent";
          Documentation = "https://wiki.hyprland.org/Hypr-Ecosystem/hyprpolkitagent/";
          PartOf = [ "graphical-session.target" ];
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
