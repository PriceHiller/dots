{ ... }:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    extraConfig.pipewire."90-default-clock" = {
      "context.properties" = {
        "default.clock" = {
          "allowed-rates" = [
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
          ];
          "quantum" = 32;
          "min-quantum" = 32;
          "max-quantum" = 1024;
        };
      };
    };
  };
}
