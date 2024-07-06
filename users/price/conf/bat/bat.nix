{ ... }:
{
  programs.bat = {
    enable = true;
    config = {
      style = "header,grid,numbers,snip";
      italic-text = "always";
      pager = "never";
      theme = "Kanagawa";
    };
    themes.Kanagawa.src = ./Kanagawa.tmTheme;
  };
}
