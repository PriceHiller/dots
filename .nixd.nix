{
  formatting = { command = "nixfmt"; };
  options = {
    enable = true;
    target = {
      args = [ ];
      installable = ".#homeConfigurations.sam";
    };
  };
}