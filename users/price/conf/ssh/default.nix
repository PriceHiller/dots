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
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = rec {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        serverAliveInterval = 10;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/state/known_hosts";
        controlMaster = "auto";
        controlPath = "~/.ssh/state/controllers/controller-%r@%n:%p";
        controlPersist = "1h";
      };
      luna = {
        hostname = "luna.hosts.pricehiller.com";
        user = "root";
        port = 10322;
      };
      "luna.hosts.pricehiller.com" = luna;
    };
  };
}
