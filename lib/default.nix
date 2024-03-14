# Some of these functions were taken from https://github.com/NixOS/nixpkgs/blob/master/lib/
{ lib ? (import <nixpkgs> { }).lib }:
rec {
  hasSuffix =
    suffix:
    string:
    let
      lenSuffix = builtins.stringLength suffix;
      lenString = builtins.stringLength string;
    in
    (
      lenString >= lenSuffix && (builtins.substring (lenString - lenSuffix) lenString string) == suffix
    );
  recurseDir = dir:
    let
      dirContents = builtins.readDir dir;
    in
    (builtins.concatMap
      (dirItem:
        let
          itemType = builtins.getAttr dirItem dirContents;
          itemPath = dir + "/${dirItem}";
        in
        if itemType == "directory" then
          (recurseDir itemPath)
        else
          [ itemPath ])
      (builtins.attrNames dirContents));
  recurseFilesInDir = dir: suffix:
    (builtins.filter (file: hasSuffix "${suffix}" file) (recurseDir dir));
  recurseFilesInDirs = dirs: suffix:
    (builtins.concatMap (dir: (recurseFilesInDir dir "${suffix}")) dirs);
  # Full credit to https://stackoverflow.com/questions/54504685/nix-function-to-merge-attributes-records-recursively-and-concatenate-arrays/54505212#54505212
  recursiveMerge = attrList:
    let
      f = attrPath:
        lib.zipAttrsWith (n: values:
          if lib.tail values == [ ]
          then lib.head values
          else if lib.all builtins.isList values
          then lib.unique (lib.concatLists values)
          else if lib.all builtins.isAttrs values
          then f (attrPath ++ [ n ]) values
          else lib.last values
        );
    in
    f [ ] attrList;
}
