{
  pkgs,
  lib,
  ...
}:
{
  systemd.user =
    let
      svc-orgmode-name = "nvim-orgmode-notify";
    in
    {
      timers.${svc-orgmode-name} = {
        Unit = {
          Description = "Launch nvim orgmode notification service";
        };
        Timer = {
          Unit = "${svc-orgmode-name}.service";
          AccuracySec = "1s";
          OnCalendar = "*:*:00";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
      services.${svc-orgmode-name} = {
        Unit = {
          Description = "Display Nvim Orgmode Notifications via `notify-send`";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = ''${pkgs.neovim}/bin/nvim --headless -c 'lua require("orgmode").cron()' '';
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
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
    packages = with pkgs; [
      neovide
      bun
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
      bashdb
      vscode-extensions.vadimcn.vscode-lldb.adapter
      bash-language-server
      shfmt
      texlab
      ansible-language-server
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
      taplo
      kotlin-language-server
      powershell-editor-services
      sql-formatter
      tflint
      prettierd
      nginx-language-server
      asmfmt
      asm-lsp
      sqlfluff
      google-java-format
      stylua
      lua-language-server
      typstyle
      cmake-format
      cmake-language-server
    ];
  };
  xdg.mimeApps.defaultApplications = {
    "text/plain" = [ "neovide.desktop" ];
    "inode/directory" = [ "neovide.desktop" ];
  };
}
