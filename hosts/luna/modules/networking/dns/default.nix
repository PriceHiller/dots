{
  config,
  ...
}:
{
  ext.dns = {
    enable = true;
    doh = {
      privateKey = config.age.secrets.pki-local-key.path;
      publicKey = ./localhost.crt;
    };
  };
}
