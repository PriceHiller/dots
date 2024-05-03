{ ... }:
{
  services.journald = {
    extraConfig = ''
      SystemMaxUse=100G
    '';
  };
}
