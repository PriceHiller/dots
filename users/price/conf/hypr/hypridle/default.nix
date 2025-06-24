{ ... }:
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener =
        let
          kbd-backlight-dev = "dell::kbd_backlight";
        in
        [
          {
            timeout = 60 * 5;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 60 * 10;
            on-timeout = "${./scripts/is-on-ac.py} && hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on; brightnessctl -r";
          }
          {
            timeout = 15;
            on-timeout = "brightnessctl -sd ${kbd-backlight-dev} set 0";
            on-resume = "brightnessctl -rd ${kbd-backlight-dev}";
          }
          {
            timeout = 3 * 60;
            on-timeout = "${./scripts/set-mon-brightness.py}";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 60 * 10;
            on-timeout = "loginctl lock-session; systemctl suspend";
          }
        ];
    };
  };
}
