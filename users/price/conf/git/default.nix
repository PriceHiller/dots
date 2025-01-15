{ ... }:
{

  programs.git = {
    enable = true;
    userName = "Price Hiller";
    userEmail = "price@price-hiller.com";
    aliases = {
      unstage = "reset HEAD --";
    };
    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      branch.autosetupmerge = "always";
      remote.pushDefault = "origin";
      am.threeWay = true;
      apply.ignoreWhitespace = "change";
      # SEC: Integrate https://github.com/git-ecosystem/git-credential-manager with GPG to improve
      # security stance around the credential store
      credential.helper = "store";
      pull.rebase = true;
      commit.gpgsign = true;
      transfer.fsckObjects = true;
      receive.fsckObjects = true;
      status.submoduleSummary = true;
      submodule.recurse = true;
      fetch = {
        fsckObjects = true;
        prune = true;
        prunetags = true;
      };
      rebase = {
        autosquash = true;
        autostash = true;
        updateRefs = true;
      };
      log = {
        abbrevCommit = true;
        decorate = "short";
        date = "iso";
      };
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      core = {
        ignorecase = false;
        quotePath = false;
      };
      diff = {
        colorMoved = "default";
        submodule = "log";
        tool = "nvimdiff";
      };
      push = {
        autoSetupRemote = true;
        default = "current";
      };
    };
    signing = {
      signByDefault = true;
      key = null;
    };
    delta = {
      enable = true;
      options = {
        navigate = true;
        features = "interactive decorations";
        interactive = {
          keep-plus-minus-markers = false;
        };
        decorations = {
          commit-decoration-style = "bold box ul";
          dark = true;
          file-style = "omit";
          hunk-header-decoration-style = ''"#022b45" box ul'';
          hunk-header-file-style = ''"#999999"'';
          hunk-header-style = "file line-number syntax";
          line-numbers = true;
          line-numbers-left-style = ''"#022b45"'';
          minus-emph-style = ''normal "#80002a"'';
          minus-style = ''normal "#330011"'';
          plus-emph-style = ''syntax "#003300"'';
          plus-style = ''syntax "#001a00"'';
          syntax-theme = "Solarized (dark)";
        };
      };
    };
  };
}
