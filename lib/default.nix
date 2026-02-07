# Some of these functions were taken from https://github.com/NixOS/nixpkgs/blob/master/lib/
{
  lib ? (import <nixpkgs> { }).lib,
}:
rec {
  dirsIn =
    dir:
    builtins.readDir dir
    |> lib.attrsets.filterAttrs (_: fType: fType == "directory")
    |> lib.attrsets.mapAttrsToList (fEntry: _: dir + "/${fEntry}");
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
  # Converts an attr path to the string representation of that path
  #   {
  #     hello = { world = true; };
  #     goodbye = { moon = "bye"; }
  #   }
  #     Becomes
  #   {
  #     "hello.world" = true;
  #     "goodbye.moon" = "bye";
  #   }
  #     Works for arbitrarily nested attrsets
  attrsToStringPath =
    attrs:
    let
      _attrsToStringPath =
        _parent:
        let
          parent = if isNull _parent then "" else "${_parent}.";
        in
        attrs:
        lib.attrsets.foldlAttrs (
          acc: _name:
          let
            name = "${parent}${_name}";
          in
          value:
          acc // (if builtins.isAttrs value then _attrsToStringPath name value else { "${name}" = value; })
        ) { } attrs;
    in
    _attrsToStringPath null attrs;

  # Converts attrs for mozilla programs (Firefox/Librewolf/Thunderbird) to correct format
  # for prefences (like in about:config)
  attrsToMozillaPref =
    let
      nixValToMozillaPref =
        val:
        if builtins.isList val then
          "[${val |> builtins.map (item: ''"${item}"'') |> lib.strings.concatStringsSep ","}]"
        else
          val;
    in
    attrs: builtins.mapAttrs (_: val: nixValToMozillaPref val) <| (attrsToStringPath attrs);

  kcolors = (import ./kanagawa-colors.nix);

  pow =
    base: exponent:
    if exponent > 0 then
      let
        and1 = x: (x / 2) * 2 != x;
        x = pow base (exponent / 2);
      in
      assert and1 0 == false;
      assert and1 1 == true;
      assert and1 2 == false;
      assert and1 3 == true;
      x * x * (if and1 exponent then base else 1)
    else if exponent == 0 then
      1
    else
      throw "undefined";

  # Extract mimetypes from a package's desktop file if they exist
  getMimeDefaults =
    package: desktopFileName:
    let
      desktopPath = "${package}/share/applications/${desktopFileName}";

      mimeTypes =
        (lib.strings.optionalString (builtins.pathExists desktopPath) (builtins.readFile desktopPath))
        |> (lib.strings.splitString "\n")
        |> (lib.lists.findFirst (line: lib.strings.hasPrefix "MimeType=" line) "")
        |> (lib.strings.removePrefix "MimeType=")
        |> (lib.strings.splitString ";")
        # Filter out empty strings caused by trailing semicolons
        |> (builtins.filter (s: s != ""));
    in
    mimeTypes
    |> builtins.map (type: {
      name = type;
      value = [ desktopFileName ];
    })
    |> builtins.listToAttrs;
}
