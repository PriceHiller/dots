{ pkgs, ... }:
{
  services = {
    printing = {
      enable = true;
      stateless = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        brlaser
        brgenml1lpr
        cnijfilter2
        splix
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    simple-scan
    system-config-printer
  ];
}