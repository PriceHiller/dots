# nix-bwrapper module that neutralises the EXIT clause in the wrapper's cleanup
# trap.  The upstream trap fires `kill -- -$$` on EXIT, which kills the wrapper
# shell with SIGTERM and produces exit code 143 instead of propagating the real
# exit code from the sandboxed process.  All background processes launched by
# nix-bwrapper (dbus proxy, xwayland satellite) already use
# `bwrap --die-with-parent`, so the kernel cleans them up via
# prctl(PR_SET_PDEATHSIG) when the wrapper exits — the EXIT clause is redundant.
#
# The file is callPackage-compatible so that packagesFromDirectoryRecursive
# exposes it as pkgs.bwrapped.presets.fixExitTrap.  The returned attrset is a
# valid NixOS module (shorthand config form) and can be used directly in a
# mkBwrapper imports list:
#
#   pkgs.mkBwrapper {
#     imports = [ pkgs.bwrapperPresets.devshell pkgs.bwrapped.presets.fixExitTrap ];
#     ...
#   };
{ ... }:
{
  config = {
    script.preCmds.stage4 = ''
      trap - EXIT
    '';
  };
}
