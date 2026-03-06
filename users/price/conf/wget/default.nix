{ pkgs, config, ... }:
{

  xdg.configFile."wgetrc".text = ''
    hsts-file = "${config.xdg.stateHome}/wget-hsts"
  '';
  home = {
    sessionVariables.WGETRC = "${config.xdg.configHome}/wgetrc";
    packages = with pkgs; [
      wget
    ];
  };
}
