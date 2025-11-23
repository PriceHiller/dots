{ pkgs, ... }:
let
  nix-build-dir = "/nix/build/";
in
{
  systemd.tmpfiles.settings = {
    "10-cleanup-nix-build-dirs-on-boot" = {
      "${nix-build-dir}" =
        let
          # System uses `noatime`
          ageBy = "bmBM";
        in
        {
          # Clean up the build directory on boot and ensure it exists
          "d!" = {
            group = "root";
            user = "root";
            mode = "0700";
            age = "${ageBy}:0";
          };
          d = {
            group = "root";
            user = "root";
            mode = "0700";
          };
        };
    };
  };
  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      # Override the build-dir so it points to a path that _isn't_ mounted on `tmpfs`.
      # If we have large-ish build artifacts in `tmpfs` that can quickly exceed the storage size of
      # the volume and cause the nix daemon to fail due a lack of memory
      build-dir = nix-build-dir;
      experimental-features = [
        "pipe-operators"
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "daily";
    };
  };
}
