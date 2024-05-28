{ ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''
      () {
        autoload -U compinit
        local zsh_cache="''${XDG_CACHE_HOME:-$HOME}/zsh/"
        if [[ ! -d "$zsh_cache" ]]; then
          mkdir -p "$zsh_cache"
        fi
        local _comp_files=($zsh_cache/zcompcache(Nm-20))
        if (( $#_comp_files )); then
          compinit -i -C -d "$zsh_cache/zcompcache"
        else
          compinit -i -d "$zsh_cache/zcompcache"
        fi
      }
    '';
    initExtra = builtins.readFile ./init-extra.zsh;
  };
}
