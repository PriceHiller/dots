{ ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      # See https://github.com/aristocratos/btop#configurability
      color_theme = "kanagawa-wave";
      vim_keys = true;
      proc_gradient = false;
    };
  };
}
