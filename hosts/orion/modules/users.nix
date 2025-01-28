{
  pkgs,
  config,
  lib,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;
  users.groups.price = { };
  users.mutableUsers = false;
  users.users = {
    root.hashedPasswordFile = config.age.secrets.users-root-pw.path;
    price = {
      isNormalUser = true;
      extraGroups =
        [
          "wheel"
          "keyd"
          "systemd-journal"
          (lib.mkIf config.virtualisation.docker.enable "docker")
          (lib.mkIf config.programs.wireshark.enable "wireshark")
        ]
        ++ (
          if config.virtualisation.libvirtd.enable then
            [
              "libvirtd"
              "qemu-libvirtd"
              "kvm"
            ]
          else
            [ ]
        );
      group = "price";
      shell = pkgs.zsh;
      createHome = true;
      hashedPasswordFile = config.age.secrets.users-price-pw.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOkWsSntg1ufF40cALcIBA7WZhiU/f0cncqq0pcp+DZY openpgp:0x15993C90"
      ];
    };
  };
  environment.persistence.ephemeral.directories = [
    {
      directory = "/home/price";
      user = "price";
      group = "${config.users.users.price.group}";
      mode = "${config.users.users.price.homeMode}";
    }
  ];
  environment.persistence.ephemeral.users = {
    root = {
      home = (config.users.users.root.home);
      files = [ ".bash_history" ];
    };
  };
}