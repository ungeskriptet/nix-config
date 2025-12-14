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
        "mail.display_glyph" = false;
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
