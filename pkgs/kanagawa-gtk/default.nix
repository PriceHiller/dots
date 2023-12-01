{ lib, stdenvNoCC, fetchFromGitHub, gnome-themes-extra, gtk-engine-murrine }:

stdenvNoCC.mkDerivation {
  pname = "kanagawa-gtk-theme";
  version = "unstable-2023-11-30";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Kanagawa-GKT-Theme";
    rev = "35936a1e3bbd329339991b29725fc1f67f192c1e";
    hash = "sha256-BZRmjVas8q6zsYbXFk4bCk5Ec/3liy9PQ8fqFGHAXe0=";
  };

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  buildInputs = [ gnome-themes-extra ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes/{Kanagawa-Border,Kanagawa-Borderless}
    mkdir -p $out/share/icons
    sed -e 's/oomox-//' -i icons/*/index.theme
    cp -r icons/Kanagawa $out/share/icons
    cp -r themes/Kanagawa-B/* $out/share/themes/Kanagawa-Border
    cp -r themes/Kanagawa-BL/* $out/share/themes/Kanagawa-Borderless
    runHook postInstall
  '';
}
