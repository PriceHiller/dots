{
  config,
  ...
}:
{
  ext.dns = {
    enable = true;
    doh = {
      privateKey = config.age.secrets.ca-cert.path;
      publicKey = ./localhost.pem;
    };
  };
}