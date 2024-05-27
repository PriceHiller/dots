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
    themes.Kanagawa = builtins.readFile ./Kanagawa.tmTheme;
  };
}
