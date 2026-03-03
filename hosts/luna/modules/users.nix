{ pkgs, config, ... }:
{
  security.sudo = {
    wheelNeedsPassword = false;
    execWheelOnly = true;
  };
  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        shell = pkgs.zsh;
        hashedPasswordFile = config.age.secrets.users-root-pw.path;
      };
    };
  };
  environment.persistence.ephemeral.directories = [
    {
      directory = "/root";
      user = "root";
      group = "root";
      mode = "u=rwx,g=,o=";
    }
  ];
}
