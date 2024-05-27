{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = rec {
      luna = {
        hostname = "luna.hosts.orion-technologies.io";
        user = "price";
        port = 2200;
      };
      "luna.hosts.orion-technologies.io" = luna;
    };
  };
}
