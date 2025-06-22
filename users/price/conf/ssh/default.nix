{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks =
      rec {
        ch-1 = {
          hostname = "129.114.27.58";
          user = "cc";
        };
        ch-2 = {
          hostname = "129.114.26.136";
          user = "cc";
        };
        luna = {
          hostname = "luna.hosts.price-hiller.com";
          user = "root";
          port = 2200;
        };
        "luna.hosts.price-hiller.com" = luna;
        asgard = {
          hostname = "asgard-eternal.com";
          user = "asgard";
        };
        "asgard-eternal.com" = asgard;
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
