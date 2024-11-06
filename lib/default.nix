# Some of these functions were taken from https://github.com/NixOS/nixpkgs/blob/master/lib/
{
  lib ? (import <nixpkgs> { }).lib,
}:
rec {
  recurseDir =
    dir:
    builtins.readDir dir
    |> lib.attrsets.mapAttrs' (
      fEntry: fType: lib.attrsets.nameValuePair (builtins.toString (dir + "/${fEntry}")) fType
    )
    |> lib.attrsets.mapAttrsToList (
      fEntry: fType: if fType == "directory" then (recurseDir "${fEntry}") else "${fEntry}"
    )
    |> lib.lists.flatten;
  recurseFilesInDir =
    dir: suffix: (builtins.filter (file: lib.strings.hasSuffix "${suffix}" file) (recurseDir dir));
  recurseFilesInDirs =
    dirs: suffix: (builtins.concatMap (dir: (recurseFilesInDir dir "${suffix}")) dirs);
  # Full credit to https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/54505212#54505212
  recursiveMerge =
    attrList:
    let
      f =
        attrPath:
        lib.zipAttrsWith (
          n: values:
          if lib.tail values == [ ] then
            lib.head values
          else if lib.all builtins.isList values then
            lib.unique (lib.concatLists values)
          else if lib.all builtins.isAttrs values then
            f (attrPath ++ [ n ]) values
          else
            lib.last values
        );
    in
    f [ ] attrList;
}
