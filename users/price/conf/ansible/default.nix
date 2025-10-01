{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      ansible
      ansible-lint
    ];
    sessionVariables = {
      ANSIBLE_HOME = "${config.xdg.dataHome}/ansible";
      ANSIBLE_CONFIG = "${config.xdg.configHome}/ansible.cfg";
      ANSIBLE_GALAXY_CACHE_DIR = "${config.xdg.cacheHome}/ansible/galaxy_cache";
    };
  };
}
