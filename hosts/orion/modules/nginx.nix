{ ... }:
{
  services.nginx = {
    enable = true;
    # Do not listen on public IPs, for local use only
    defaultListenAddresses = [
      "127.0.0.1"
      "[::1]"
    ];
    recommendedProxySettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedTlsSettings = true;
  };
}
