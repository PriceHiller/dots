{ agenix ? true, lib ? import ../lib { } }:
let
  keys = [
    "age1yubikey1qfnj0k4mkzrn8ef5llwh2sv6hd7ckr0qml3n9hzdpz9c59ypvryhyst87k0"
    "age1ur2lr3z6d2eftgxcalc6s5x9840ew9x43upl9k23wg0ugacrn5as4zl6sj"
  ];
  secrets = let dir = "files";
  in {
  };
in if agenix then
  (builtins.listToAttrs (builtins.concatMap (secretName: [{
    name = builtins.toString secretName;
    value.publicKeys = keys;
  }]) (builtins.attrNames secrets)))
else
  (lib.recursiveMerge (builtins.map (secretName: {
    age.secrets.${secretName}.file = ./${secrets.${secretName}};
  }) (builtins.attrNames secrets)))
