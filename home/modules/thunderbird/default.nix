{ lib, config, ... }:
let
  cfg = config.nix-config.thunderbird;
in
{
  options.nix-config.thunderbird = {
    preset = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "default"
          "david"
        ]
      );
      description = "Preset to use for the Thunderbird configuration";
      default = null;
    };
    language = lib.mkOption {
      type = lib.types.str;
      description = "Thunderbird Language";
    };
    defaultProfile = lib.mkOption {
      type = lib.types.str;
      description = "Default Firefox profile";
      readOnly = true;
    };
  };
  config = lib.mkIf (cfg.preset != null) (
    lib.mkMerge [
      {
        nix-config.thunderbird.defaultProfile = "nix";
        programs.thunderbird = {
          enable = true;
          languagePacks = [ cfg.language ];
          policies = {
            # keep-sorted start block=yes
            DisableTelemetry = true;
            ExtensionSettings = {
              # keep-sorted start block=yes case=no
              "de-DE@dictionaries.addons.mozilla.org" = {
                installation_mode = "force_installed";
                install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/dictionary-german/latest.xpi";
              };
              "pl@dictionaries.addons.mozilla.org" = {
                installation_mode = "force_installed";
                install_url = "https://addons.thunderbird.net/thunderbird/downloads/latest/polish-spellchecker-dictionary/latest.xpi";
              };
              # keep-sorted end
            };
            RequestedLocales = lib.mkForce [ cfg.language ];
            # keep-sorted end
          };
          profiles.${cfg.defaultProfile} = {
            isDefault = true;
            settings = {
              # keep-sorted start block=yes
              "datareporting.healthreport.uploadEnabled" = false;
              "extensions.autoDisableScopes" = 0;
              "intl.date_time.pattern_override.date_short" = "dd.MM.yyyy";
              "intl.date_time.pattern_override.time_short" = "HH:mm";
              "mail.shell.checkDefaultClient" = false;
              # keep-sorted end
            };
          };
        };
      }
      (lib.mkIf (cfg.preset == "david") {
        programs.thunderbird = {
          profiles.${cfg.defaultProfile} = {
            settings = {
              # keep-sorted start block=yes
              "mail.compose.big_attachments.notify" = false;
              "mail.compose.default_to_paragraph" = false;
              "mail.display_glyph" = false;
              "msgcompose.font_face" = "monospace";
              # keep-sorted end
            };
          };
        };
      })
    ]
  );
}
