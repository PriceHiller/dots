{ pkgs, config, ... }:
let
  AWS-CacheHome = "${config.xdg.cacheHome}/aws";
  AWS-DataHome = "${config.xdg.dataHome}/aws";
in
{
  link."${AWS-DataHome}/shared-credentials".source = builtins.trace config.age.secrets config.age.secrets.hm-price-aws.path;
  home = {
    packages = [
      (pkgs.symlinkJoin {
        name = "aws";
        paths = [ pkgs.awscli2 ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/aws" \
            --set 'HOME' '${AWS-CacheHome}'
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
  xdg.configFile."aws/config".text = ''
    [default]
    role_arn=arn:aws:iam::762233728178:role/Admin
    source_profile=default
  '';

  # Integrate AWS cli completions with ZSH
  programs.zsh.initContent = ''complete -C "$(command -v aws_completer)" aws'';
}
