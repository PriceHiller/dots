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
      #  HACK: Specify openssl info for rust, this is really not a good idea, but it saves me from
      #  writing per-project shell.nix or `nix-shell -p` nonsense. I'm willing to compromise for my
      #  laziness.
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
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
      sccache
    ];
    file = {
      # NOTE: This improves the rust edit-build-run cycle. See https://davidlattimore.github.io/posts/2024/02/04/speeding-up-the-rust-edit-build-run-cycle.html
      "${config.home.sessionVariables.CARGO_HOME}/config.toml".text = ''
        [build]
        rustflags = [ "-C", "linker=${pkgs.clang}/bin/clang", "-C", "link-arg=--ld-path=${pkgs.mold-wrapped}/bin/mold" ]

        [profile.dev]
        split-debuginfo = "unpacked"
      '';
    };
  };
}
