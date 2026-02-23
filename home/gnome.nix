{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.gnome;
in
{
  options = {
    gnome.monitorID = lib.mkOption {
      type = lib.types.str;
      description = "Monitor ID for Dash-to-Panel.";
    };
  };
  config = {
    sops.secrets = {
      "rdp/password".mode = "0400";
      "rdp/tls-cert".mode = "0400";
      "rdp/tls-key".mode = "0400";
    };

    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "allowlockedremotedesktop@kamens.us"
          "appindicatorsupport@rgcjonas.gmail.com"
          "arcmenu@arcmenu.com"
          "dash-to-panel@jderose9.github.com"
          "gtk4-ding@smedius.gitlab.com"
          "lockkeys@vaina.lt"
        ];
        # Force empty list to enable all extensions
        disabled-extensions = lib.mkForce [ ];
        disable-user-extensions = false;

        favorite-apps = [
          "firefox.desktop"
          "startcenter.desktop"
          "org.gnome.Nautilus.desktop"
        ];

        # ArcMenu
        "extensions/arcmenu/custom-menu-button-icon" =
          "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
        "extensions/arcmenu/custom-menu-button-icon-size" = 36.0;
        "extensions/arcmenu/menu-button-icon" = "Custom_Icon";
        "extensions/arcmenu/menu-layout" = "Windows";
        "extensions/arcmenu/show-activities-button" = true;

        # Desktop Icons
        "extensions/gtk4-ding/show-home" = true;
        "extensions/gtk4-ding/show-trash" = true;
        "extensions/gtk4-ding/show-volumes" = true;

        # Lock Keys
        "extensions/lockkeys/capslock-indicator" = "when-active";
        "extensions/lockkeys/capslock-notification" = "osd";
        "extensions/lockkeys/numlock-indicator" = "never";
        "extensions/lockkeys/numlock-notification" = "osd";

        # Dash to Panel
        "extensions/dash-to-panel/animate-appicon-hover" = true;
        "extensions/dash-to-panel/dot-color-dominant" = true;
        "extensions/dash-to-panel/hide-overview-on-startup" = true;
        "extensions/dash-to-panel/scroll-icon-action" = "NOTHING";
        "extensions/dash-to-panel/scroll-panel-action" = "NOTHING";
        "extensions/dash-to-panel/trans-dynamic-behavior" = "ALL_WINDOWS";
        "extensions/dash-to-panel/trans-panel-opacity" = 0.6;
        "extensions/dash-to-panel/trans-use-custom-opacity" = true;
        "extensions/dash-to-panel/trans-use-dynamic-opacity" = true;
        "extensions/dash-to-panel/panel-element-positions" = ''
          {
            "${cfg.monitorID}": [
              {
                "element": "leftBox",
                "visible": true,
                "position": "stackedTL"
              },
              {
                "element": "activitiesButton",
                "visible": true,
                "position": "stackedTL"
              },
              {
                "element": "showAppsButton",
                "visible": true,
                "position": "centerMonitor"
              },
              {
                "element": "taskbar",
                "visible": true,
                "position": "centerMonitor"
              },
              {
                "element": "centerBox",
                "visible": true,
                "position": "stackedBR"
              },
              {
                "element": "rightBox",
                "visible": true,
                "position": "stackedBR"
              },
              {
                "element": "dateMenu",
                "visible": true,
                "position": "stackedBR"
              },
              {
                "element": "systemMenu",
                "visible": true,
                "position": "stackedBR"
              },
              {
                "element": "desktopButton",
                "visible": true,
                "position": "stackedBR"
              }
            ]
          }
        '';
      };

      "org/gnome/desktop" = {
        "input-sources/xkb-options" = [ "compose:rctrl" ];
        "interface/enable-hot-corners" = false;
        "interface/show-battery-percentage" = true;
        "remote-desktop/rdp/enable" = true;
        "remote-desktop/rdp/tls-cert" = config.sops.secrets."rdp/tls-cert".path;
        "remote-desktop/rdp/tls-key" = config.sops.secrets."rdp/tls-key".path;
        "remote-desktop/rdp/view-only" = false;
        "screensaver/lock-enabled" = false;
        "wm/preferences/button-layout" = "appmenu:minimize,maximize,close";
      };

      "org/gnome/settings-daemon" = {
        "plugins/media-keys/control-center" = [ "<Super>i" ];
        "plugins/media-keys/custom-keybindings/custom0/binding" = "<Control><Alt>t";
        "plugins/media-keys/custom-keybindings/custom0/command" = "kgx";
        "plugins/media-keys/custom-keybindings/custom0/name" = "Terminal";
        "plugins/media-keys/custom-keybindings" = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
        "plugins/media-keys/home" = [ "<Super>e" ];
      };
    };

    systemd.user.services = {
      gnome-remote-desktop-password = {
        Unit = {
          Description = "Set GNOME remote desktop password";
          After = [
            "sops-nix.service"
            "gnome-session.target"
          ];
        };
        Service = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "grdctl-set-pass" ''
            GRD_PASS=$(cat ${config.sops.secrets."rdp/password".path})
            ${lib.getExe pkgs.gnome-remote-desktop} rdp set-credentials ${config.home.username} $GRD_PASS
          '';
        };
        Install.WantedBy = [ "default.target" ];
      };
    };

    home.packages =
      with inputs.gnome.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gnomeExtensions; [
        allow-locked-remote-desktop
        appindicator
        arcmenu
        dash-to-panel
        gtk4-desktop-icons-ng-ding
        lock-keys-2
      ];
  };
}
