{
  config,
  lib,
  ...
}:
let
  cfg = config.ext.persistence;
in
{
  options.ext.persistence = {
    enable = lib.mkEnableOption "Set up some useful defaults for impermanence";
    persistDir = lib.mkOption {
      description = "Directory to use to persist files/directories";
      default = "/persist";
      type = lib.types.either (lib.types.str) (lib.types.path);
    };
  };

  config = lib.mkIf (cfg.enable) {
    system.activationScripts."systemd-private-perms" = {
      # Ensure the systemd private directory has the correct permissions set
      #
      # Impermanence will create the outer parent directory and set wrong permissions for it if any
      # path within is persisted, thus we need to set it back to what systemd expects
      deps = [
        "persist-files"
        "createPersistentStorageDirs"
      ];
      text = ''
        mkdir -p /var/lib/private
        chmod 0700 /var/lib/private

        mkdir -p /var/log/private
        chmod 0700 /var/log/private
      '';
    };

    fileSystems."${cfg.persistDir}".neededForBoot = true;

    environment.persistence.save = {
      hideMounts = true;
      persistentStoragePath = "${cfg.persistDir}/save";
      directories = [
        # Persist log files
        "/var/log"
        "/var/lib/lastlog"
      ];
    };

    environment.persistence.critical = {
      persistentStoragePath = "${cfg.persistDir}/critical";
      hideMounts = true;
      files = [
        # Persist machine id
        # See https://nixos.org/manual/nixos/stable/#sec-machine-id
        "/etc/machine-id"
      ];
      directories = builtins.concatLists [
        [
          # Persist systemd state
          # see https://nixos.org/manual/nixos/stable/#sec-var-systemd
          "/var/lib/systemd"
        ]

        # Persist important state for users
        # see https://nixos.org/manual/nixos/stable/#sec-state-users
        [
          "/var/lib/nixos"
        ]
      ];
    };

    environment.persistence.ephemeral = {
      persistentStoragePath = "${cfg.persistDir}/ephemeral";
      hideMounts = true;

      directories = [
        # Systemd needs the `/usr` directory to exist on boot -- see
        # https://github.com/nix-community/impermanence/issues/253#issuecomment-2614528056
        "/usr/systemd-placeholder"

        # TODO: Remove this and correctly identify all specific directories to persist
        # Generically hang onto state from most services
        "/var/lib"
      ];
    };
  };
}
