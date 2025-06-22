{ ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      keep-open = "yes";
      hwdec = "auto-safe";
      vo = "gpu";
      profile = "gpu-hq";
      gpu-context = "wayland";
    };
  };
}
