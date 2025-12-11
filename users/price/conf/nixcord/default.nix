{
  pkgs,
  lib,
  ...
}:
let
  # TODO: Integrate the below to use custom user plugins
  # in equibop
  mergeScript =
    pkgs.writeShellApplication {
      name = "merge-json";
      runtimeInputs = with pkgs; [
        jq
      ];
      text = ''
        merge_json() {
        	local file="$1"
        	local new_json="$2"

        	if [ -f "$file" ]; then
        		jq ". * $new_json" "$file" >tmp.json && mv tmp.json "$file"
        	else
        		echo "$new_json" | jq '.' >"$file"
        	fi
        }

        merge_json "$@"
      '';
    }
    |> lib.getExe;
  updatedState = builtins.toJSON {
    firstLaunch = false;
    equicordDir = pkgs.equicord.outPath;
  };
in
{
  home = {
    packages = [
      # Use until equibop is updated on Nixpkgs
      # WAITING: https://github.com/NixOS/nixpkgs/pull/456790
      (import (pkgs.fetchzip {
        url = "https://github.com/Rexcrazy804/nixpkgs/archive/update-equibop.tar.gz";
        hash = "sha256-QBcO3s4g5OzEWabTrWj/vqFzpAyYYKIrb7slViGbxp0=";
      }) { inherit (pkgs.stdenv.hostPlatform) system; }).equibop
    ];
  };
}
