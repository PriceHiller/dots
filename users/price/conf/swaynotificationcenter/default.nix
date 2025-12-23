{ pkgs, ... }:
{

  home.packages = with pkgs; [
    swaynotificationcenter
  ];
  services.swaync = {
    enable = true;
    style =
      pkgs.runCommand "build-scss"
        {
          nativeBuildInputs = [ pkgs.dart-sass ];

        }
        ''
          sass --style expanded ${./style}/style.scss $out
        '';

  };
}
