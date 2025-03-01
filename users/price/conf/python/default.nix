{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      python314Full
      uv
      (poetry.withPlugins (
        p: with p; [
          poetry-plugin-shell
        ]
      ))
    ];
    sessionVariables = {
      PYTHON_HISTORY = "${config.xdg.dataHome}/python/history";
    };
  };
}
