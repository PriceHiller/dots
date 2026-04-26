{
  writeShellApplication,
  stylua,
  gnugrep,
  nixfmt,
  shfmt,
  ...
}:
writeShellApplication {
  name = "Fmt";
  runtimeInputs = [
    stylua
    gnugrep
    nixfmt
    shfmt
  ];
  text = builtins.readFile ./fmt.bash;
}
