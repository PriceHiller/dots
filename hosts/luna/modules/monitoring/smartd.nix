{ ... }:
{
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
    devices = [
      {
        device = "/dev/nvme0";
      }
      {
        device = "/dev/nvme1";
      }
      {
        device = "/dev/nvme2";
      }
    ];
  };
}
