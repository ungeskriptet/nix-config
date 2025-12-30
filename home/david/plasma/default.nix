{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.hm-config.plasma;
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  options.hm-config.plasma.enable = lib.mkEnableOption "David's Plasma configs" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      autostart = {
        enable = true;
        entries = with pkgs; [
          "${kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
        ];
      };
    };
    programs.plasma = {
      enable = true;
      shortcuts = {
        yakuake.toggle-window-state = "Meta+Esc";
      };
      configFile = {
        yakuakerc = {
          Window = {
            Height = 100;
            ShowTitleBar = false;
            Width = 100;
          };
          Dialogs.FirstRun = false;
          "Notification Messages".hinding_title_bar = false;
        };
      };
    };
  };
}
