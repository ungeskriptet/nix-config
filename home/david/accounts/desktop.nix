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
      settings = {
        "datareporting.healthreport.uploadEnabled" = false;
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
