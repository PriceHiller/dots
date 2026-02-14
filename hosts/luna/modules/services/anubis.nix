# This file is only specifying the defaults for all Anubis instances -- see
# individual services for their actual anubis per-instance configurations
{ ... }:
{
  services.anubis.defaultOptions = {
    settings = {
      WEBMASTER_EMAIL = "anubis.webmaster@pricehiller.com";
      SERVE_ROBOTS_TXT = true;
      DIFFICULTY = 6;
    };
    policy = {
      useDefaultBotRules = true;
    };
  };
}
