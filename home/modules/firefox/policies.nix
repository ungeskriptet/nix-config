{ lib, config, ... }:
let
  cfg = config.nix-config.firefox;
in
{
  programs = {
    firefox.policies = lib.mkMerge [
      {
        # keep-sorted start block=yes
        AIControls = {
          Default.Value = "blocked";
          Translations = {
            Value = "available";
            Locked = false;
          };
        };
        AutofillAddressEnabled = false;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        ExtensionSettings = {
          # keep-sorted start block=yes case=no
          "de-DE@dictionaries.addons.mozilla.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/dictionary-german/latest.xpi";
          };
          "pl@dictionaries.addons.mozilla.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/polish-spellchecker-dictionary/latest.xpi";
          };
          "sponsorBlocker@ajay.app" = {
            default_area = "menupanel";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            private_browsing = true;
          };
          "uBlock0@raymondhill.net" = {
            default_area = "navbar";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            private_browsing = true;
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            default_area = "navbar";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            private_browsing = true;
          };
          # keep-sorted end
        };
        FirefoxHome = {
          Highlights = false;
          Pocket = false;
          Snippets = false;
          SponsoredPocket = false;
          SponsoredStories = false;
          SponsoredTopSites = false;
          Stories = false;
          TopSites = false;
          Weather = false;
        };
        FirefoxSuggest = {
          SponsoredSuggestions = false;
          ImproveSuggest = false;
        };
        NoDefaultBookmarks = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        RequestedLocales = [ cfg.language ];
        # keep-sorted end
      }
      (lib.mkIf (cfg.preset == "david") {
        # keep-sorted start block=yes
        AIControls.Default.Locked = true;
        ExtensionSettings = {
          # keep-sorted start block=yes case=no
          "addon@darkreader.org" = {
            default_area = "navbar";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            private_browsing = true;
          };
          "insensitivex@orca.pet" = {
            default_area = "menupanel";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/insensitivex/latest.xpi";
            private_browsing = true;
          };
          "ipvfoo@pmarks.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ipvfoo/latest.xpi";
            private_browsing = true;
          };
          "V3-eov3cv@hotmail.com" = {
            default_area = "menupanel";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/v3-get-old-youtube-layout/latest.xpi";
            private_browsing = true;
          };
          "{08ed11c3-efeb-4275-8887-5b1fc9dfc183}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/terrakok-fuzzytabs/latest.xpi";
            private_browsing = true;
          };
          # keep-sorted end
        };
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        # keep-sorted end
      })
    ];
  };
}
