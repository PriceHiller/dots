{ ... }:
{
  services.memcached = {
    enable = true;
    maxMemory = 512;
  };
}
