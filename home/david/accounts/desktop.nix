{
  pkgs,
  ...
}:
{
  accounts.email.accounts = {
    myEmail.thunderbird.enable = true;
    mainlining.thunderbird.enable = true;
  };

  programs.thunderbird = {
    enable = true;
    profiles."Default" = {
      isDefault = true;
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [ dictionary-german ];
      settings = {
        "datareporting.healthreport.uploadEnabled" = false;
        "extensions.autoDisableScopes" = 0;
        "intl.date_time.pattern_override.date_short" = "dd.MM.yyyy";
        "intl.date_time.pattern_override.time_short" = "HH:mm";
        "mail.compose.default_to_paragraph" = false;
        "mail.display_glyph" = false;
        "msgcompose.font_face" = "monospace";
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
