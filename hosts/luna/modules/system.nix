{ self, ... }:

{
  system = {
    autoUpgrade = {
      enable = true;
      dates = "05:00";
      allowReboot = true;
      flake = self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L"
      ];
    };
  };
}
