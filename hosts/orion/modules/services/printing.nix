{ pkgs, config, ... }:
{
  services = {
    printing = {
      enable = true;
      listenAddresses = [ "127.0.0.1:631" ];
      stateless = true;
      drivers = with pkgs; [
        gutenprint
        hplip
        brlaser
        brgenml1lpr
        # Currently broken, waiting on https://github.com/NixOS/nixpkgs/pull/477193
        # cnijfilter2
        splix
      ];
    };
  };
  environment.systemPackages = with pkgs; [
    simple-scan
    system-config-printer
  ];
  services.nginx.virtualHosts."print.localhost".locations."/" = {
    proxyPass = "http://${builtins.elemAt config.services.printing.listenAddresses 0}/";
    # Disabled to allow modification of the `Host` header
    recommendedProxySettings = false;
    # set the Host header to deal with some security stuff on CUPS side validing the `Host` header
    extraConfig = ''
      proxy_set_header Host localhost;
    '';
  };
}
