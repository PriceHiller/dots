{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (discord.override {
      withEquicord = true;
    })
  ];
}
