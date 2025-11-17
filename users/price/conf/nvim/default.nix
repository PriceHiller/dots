{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    extraWrapperArgs = [
      "--suffix"
      "LD_LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        pkgs.sqlite
      ]}"
      "--suffix"
      "LIBRARY_PATH"
      ":"
      "${lib.makeLibraryPath [
        pkgs.stdenv.cc.cc
        pkgs.zlib
      ]}"
      "--suffix"
      "PKG_CONFIG_PATH"
      ":"
      "${lib.makeSearchPathOutput "dev" "lib/pkgconfig" [
        pkgs.stdenv.cc.cc
        pkgs.zlib
      ]}"
      "--suffix"
      "LUA_PATH"
      ":"
      "?;?.lua"
    ];
  };
  home = {
    sessionVariables = {
      NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE = 1;
    };
    packages = with pkgs; [
      neovide
      bun
      flutter
      jdk
      nil
      sqlfluff
      ast-grep
      ripgrep
      fd
      fzf
      oxlint
      ruff
      typescript
      vue-language-server
      typescript-language-server
      vscode-extensions.vadimcn.vscode-lldb.adapter
      inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.bashdb
      bash-language-server
      shfmt
      texlab
      ansible-lint
      csharp-ls
      gopls
      vscode-langservers-extracted
      docker-language-server
      docker-compose-language-service
      hadolint
      terraform-ls
      jdt-language-server
      yaml-language-server
      tinymist
      vim-language-server
      kotlin-language-server
      powershell-editor-services
      sql-formatter
      tflint
      prettierd
      superhtml
      nginx-language-server
      asmfmt
      asm-lsp
      sqlfluff
      google-java-format
      stylua
      lua-language-server
      typstyle
      live-server
      cmake-format
      cmake-language-server
      tombi
      markdownlint-cli
      php
      phpactor
      phpPackages.php-cs-fixer
      phpPackages.psalm
      phpPackages.phpstan
      actionlint
      netcoredbg
    ];
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "neovide.desktop" ];
    "inode/directory" = [ "neovide.desktop" ];
  };
}
