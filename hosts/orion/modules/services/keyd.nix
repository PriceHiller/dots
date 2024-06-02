{ ... }:
{
  users.groups.keyd = { };
  systemd.services.keyd.serviceConfig.Group = "keyd";
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          leftmeta = "layer(meta_custom)";
        };
        "meta_custom:M" = {
          c = "C-c";
          v = "C-v";
        };
      };
    };
  };
}
