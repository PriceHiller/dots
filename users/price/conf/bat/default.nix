{ ... }:
{
  programs.bat = {
    enable = true;
    config = {
      italic-text = "always";
      pager = "never";
      theme = "Kanagawa";
    };
    themes.Kanagawa.src = ./Kanagawa.tmTheme;
  };
}
