{ config, pkgs, ... }:
let
  prometheus_host = "prometheus.${config.networking.domain}";
in
{
  services = {
    prometheus = {
      enable = true;
      port = 9000;
      scrapeConfigs = [
        {
          job_name = "node-exporter";
          static_configs = [
            { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ]; }
          ];
        }
      ];
      exporters = {
        node = {
          enable = true;
          port = 9001;
          enabledCollectors = [
            "arp"
            "bcache"
            "btrfs"
            "bonding"
            "cpu"
            "cpufreq"
            "diskstats"
            "edac"
            "entropy"
            "fibrechannel"
            "filefd"
            "filesystem"
            "hwmon"
            "ipvs"
            "loadavg"
            "meminfo"
            "mdadm"
            "netclass"
            "netdev"
            "netstat"
            "nfs"
            "nfsd"
            "nvme"
            "os"
            "powersupplyclass"
            "pressure"
            "rapl"
            "schedstat"
            "sockstat"
            "softnet"
            "stat"
            "thermal_zone"
            "time"
            "udp_queues"
            "uname"
            "vmstat"
            "systemd"
          ];
        };
      };
    };

    nginx = {
      additionalModules = [ pkgs.nginxModules.pam ];
      virtualHosts."${prometheus_host}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          auth_pam "Password Required";
          auth_pam_service_name "nginx";
        '';
        locations."/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
        };
      };
    };
  };
  security.pam.services.nginx.setEnvironment = false;
  systemd.services.nginx.serviceConfig = {
    SupplementaryGroups = [ "shadow" ];
  };

  environment.persistence.save.directories = [
    {
      directory = "/var/lib/${config.services.prometheus.stateDir}";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}