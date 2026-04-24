{
  lib,
  pkgs,
  ...
}:
let
  homeAssistantKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCo1aBmLiSmZrjtnFVYczuv4/cNXjxF+4soUTSIeZla hass";
  sshWrapper = pkgs.writeShellScript "home-assistant-ssh" ''
    case "$SSH_ORIGINAL_COMMAND" in
      "poweroff")
        exec ${lib.getExe' pkgs.systemd "poweroff"}
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
