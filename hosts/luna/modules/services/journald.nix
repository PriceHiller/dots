{ ... }:
{
  ext.journald = {
    enable = true;
    settings = {
      SystemMaxFileSize = "100M";
    };
  };
}
