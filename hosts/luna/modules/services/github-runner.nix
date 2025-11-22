{
  pkgs,
  lib,
  config,
  ...
}:
let
  workDirBaseDir = "github-runner-workdirs";
  workDirBaseState = "%S/${workDirBaseDir}";
in
{
  services.github-runners =
    let
      baseRunnerCfg = {
        enable = true;
        replace = true;
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
        (builtins.genList (
          num:
          let
            runnerName = "nix-${builtins.toString (num + 1)}";
            workDirBase = "${workDirBaseDir}/${runnerName}";
            workDirState = "${workDirBaseState}/${runnerName}";
          in
          {
            name = runnerName;
            value = (
              baseRunnerCfg
              // {
                serviceOverrides = {
                  # Done so that the working directory is not set under `/run` which is mounted as
                  # `tmpfs` which uses ram.
                  BindPaths = lib.mkForce [ ];
                  StateDirectory = [
                    workDirBase
                  ];
                  ExecStop =
                    let
                      cleanRunnerWorkDir =
                        pkgs.writeShellScriptBin "github-runner-${runnerName}-clean-workdir" ''
                          find -H "$1" -mindepth 1 -delete
                        ''
                        |> lib.getExe;
                    in
                    [
                      # The NixOS module already cleans the workdir up, but I want to ensure we wipe it out after
                      # the runner is shut down
                      "${cleanRunnerWorkDir} ${(lib.escapeShellArg workDirState)}"
                    ];
                };
                workDir = workDirState;
              }
            );
          }
        ) numBaseRunners)
        |> builtins.listToAttrs;
    in
    baseRunners 8;

  systemd.tmpfiles.settings = {
    "10-cleanup-github-workdirs" = {
      "${workDirBaseState}/*" =
        let
          # System uses `noatime`
          ageBy = "bmBM";
        in
        {
          # Clean up the directory on boot
          "e!" = {
            age = "${ageBy}:0";
          };
          # Wipe out anything older than 1d
          e = {
            age = "${ageBy}:1d";
          };
        };
    };
  };

  environment.persistence.save.directories = [
    {
      directory = "/var/lib/private/github-runner";
      user = "nobody";
      group = "nogroup";
      mode = "0700";
    }
  ];
}
