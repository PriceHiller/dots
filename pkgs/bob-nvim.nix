{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "bob";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "MordechaiHadad";
    repo = "bob";
    rev = "v${version}";
    hash = "sha256-Op/NXWssylgAOb1BccSOz7JqXFranzAsGICFMF3o/K8=";
  };
  cargoLock.lockFile = "${src}/Cargo.lock";
}
