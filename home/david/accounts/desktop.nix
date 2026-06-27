{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.hm-config;
in
{
  accounts.email.accounts = lib.mkIf cfg.trusted {
    myEmail.thunderbird.enable = true;
    mainlining.thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    languagePacks = [ "en-US" ];
    policies = {
      DisableTelemetry = true;
      ExtensionSettings = {
        "pl@dictionaries.addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/polish-spellchecker-dictionary/latest.xpi";
        };
        "de-DE@dictionaries.addons.mozilla.org" = {
          installation_mode = "force_installed";
          install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionary-german/latest.xpi";
        };
      };
    };
    profiles."Default" = {
      isDefault = true;
      settings = {
        "datareporting.healthreport.uploadEnabled" = false;
        "extensions.autoDisableScopes" = 0;
        "intl.date_time.pattern_override.date_short" = "dd.MM.yyyy";
        "intl.date_time.pattern_override.time_short" = "HH:mm";
        "mail.compose.default_to_paragraph" = false;
        "mail.display_glyph" = false;
        "msgcompose.font_face" = "monospace";
        "mail.compose.big_attachments.notify" = false;
      };
    };
  };

  xdg = {
    enable = true;
    autostart = {
      enable = true;
      entries = with pkgs; [
        "${thunderbird}/share/applications/thunderbird.desktop"
      ];
    };
  };
}
