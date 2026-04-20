{ pkgs, ... }:
{
  home.packages = [
    (pkgs.mkBwrapper {
      app.package = pkgs.spotify;
      imports = [
        pkgs.bwrapperPresets.desktop
      ];
      flatpak.manifestFile = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/flathub/com.spotify.Client/23a1c107d11bdfed6a66fa009e41c71003acd99c/com.spotify.Client.json";
        hash = "sha256-ULCoj/s+vZC6pLip1wgLmcv5naE+pCrZOoekFSeR5jM=";
      };
      mounts = {
        readWrite = [
          "$XDG_CACHE_HOME/spotify"
          "$XDG_CONFIG_HOME/spotify"
        ];
      };
    })
  ];
}
