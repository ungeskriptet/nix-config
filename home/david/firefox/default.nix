{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
{
  programs = {
    firefox = {
      enable = true;
      languagePacks = [
        "en-US"
        "de"
        "pl"
      ];
      profiles.nix = {
        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            darkreader
            dictionary-german
            ipvfoo
            plasma-integration
            polish-dictionary
            sponsorblock
            ublock-origin
          ];
        };
        search = import ./search { inherit lib pkgs; };
        settings = import ./settings.nix;
      };
      policies = import ./policies.nix;
    };
  };
}
