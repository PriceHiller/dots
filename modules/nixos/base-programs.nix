{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.ext.basePrograms;
  mkEnabledOption =
    description:
    lib.options.mkOption {
      description = description;
      type = lib.types.bool;
      default = true;
    };
in
{
  options.ext.basePrograms = {
    enable = lib.options.mkEnableOption "Install & Configure default programs";
    zsh = lib.options.mkOption {
      description = "Zsh specific options";
      default = { };
      type = lib.types.submodule {
        options = {
          enable = mkEnabledOption "Whether to enable Zsh";
          enableFzfTab = mkEnabledOption "Whether to enable fzf-tab for completions";
        };
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment = {
      sessionVariables = {
        DO_NOT_TRACK = 1;
      };
      systemPackages = with pkgs; [
        eza
        dust
        man
        fd
        fzf
        curl
        git
        dig
        rsync
        unzip
        ripgrep
        htop
        killall
        zip
        unzip
        openssl
        openssh
        age
        man-pages
        man-pages-posix
        jq
        coreutils-full
        unblob
        inetutils
        iperf
        nmap
        traceroute
        mtr
      ];
    };

    documentation = {
      dev.enable = true;
      nixos.includeAllModules = true;
    };

    programs = {
      neovim = {
        enable = true;
        defaultEditor = true;
      };
      fzf = {
        keybindings = true;
        fuzzyCompletion = true;
      };
      zsh = {
        enable = true;
        enableCompletion = true;
        enableGlobalCompInit = true;
        enableBashCompletion = true;
        autosuggestions = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
          extraConfig = {
            "ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE" = "20";
          };
        };
        shellAliases = {
          ex = "unblob";
          ls = "eza --icons=always --group-directories-first --long --header --octal-permissions --classify --group --extended";
          l = "ls -alh";
          ll = "l";
          Get-Public-IPV4 = "dig @resolver4.opendns.com myip.opendns.com +short -4";
          Get-Public-IPV6 = "dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6";
        };
        syntaxHighlighting.enable = true;
        interactiveShellInit = # zsh
          lib.mkMerge [
            # Options
            # zsh
            ''
              export SAVEHIST=10000
              export HISTSIZE=10000
              setopt INC_APPEND_HISTORY_TIME
              setopt EXTENDED_HISTORY
              setopt HIST_FIND_NO_DUPS
              setopt AUTO_PARAM_SLASH

              setopt EXTENDED_GLOB
              setopt NULL_GLOB

              setopt AUTO_CD
              setopt AUTO_PUSHD

              setopt HASH_CMDS
              setopt COMBININGCHARS

              setopt RM_STAR_SILENT

              setopt CHASEDOTS

              unsetopt BEEP

            ''

            # zsh
            ''
              export FZF_DEFAULT_COMMAND='fd --hidden --exclude .git --color=always'
              export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --info=inline --border --margin=1 --ansi"
              export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

              export ZSH_HIGHLIGHT_MAXLENGTH=10000
            ''
            # Helpers
            # zsh
            ''
              tree() {
                local cmd="ls --tree"
                if [[ -n "''${*}" ]]; then
                  eval "$cmd ''${@}"
                else
                  eval "$cmd"
                fi
              }

            ''

            (lib.mkIf cfg.zsh.enableFzfTab
              # Ensure we load fzf-tab AFTER compinit
              # zsh
              ''source "${pkgs.zsh-fzf-tab.src}/fzf-tab.plugin.zsh"''
            )
          ];
      };
    };
  };
}
