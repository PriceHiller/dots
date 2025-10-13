{ pkgs, ... }:
{
  users = {
    mutableUsers = false;
    users.root = {
      shell = pkgs.zsh;
      # Do not require a password to login, this is a bootable live system
      hashedPassword = "";
    };
  };
}
