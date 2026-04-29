{ lib, pkgs, ... }:
{
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
    extraConfig = lib.mkMerge [
      # This is done to ensure `SSH_AUTH_SOCK` is picked up from the user session -- useful for nix
      # invocations that look up submodules.
      #
      # See https://pricehiller.com/posts/private-git-submodule-authentication-and-nixos-rebuilds
      ''
        Defaults env_keep+=SSH_AUTH_SOCK
      ''
    ];
  };

  # See https://developers.yubico.com/pam-u2f/
  # See https://wiki.nixos.org/wiki/Yubikey#pam_u2f
  security.pam = {
    u2f = {
      enable = true;
      settings = {
        cue = true;
        interactive = true;
        authfile = (
          [
            "price:oYMgpB9Q7aMcluicIdQS+5g3J1xRqcaavscWUZCRw2xSvAETwzwVoQU9vAlxQv/SMXyiDYepMWAKstQr3bUuZA==,k6klh6t5iwW8Kh1hHgBMmU0AT86/2Vm9bYHhoW9OZNGLE6dO7LhfJAnDS8J+fGiejxcUFg7S2gLyfgkKxo6bBw==,es256,+presence"
          ]
          |> builtins.concatStringsSep "\n"
          |> pkgs.writeText "u2f_keys"
        );
      };
    };
    services = {
      sudo = {
        u2f = {
          enable = true;
          control = "sufficient";
        };
      };
    };
  };
}
