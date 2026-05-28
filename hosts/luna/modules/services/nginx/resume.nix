{
  inputs,
  pkgs,
  ...
}:
{
  services = {
    nginx.virtualHosts = {
      "resume.pricehiller.com" = {
        forceSSL = true;
        locations."/" = {
          root = inputs.resume.packages.${pkgs.stdenv.hostPlatform.system}.default;
          extraConfig =
            let
              docName = "resume.pdf";
            in
            # nginx
            ''
              rewrite ^ /${docName} break;
              add_header Content-Disposition "attachment; filename=\"${docName}\"";
              default_type application/pdf;
            '';
        };
      };
    };
  };
}
