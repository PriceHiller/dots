{ pkgs, ... }:
{
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-file ]);
    settings = {
      PASSWORD_STORE_KEY = "C3FADDE7A8534BEB";
    };
  };
}
