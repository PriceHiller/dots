{ pkgs }:
pkgs.writeShellApplication {
  name = "screen-cap";
  runtimeInputs = with pkgs; [
    wl-screenrec
    gifski
    inotify-tools
    libnotify
    mktemp
    slurp
    file
  ];
  text = ''
    #!${pkgs.bash}/bin/bash
    ${builtins.readFile ./screen-cap.bash}
  '';
}
