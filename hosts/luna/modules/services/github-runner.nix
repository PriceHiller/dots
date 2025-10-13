{ pkgs, config, ... }:
{
  services.github-runners =
    let
      baseRunnerCfg = {
        enable = true;
        tokenFile = config.age.secrets.gh-token.path;
        url = "https://github.com/phobost";
        extraLabels = [
          "nix"
          "luna"
        ];
        extraPackages = with pkgs; [
          nix
          bash
          coreutils-full
          ripgrep
          jq
          curlFull
        ];
      };
      baseRunners =
        numBaseRunners:
        (builtins.genList (num: {
          name = "nix-${builtins.toString (num + 1)}";
          value = baseRunnerCfg;
        }) numBaseRunners)
        |> builtins.listToAttrs;
    in
    baseRunners 8;

  environment.persistence.save.directories = [
    {
      directory = "/var/lib/private/github-runner";
      user = "nobody";
      group = "nogroup";
      mode = "0700";
    }
  ];
}
