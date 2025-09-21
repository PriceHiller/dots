{ config, ... }:
let
  prometheus_host = "prometheus.${config.networking.domain}";
in
{
  services = {
    prometheus = {
      enable = true;
      port = 9000;
      globalConfig = {
        scrape_interval = "15s";
      };
      scrapeConfigs = [
        {
          job_name = "node-exporter";
          static_configs = [
            {
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
              labels = {
                host = "${prometheus_host}";
              };
            }
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
      virtualHosts."${prometheus_host}" = {
        enableACME = true;
        forceSSL = true;
        extraConfig = ''
          auth_basic "Password Required";
          auth_basic_user_file ${config.age.secrets.prometheus-basic-auth.path};
        '';
        locations."/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
        };
      };
    };
  };
  age.secrets.prometheus-basic-auth = {
    owner = config.services.nginx.user;
    group = config.services.nginx.user;
  };
  environment.persistence.save.directories = [
    {
      directory = "/var/lib/${config.services.prometheus.stateDir}";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}
