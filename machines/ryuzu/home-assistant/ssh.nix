{
  lib,
  pkgs,
  config,
  ...
}:
let
  systemdCmd = cmd: lib.getExe' pkgs.systemd cmd;
  homeAssistantKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCo1aBmLiSmZrjtnFVYczuv4/cNXjxF+4soUTSIeZla hass";
  sshWrapper = pkgs.writeShellScript "home-assistant-ssh" ''
    case "$SSH_ORIGINAL_COMMAND" in
      "poweroff")
        exec ${systemdCmd "poweroff"}
        ;;
      "itgmania")
        exec ${systemdCmd "systemctl"} \
          --machine=${config.users.userName}@ \
          --user start ${config.systemd.user.services.itgmania.name}
        ;;
      *)
        echo "Access denied for unknown command" 1>&2
        exit
    esac
  '';
in
{
  users.users.root = {
    openssh.authorizedKeys.keys = [
      ''restrict,command="${sshWrapper}" ${homeAssistantKey}''
    ];
  };

  systemd.user.services.itgmania = {
    description = "Launch ITGmania";
    script =
      let
        speakers = "alsa_output.pci-0000_0b_00.4.analog-stereo";
      in
      ''
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
        wpctl set-default $(get_output_id "${speakers}")
        systemd-inhibit --what=idle:sleep itgmania
        wpctl set-default $(get_output_id "$PREVIOUS_OUTPUT")
      '';
    after = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    path = with pkgs; [
      itgmania
      jq
      pipewire
      systemd
      wireplumber
    ];
  };
}
