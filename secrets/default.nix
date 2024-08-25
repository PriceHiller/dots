{
  agenix ? false,
  clib ? import ../clib { },
}:
let
  masterKeys = [
    "age1yubikey1qfnj0k4mkzrn8ef5llwh2sv6hd7ckr0qml3n9hzdpz9c59ypvryhyst87k0"
    "age1ur2lr3z6d2eftgxcalc6s5x9840ew9x43upl9k23wg0ugacrn5as4zl6sj"
  ];
  hosts = {
    luna =
      let
        secrets = "hosts/luna";
      in
      {
        users-root-pw = "${secrets}/users-root-pw.age";
        users-price-pw = "${secrets}/users-price-pw.age";
        lakewatch-db-pass = "${secrets}/lakewatch-db-pass.age";
        gitea-db-pass = "${secrets}/gitea-db-pass.age";
        gitea-runner-token = "${secrets}/gitea-runner-token.age";
        gh-ts-autotag-runner-token = "${secrets}/gh-ts-autotag-runner-token.age";
      };
    orion =
      let
        secrets = "hosts/orion";
      in
      {
        users-root-pw = "${secrets}/users-root-pw.age";
        users-price-pw = "${secrets}/users-price-pw.age";
      };
  };
in
if agenix then
  (builtins.listToAttrs (
    builtins.concatMap (
      host:
      let
        hostSecrets = (builtins.getAttr host hosts);
      in
      (builtins.map (
        hostSecretName:
        let
          secret = (builtins.getAttr hostSecretName hostSecrets);
        in
        {
          name = builtins.toString secret;
          value = {
            publicKeys = [ (import ./../hosts/${host}/pubkey.nix) ] ++ masterKeys;
          };
        }
      ) (builtins.attrNames hostSecrets))
    ) (builtins.attrNames hosts)
  ))
else
  (builtins.mapAttrs (
    host: secrets:
    (clib.recursiveMerge (
      builtins.map (secretName: { age.secrets.${secretName}.file = ./${secrets.${secretName}}; }) (
        builtins.attrNames hosts.${host}
      )
    ))
  ) hosts)
