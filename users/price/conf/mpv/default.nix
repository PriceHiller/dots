{ pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    package = (
      pkgs.mpv.override {
        scripts = with pkgs.mpvScripts; [
          thumbfast
          sponsorblock
          uosc
        ];
        mpv-unwrapped = pkgs.mpv-unwrapped.override {
          waylandSupport = true;
          ffmpeg = pkgs.ffmpeg-full;
        };
      }
    );
    bindings = {
      tab = "script-binding uosc/toggle-ui";
      "?" = "script-binding uosc/keybinds";
      "mbtn_right" = "script-binding uosc/toggle-ui";
      "menu" = "script-binding uosc/menu";
    };
    config = {
      keep-open = "yes";
      hwdec = "auto-safe";
      vo = "gpu";
      osd-bar = "no";
      border = "no";
      profile = "gpu-hq";
      gpu-context = "wayland";
    };
  };
}
