{
  config,
  inputs,
  pkgs,
  clib,
  lib,
  ...
}:
let
  nix-netrc-path = "/run/nix-cache-config";
in
{
  age.secrets.nix-access-tokens = {
    mode = "440";
    group = "wheel";
  };

  nixpkgs.config.allowUnfree = true;

  systemd.services.generate-nix-cache-config = {
    description = "Generate nix cache config with credentials";
    wantedBy = [ "nix-daemon.service" ];
    before = [ "nix-daemon.service" ];
    serviceConfig = {
      Type = "oneshot";
      EnvironmentFile = config.age.secrets.basic-auth-env.path;
      ExecStart =
        let
        in
        pkgs.writeShellScript "gen-nix-config" ''
          echo "machine nix.cache.pricehiller.com" >> ${nix-netrc-path}
          echo "login $BASIC_AUTH_USERNAME" >> ${nix-netrc-path}
          echo "password $BASIC_AUTH_PASSWORD" >> ${nix-netrc-path}
          chmod 440 ${nix-netrc-path}
          chown root:wheel ${nix-netrc-path}
        '';
      RemainAfterExit = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "home-manager=${inputs.home-manager}"
    ];
    extraOptions = ''
      !include ${config.age.secrets.nix-access-tokens.path}
      netrc-file = ${nix-netrc-path}
    '';
    settings = {
      # Make the download buffer 256 mb
      download-buffer-size = 256 * (clib.pow 2 20);
      # Allow more connections in parallel to fetch files
      http-connections = 50;
      # If a nix build fails, we want to hang onto its build directory for debugging
      keep-failed = true;
      auto-optimise-store = true;
      commit-lock-file-summary = "build(nix): update flake.lock";
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
        "ca-derivations"
        "recursive-nix"
        "dynamic-derivations"
      ];
      use-xdg-base-directories = true;
      allowed-users = [
        "@wheel"
        # DynamicUser services have no /etc/group entry, so group-based checks
        # fail. Allow the dynamic username directly.
        "nix-post-build-hook-queue"
      ];
      trusted-users = [
        "@wheel"
      ];
      substituters = [
        "https://nix.cache.pricehiller.com"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
      ];
      log-lines = 100;
      max-jobs = "auto";
      trusted-public-keys = [
        "nix.cache.pricehiller.com-1:itknnAnhCcMXhaRfY9AxCBlaa8CaNWfvEeVx007yfYA="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      secret-key-files = [ config.age.secrets.nix-cache-signing-key.path ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };

  services.nix-post-build-hook-queue = {
    enable = true;
    signingPrivateKeyPath = config.age.secrets.nix-cache-signing-key.path;
    sshPrivateKeyPath = config.age.secrets.ssh-automation-key.path;
    uploadTo = "ssh://nix-ssh@nix.cache.pricehiller.com:10322";
  };

  programs.ssh.knownHostsFiles = [
    (pkgs.writeText "luna" ''
      [luna.hosts.pricehiller.com]:10322 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKm8jeE4idKQiUGqFv17SEcfR2zzVIL5c/miuvOfy3A3
      [git.pricehiller.com]:10322 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKm8jeE4idKQiUGqFv17SEcfR2zzVIL5c/miuvOfy3A3
      [nix.cache.pricehiller.com]:10322 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKm8jeE4idKQiUGqFv17SEcfR2zzVIL5c/miuvOfy3A3
    '')
  ];
}
