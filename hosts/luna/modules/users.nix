{ pkgs, config, ... }:
{
  security.sudo.wheelNeedsPassword = false;
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users = {
      root.hashedPasswordFile = config.age.secrets.users-root-pw.path;
      price = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.age.secrets.users-price-pw.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkWsSntg1ufF40cALcIBA7WZhiU/f0cncqq0pcp+DZY openpgp:0x15993C90"
        ];
      };
    };
  };
  environment.persistence.ephemeral.users = {
    price = {
      files = [ ".bash_history" ".zsh_history" ];
    };
    root = {
      home = "/root";
      files = [ ".bash_history" ".zsh_history" ];
    };
  };
}