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
    ./kate.nix
  ];

  options.hm-config.plasma = {
    enable = lib.mkEnableOption "David's Plasma configs" // {
      default = true;
    };
    nixIcon = lib.mkEnableOption "Nix icon for the application launcher" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with inputs.self.packages.${pkgs.stdenv.hostPlatform.system}; [
      firefox-focus-windows
      telegram-show-hide
    ];
    xdg = {
      enable = true;
      autostart = {
        enable = true;
        entries = with pkgs; [
          "${kdePackages.yakuake}/share/applications/org.kde.yakuake.desktop"
        ];
      };
    };
    programs = {
      firefox = {
        nativeMessagingHosts = with pkgs; [ kdePackages.plasma-browser-integration ];
        policies = {
          ExtensionSettings."plasma-browser-integration@kde.org" = {
            default_area = "menupanel";
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
            private_browsing = true;
          };
        };
      };
      plasma = {
        enable = true;
        overrideConfig = true;
        shortcuts = {
          kwin."Switch to Desktop 2" = "Ctrl+F2";
          yakuake.toggle-window-state = "Meta+Esc";
        };
        configFile = {
          yakuakerc = {
            Window = {
              Height = 100;
              KeepOpen = true;
              ShowTitleBar = false;
              Width = 100;
            };
            Appearance.HideSkinBorders = true;
            Dialogs.FirstRun = false;
            "Notification Messages".hinding_title_bar = false;
          };
          kcminputrc.Keyboard = {
            RepeatDelay = 300;
            RepeatRate = 80;
          };
          ksmserverrc.General.loginMode = "emptySession";
          kwinrc.Plugins = {
            telegram-show-hideEnabled = true;
            firefox-focus-windowsEnabled = true;
          };
        };
        panels = [
          {
            floating = false;
            location = "top";
            widgets = [
              {
                name = "org.kde.plasma.kickoff";
                config.General.icon = lib.mkIf cfg.nixIcon "nix-snowflake";
              }
              "org.kde.plasma.marginsseparator"
              "org.kde.plasma.pager"
              "org.kde.plasma.icontasks"
              "org.kde.plasma.marginsseparator"
              "org.kde.plasma.systemtray"
              {
                digitalClock = {
                  date.format = "isoDate";
                  time.format = "24h";
                };
              }
            ];
          }
        ];
        workspace = {
          theme = "breeze-dark";
          lookAndFeel = "org.kde.breezedark.desktop";
        };
      };
    };
  };
}
