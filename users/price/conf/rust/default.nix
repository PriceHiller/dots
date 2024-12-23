{
  config,
  pkgs,
  osConfig,
  ...
}:
let
  sccacheWrapped =
    if osConfig.services.memcached.enable then
      pkgs.symlinkJoin {
        name = "sccache";
        paths = [ pkgs.sccache ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/sccache \
            --set SCCACHE_MEMCACHED_KEY_PREFIX "SCCACHE" \
            --set SCCACHE_MEMCACHED_ENDPOINT "tcp://${builtins.toString osConfig.services.memcached.listen}:${builtins.toString osConfig.services.memcached.port}"
        '';
      }
    else
      # Symlinking this ensures that sccache can properly create temporary directories.
      # This is because Nix wants to cause every sccache invocation to sandbox the build, by
      # symlinking sccache instead, we can avoid the sandbox to some degree.
      pkgs.symlinkJoin {
        name = "sccache";
        paths = [ pkgs.sccache ];
      };
in
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
      sccacheWrapped
    ];
    file = {
      # NOTE: This improves the rust edit-build-run cycle. See https://davidlattimore.github.io/posts/2024/02/04/speeding-up-the-rust-edit-build-run-cycle.html
      "${config.home.sessionVariables.CARGO_HOME}/config.toml".text = ''
        [build]
        rustc-wrapper = "${sccacheWrapped}/bin/sccache"
        rustflags = [ "-C", "linker=${pkgs.clang}/bin/clang", "-C", "link-arg=--ld-path=${pkgs.mold-wrapped}/bin/mold" ]

        [profile.dev]
        split-debuginfo = "unpacked"
      '';
    };
  };
}
