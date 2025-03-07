{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      black
      basedpyright
      python313Full
      uv
      (poetry.withPlugins (
        p: with p; [
          poetry-plugin-shell
        ]
      ))
    ];
    sessionVariables = {
      PYTHON_HISTORY = "${config.xdg.dataHome}/python_history";
    };
  };
}
