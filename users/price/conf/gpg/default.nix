{ pkgs, config, ... }:
{
  programs.gpg = {
    homedir = "${config.xdg.dataHome}/gnupg";
    enable = true;
    mutableKeys = false;
    mutableTrust = false;
    scdaemonSettings = {
      disable-ccid = true;
      pcsc-shared = true;
    };
    publicKeys = [
      {
        source = ./public-gpg-yubikey.asc;
        trust = "ultimate";
      }
    ];
  };
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-rofi;
    maxCacheTtl = 4 * 60 * 60;
    maxCacheTtlSsh = 4 * 60 * 60;
    sshKeys = [ "530D3EC95C32AB9EC33714AAF865738D6E77680A" ];
    extraConfig = ''
      allow-loopback-pinentry
    '';
  };
}
