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
}
