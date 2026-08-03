{ lib, ... }:

let
  rulesDir = ./rules;
  stripExt = name: name |> lib.removeSuffix ".rules" |> lib.removeSuffix ".js";
in
{
  ext.polkit.rules =
    rulesDir
    |> lib.filesystem.listFilesRecursive
    |> builtins.filter (
      p:
      let
        fname = (baseNameOf (toString p));
      in
      (lib.hasSuffix ".rules" fname) || (lib.hasSuffix ".js" fname)
    )
    |> map (p: lib.nameValuePair (stripExt (baseNameOf (toString p))) (builtins.readFile p))
    |> lib.listToAttrs;

  security.polkit = {
    enable = true;
    settings = {
      # See `man 5 polkitd.conf`
      # https://man.archlinux.org/man/polkitd.conf.5.en
      Polkitd = {
        # Increase default expiration time for polkit auth
        ExprationSeconds = 60 * 60;
      };

    };
  };
}
