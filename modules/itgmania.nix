{
  lib,
  pkgs,
  config,
  ...
}:
let
  format = pkgs.formats.ini { };
  cfg = config.programs.itgmania;
  preferencesIni = format.generate "Preferences.ini" (
    cfg.preferences
    // {
      Options.DisableScreenSaver = 0;
    }
  );
in
{
  options.programs.itgmania = {
    enable = lib.mkEnableOption "ITGmania";
    audioDevice = lib.mkOption {
      type = lib.types.str;
      description = ''
        Audio device to switch to.
        Use `pw-dump` for the output node name.
      '';
      default = "";
    };
    preferences = lib.mkOption {
      type = format.type;
      description = ''
        Preferences to apply to `Save/Preferences.ini`.
      '';
      default = { };
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.user.services.itgmania = {
      description = "Launch ITGmania";
      script = ''
        ${lib.optionalString (cfg.audioDevice != "") ''
          get_output_id() {
            pw-dump | jq -r '
              .[] | select(
                .info.props."node.name" == "'"$1"'"
              ) | .id
            '
          }
          PREVIOUS_OUTPUT=$(pw-dump | jq -r '
            .[] | select(
              .type == "PipeWire:Interface:Metadata"
            ) | select(
              .props."metadata.name" == "default"
            ) | .metadata[] | select(
              .key == "default.configured.audio.sink"
            ) | .value.name'
          )
          wpctl set-default $(get_output_id "${cfg.audioDevice}")
        ''}
        mkdir -p ~/.itgmania/Save
        crudini --ini-options=nospace --merge \
          ~/.itgmania/Save/Preferences.ini < "${preferencesIni}"
        systemd-inhibit --what=idle:sleep itgmania
        ${lib.optionalString (cfg.audioDevice != "") ''
          wpctl set-default $(get_output_id "$PREVIOUS_OUTPUT")
        ''}
      '';
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      path =
        with pkgs;
        (
          [
            crudini
            itgmania
            systemd
          ]
          ++ lib.optionals (cfg.audioDevice != "") [
            jq
            pipewire
            wireplumber
          ]
        );
    };
  };
}
