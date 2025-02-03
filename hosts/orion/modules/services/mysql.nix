{ pkgs, ... }:
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    ensureUsers = [
      {
        name = "price";
        ensurePermissions = {
          "price.*" = "ALL PRIVILEGES";
        };
      }
    ];
    settings = {
      mysqld.bind_address = "localhost";
    };
  };
  environment.systemPackages = [
    pkgs.mysql-workbench
  ];
  services.gnome.gnome-keyring.enable = true;
}