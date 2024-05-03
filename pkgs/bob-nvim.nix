{ rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "bob";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "MordechaiHadad";
    repo = "bob";
    rev = "v${version}";
    hash = "sha256-jVRxvhUENyucRHN4TGV9xsWOs7mfPJCV90Lk/hD1xFE=";
  };
  cargoLock.lockFile = "${src}/Cargo.lock";
}
