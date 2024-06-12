{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      dotnet-sdk_8
      csharp-ls
    ];
    sessionVariables = rec {
      OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
      NUGET_PACKAGES = "${config.xdg.dataHome}/NuGetPackages";
      DOTNET_ROOT = "${config.xdg.dataHome}/Dotnet";
      DOTNET_CLI_HOME = DOTNET_ROOT;
      DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    };
  };
}
