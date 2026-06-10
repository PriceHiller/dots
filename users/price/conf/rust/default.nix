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
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustcSrc}";
      OPENSSL_DIR = "${pkgs.openssl.dev}";
      OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      SCCACHE_SERVER_UDS = "${config.xdg.stateHome}/sccache.sock";
      SCCACHE_CACHE_SIZE = "40G";
    };
    packages = with pkgs; [
      rustc
      cargo
      clippy
      rustfmt
      rust-analyzer
      cargo-audit
      cargo-deny
      cargo-watch
      cargo-nextest
      sccache
    ];
    file = {
      # NOTE: This improves the rust edit-build-run cycle. See https://davidlattimore.github.io/posts/2024/02/04/speeding-up-the-rust-edit-build-run-cycle.html
      "${config.home.sessionVariables.CARGO_HOME}/config.toml".text = ''
        [build]
        rustc-wrapper = "${pkgs.sccache}/bin/sccache"
        rustflags = [ "-C", "linker=${pkgs.clang}/bin/clang", "-C", "link-arg=--ld-path=${pkgs.mold}/bin/mold" ]

        [profile.dev]
        split-debuginfo = "unpacked"
      '';
    };
  };
}
