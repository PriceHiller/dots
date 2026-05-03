{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.runCommand "build-scss"
  {
    nativeBuildInputs = [ pkgs.dart-sass ];

  }
  ''
    sass --style expanded ${./.}/style.scss $out
  ''
