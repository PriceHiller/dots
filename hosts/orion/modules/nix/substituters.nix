{
  config,
  pkgs,
  lib,
  ...
}:
let
  ncro-netrc-file = "/run/ncro-auth/netrc";
in
{
  systemd.services.generate-ncro-netrc = {
    description = "Generate netrc for ncro";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "root";
      RuntimeDirectory = "ncro-auth";
      RuntimeDirectoryMode = "0700";
      UMask = "0077";
      EnvironmentFile = config.age.secrets.basic-auth-env.path;
      ExecStart = pkgs.writeShellScript "generate-ncro-netrc" ''
        set -eu

        : "''${BASIC_AUTH_USERNAME:?BASIC_AUTH_USERNAME is required}"
        : "''${BASIC_AUTH_PASSWORD:?BASIC_AUTH_PASSWORD is required}"

        ${pkgs.coreutils}/bin/cat > "${ncro-netrc-file}.tmp" <<-EOF
        	machine nix.cache.pricehiller.com
        	login $BASIC_AUTH_USERNAME
        	password $BASIC_AUTH_PASSWORD
        EOF

        ${pkgs.coreutils}/bin/mv \
          "${ncro-netrc-file}.tmp" \
          "${ncro-netrc-file}"
      '';
    };
  };

  systemd.services.ncro = {
    requires = [ "generate-ncro-netrc.service" ];
    after = [ "generate-ncro-netrc.service" ];
  };

  services.ncro = {
    enable = true;
    netrcFile = ncro-netrc-file;
    port = 8081;
    openFirewall = false;
    socketActivation = true;
    settings = {
      server.listen = "127.0.0.1:9876";
      upstreams = [
        {
          url = "https://cache.nixos.org";
          priority = 10;
        }
        {
          url = "https://nix.cache.pricehiller.com";
          priority = 20;
          public_key = "nix.cache.pricehiller.com-1:itknnAnhCcMXhaRfY9AxCBlaa8CaNWfvEeVx007yfYA=";
        }
        {
          url = "https://nix-community.cachix.org";
          priority = 30;
          public_key = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
        }
        {
          url = "https://hyprland.cachix.org";
          priority = 50;
          public_key = "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=";
        }
      ];
    };
  };

  nix.settings.substituters = lib.mkForce [
    "http://${config.services.ncro.settings.server.listen}?trusted=true"
  ];

  environment.persistence.ephemeral.directories = [
    {
      # Persist the backing directory for ncro
      directory = "/var/lib/private/ncro";
      user = "root";
      group = "root";
      mode = "0755";
    }
  ];
}
