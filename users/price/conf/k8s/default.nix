{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kind
    k9s
    kubectl
    helm
    helm-ls
    helm-docs
    helmfile
  ];
}
