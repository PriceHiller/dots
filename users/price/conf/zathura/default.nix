{ pkgs, ... }:
{
  home.packages = [
    (pkgs.zathura.override {
      useMupdf = true;
    })
  ];
  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [
      "org.pwmt.zathura.desktop"
    ];
  };
}
