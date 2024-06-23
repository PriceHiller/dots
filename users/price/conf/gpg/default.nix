{ pkgs, config, ... }:
{
  programs.gpg = {
    homedir = "${config.xdg.dataHome}/gnupg";
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
    publicKeys = [
      {
        source = ./public-gpg-yubikey.asc;
        trust = "ultimate";
      }
    ];
    settings = {
      pinentry-mode = "loopback";
    };
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentryPackage = pkgs.pinentry-qt;
    maxCacheTtl = 14400;
    maxCacheTtlSsh = 14400;
    sshKeys = [ "530D3EC95C32AB9EC33714AAF865738D6E77680A" ];
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
