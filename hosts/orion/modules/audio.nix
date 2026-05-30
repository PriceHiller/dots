{ ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    extraConfig.pipewire."10-default-clock" = {
      "context.properties" = {
        "default.clock.allowed-rates" = [
          44100
          48000
          88200
          96000
          176400
          192000
          352800
          384000
          705600
          768000
          1411200
        ];
        "default.clock.quantum" = 2048;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 4096;
      };
    };
  };
}
