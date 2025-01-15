{ ... }:
{
  services.smartd = {
    enable = true;
    notifications.mail.enable = true;
    devices = [
      {
        device = "/dev/nvme0";
      }
    ];
  };
}
