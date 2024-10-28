{
  config,
  pkgs,
  ...
}:
{
  home = {
    sessionVariables = {
      CARGO_HOME = "${config.xdg.dataHome}/cargo";
      RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
      RUST_SRC_PATH = "${pkgs.fenix.complete.rust-src}/lib/rustlib/src/rust/library";
    };
    packages = with pkgs; [
      (pkgs.fenix.complete.withComponents [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ])
      rust-analyzer-nightly
      cargo-watch
      cargo-nextest
    ];

  };
}
