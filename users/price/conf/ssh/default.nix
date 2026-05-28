{ lib, config, ... }:
let
  ssh-state-dir = "${config.home.homeDirectory}/.ssh/state";
in
{
  home.activation.ensureSSHControlDirExists =
    lib.hm.dag.entryAfter [ "writeBoundary" ]
      # bash
      ''
        run echo "Ensuring ssh state directory exists at '${ssh-state-dir}'"
        run mkdir -p '${ssh-state-dir}/controllers'
        run chmod 0700 '${ssh-state-dir}'
      '';

  # See https://github.com/nix-community/home-manager/issues/322#issuecomment-3730266609
  # To ensure ssh picks up the right perms for `~/.ssh/config`
  home.file = {
    # home-manager wrongly thinks it doesn't manage (and thus shouldn't clobber) this file due to the activation script
    ".ssh/config".force = true;
  };

  home.activation = {
    # https://github.com/nix-community/home-manager/issues/322
    fixSshPermissions = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      run install -d -m 0700 "$HOME/.ssh"
      if [ -L "$HOME/.ssh/config" ]; then
        src="$(readlink -f "$HOME/.ssh/config")"
        run rm -f "$HOME/.ssh/config"
        run install -m 0600 "$src" "$HOME/.ssh/config"
      fi
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = rec {
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = false;
        ServerAliveInterval = 10;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/state/known_hosts";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/state/controllers/controller-%r@%n:%p";
        ControlPersist = "1h";
      };
      luna = {
        HostName = "luna.hosts.pricehiller.com";
        User = "root";
        Port = 10322;
      };
      "luna.hosts.pricehiller.com" = luna;
    };
  };
}
