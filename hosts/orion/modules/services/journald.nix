{ ... }:
{
  ext.journald = {
    enable = true;
    settings = {
      MaxRetentionSec = "7d";
    };
  };
}
