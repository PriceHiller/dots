{ pkgs, config, ... }:
let
  AWS-HOME = "${config.xdg.cacheHome}/aws";
in
{
  home = {
    file."${AWS-HOME}/.hm-create" = {
      text = ''
        Created by hm to ensure `${AWS-HOME}` exists.

        Do NOT edit!
      '';
      force = true;
    };
    packages = [
      (pkgs.symlinkJoin {
        name = "aws";
        paths = [ pkgs.awscli2 ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/aws" \
            --set 'HOME' '${AWS-HOME}'
        '';
      })
    ];
    sessionVariables = {
      AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
      AWS_CLI_HISTORY_FILE = "${config.xdg.dataHome}/aws/history";
      AWS_CREDENTIALS_FILE = "${config.xdg.dataHome}/aws/credentials";
      AWS_WEB_IDENTITY_TOKEN_FILE = "${config.xdg.dataHome}/aws/token";
      AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.dataHome}/aws/shared-credentials";
    };
  };

  # Integrate AWS cli completions with ZSH
  programs.zsh.initContent = ''complete -C "$(command -v aws_completer)" aws'';
}
