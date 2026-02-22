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
          job_name = "Luna Metrics";
          static_configs =
            builtins.map
              (
                cfg:
                cfg
                // {
                  labels.host = "${prometheus_host}";
                  labels.instance = "luna.hosts.${config.networking.domain}";
                }
              )
              [
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
                }
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}" ];
                }
                {
                  targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.systemd.port}" ];
                }
                {
                  targets = [ "127.0.0.1:${toString config.services.endlessh-go.prometheus.port}" ];
                }
              ];
        }
      ];
      exporters = {
        nginx = {
          enable = true;
        };
        systemd = {
          enable = true;
        };
        node = {
          enable = true;
          port = 9001;
          enabledCollectors = [
            "logind"
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
      statusPage = true;
      virtualHosts."${prometheus_host}" = {
        forceSSL = true;
        extraConfig = ''
          auth_basic "Password Required";
          auth_basic_user_file ${config.age.secrets.nginx-basic-auth.path};
        '';
        locations."/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
        };
      };
    };
  };

  environment.persistence.save.directories = [
    {
      directory = "/var/lib/${config.services.prometheus.stateDir}";
      user = "prometheus";
      group = "prometheus";
    }
  ];
}