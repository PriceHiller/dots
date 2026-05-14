{
  self,
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
        # Waiting on https://github.com/NixOS/nixpkgs/pull/519827
        # unblob
        inetutils
        iproute2
        iperf
        nmap
        traceroute
        mtr
        bubblewrap
      ];
    };

    documentation = {
      dev.enable = true;
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
        enableGlobalCompInit = false;
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
          bwrap-cwd = ''bwrap --ro-bind /nix/store /nix/store --ro-bind-try /etc /etc --ro-bind-try /run/current-system /run/current-system --ro-bind-try /usr/bin/env /usr/bin/env --proc /proc --dev /dev --tmpfs /tmp --bind "$PWD" "$PWD" --chdir "$PWD" --unshare-all --die-with-parent --setenv PATH "$PATH"'';
          ex = "unblob";
          ls = "eza --icons=always --group-directories-first --long --header --octal-permissions --classify --group --extended";
          l = "ls -alh";
          ll = "l";
          nflu = "nix flake update --commit-lock-file";
          Get-Public-IPV4 = "dig @resolver4.opendns.com myip.opendns.com +short -4";
          Get-Public-IPV6 = "dig @resolver1.ipv6-sandbox.opendns.com AAAA myip.opendns.com +short -6";
        };
        syntaxHighlighting.enable = true;
        interactiveShellInit = # zsh
          lib.mkMerge [
            # Default env vars
            # zsh
            ''
              export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
              if [[ ! -d $XDG_CONFIG_HOME ]]; then
                mkdir -p "$XDG_CONFIG_HOME"
              fi
              export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.local/cache}"
              if [[ ! -d $XDG_CACHE_HOME ]]; then
                mkdir -p "$XDG_CACHE_HOME"
              fi
              export XDG_DATA_HOME="''${XDG_DATA_HOME:-$HOME/.local/share}"
              if [[ ! -d $XDG_DATA_HOME ]]; then
                mkdir -p "$XDG_DATA_HOME"
              fi
              export XDG_STATE_HOME="''${XDG_STATE_HOME:-$HOME/.local/state}"
              if [[ ! -d $XDG_STATE_HOME ]]; then
                mkdir -p "$XDG_STATE_HOME"
              fi
              export XDG_CONFIG_DIRS="''${XDG_CONFIG_DIRS:-/etc/xdg}"
            ''
            # Options
            # zsh
            ''
              export HISTFILE="''${XDG_DATA_HOME}/zsh_history"
              export SAVEHIST=10000
              export HISTSIZE=10000
              setopt INC_APPEND_HISTORY_TIME
              setopt EXTENDED_HISTORY
              setopt HIST_FIND_NO_DUPS
              setopt AUTO_PARAM_SLASH

              setopt NULL_GLOB

              setopt AUTO_CD
              setopt AUTO_PUSHD

              setopt HASH_CMDS
              setopt COMBININGCHARS

              setopt RM_STAR_SILENT

              setopt CHASEDOTS

              setopt INTERACTIVE_COMMENTS

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

            # Additional useful plugins
            # zsh
            ''
              source "${pkgs.zsh-nix-shell.src}/nix-shell.plugin.zsh"
              source "${pkgs.zsh-completions.src}/zsh-completions.plugin.zsh"
              source "${pkgs.nix-zsh-completions.src}/nix-zsh-completions.plugin.zsh"
            ''

            # zsh
            ''
              () {
                autoload -Uz compinit bashcompinit
                local cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"

                if [[ ! -d "$cache_dir" ]]; then
                  mkdir -p "$cache_dir"
                fi

                zstyle ':completion:*' cache-path "$cache_dir"
                zstyle ':completion:*' use-cache on
                zstyle ":completion:*:commands" rehash 1

                # Generate a new zcompdump every 24 hours and on every new revision of the system
                local zcompdump="$cache_dir/zcompdump-${self.shortRev or self.dirtyShortRev or "unknown-rev"}"
                local stale_dump=($zcompdump(N.mh+24))
                if [[ -f "$zcompdump" && -z "$stale_dump" ]]; then
                    # zcompdump is not considered stale, re-use it
                    compinit -C -d "$zcompdump"
                else
                    # Rebuild zcompdump
                    compinit -d "$zcompdump"
                fi

                bashcompinit
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
