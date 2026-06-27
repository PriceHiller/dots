{ pkgs, config, ... }:
let
  webdav-host = "fs.pricehiller.com";
  creds-svc-name = "setup-davfs-creds";
  mount-path = "/mnt/${webdav-host}";
in
{

  # Webdav support
  services.davfs2 = {
    enable = true;
  };

  age.secrets.copyparty-users-price-pw = {
    group = config.services.davfs2.davGroup;
    mode = "0440";
  };

  systemd.services.${creds-svc-name} = {
    description = "Setup Webdav creds for ${creds-svc-name}";
    serviceConfig = {
      Type = "oneshot";
      LoadCredential = "pw:${config.age.secrets.copyparty-users-price-pw.path}";
      ExecStart = pkgs.writeShellScript "gen-webdav-creds" ''
        PW="$(cat "$CREDENTIALS_DIRECTORY/pw")"
        echo "/mnt/${webdav-host} price \"$PW\"" > /etc/davfs2/secrets
        chmod 0600 /etc/davfs2/secrets
      '';
      RemainAfterExit = true;
    };
  };

  systemd.mounts = [
    rec {
      description = "Webdav Mount for '${webdav-host}'";
      after = [
        "network-online.target"
        "${creds-svc-name}.service"
      ];
      wants = after;
      what = "https://${webdav-host}";
      options = "uid=${config.services.davfs2.davGroup},gid=${config.services.davfs2.davGroup},dir_mode=2770,file_mode=0660,grpid";
      where = mount-path;
      type = "davfs";
    }
  ];

  systemd.automounts = [
    {
      description = "Webdav Mount for '${webdav-host}'";
      where = mount-path;
      automountConfig.TimeoutIdleSec = "30min";
      wantedBy = [ "multi-user.target" ];
    }
  ];
}
