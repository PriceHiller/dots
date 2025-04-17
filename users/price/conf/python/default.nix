{ pkgs, config, ... }:
{
  home = {
    packages = with pkgs; [
      ruff
      basedpyright
      (python313.withPackages (
        py-pkgs: with py-pkgs; [
          debugpy
        ]
      ))
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
