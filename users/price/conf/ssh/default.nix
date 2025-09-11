{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = rec {
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
      luna = {
        hostname = "luna.hosts.pricehiller.com";
        user = "root";
        port = 2200;
      };
      "luna.hosts.pricehiller.com" = luna;
      webtech = {
        hostname = "webtech.pricehiller.com";
        user = "root";
      };
      "webtech.pricehiller.com" = webtech;
    }
    # NOTE: UTSA Hosts behind VPN server
    // builtins.listToAttrs (
      builtins.map (
        num:
        let
          hostname = "fox${
            if (num > 0 && num < 10) then "0${builtins.toString num}" else builtins.toString num
          }.cs.utsarr.net";
        in
        {
          name = hostname;
          value = {
            user = "zfp106";
            inherit hostname;
          };
        }
      ) (lib.range 1 4)
    );
  };
}
