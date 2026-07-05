{ lib, config, ... }:
{
  programs.firefox.policies = {
    # keep-sorted start block=yes
    AIControls = {
      Default = {
        Value = "blocked";
        Locked = true;
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
      "addon@darkreader.org" = {
        default_area = "navbar";
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        private_browsing = true;
      };
      "de-DE@dictionaries.addons.mozilla.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/dictionary-german/latest.xpi";
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
      "pl@dictionaries.addons.mozilla.org" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/polish-spellchecker-dictionary/latest.xpi";
      };
      "plasma-browser-integration@kde.org" = lib.mkIf config.hm-config.plasma.enable {
        default_area = "menupanel";
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
        private_browsing = true;
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
    OfferToSaveLogins = false;
    OverrideFirstRunPage = "";
    OverridePostUpdatePage = "";
    PasswordManagerEnabled = false;
    # keep-sorted end
  };
}
