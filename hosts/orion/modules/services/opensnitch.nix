{ config, ... }: {
  services.opensnitch = {
    enable = true;
    settings = {
      Firewall = "nftables";
      DefaultAction = "allow";
      ProcMonitorMethod = "ebpf";
    };
  };
  environment.persistence.ephemeral.directories = [
    config.services.opensnitch.settings.Rules.Path
  ];
}