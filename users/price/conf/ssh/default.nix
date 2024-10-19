{ lib, ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks =
      rec {
        luna = {
          hostname = "luna.hosts.price-hiller.com";
          user = "price";
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
