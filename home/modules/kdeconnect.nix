{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.kdeconnect;
  mkCommandConfig =
    json:
    let
      jsonEscaped = lib.escape [ "\"" ] (builtins.toJSON json);
    in
    pkgs.writeText "kdeconnect-command-config" ''
      [General]
      commands="@ByteArray(${jsonEscaped})"
    '';
  cli = lib.getExe' pkgs.kdePackages.kdeconnect-kde "kdeconnect-cli";
  homeDir = config.home.homeDirectory;
  script = pkgs.writeShellScript "kdeconnect-config-setup" ''
    ${cli} --list-available --id-name-only | while IFS=" " read -ra line; do
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (_: device: ''
          if [[ "''${line[1]}" == "${device.name}" ]]; then
            ln -sf ${mkCommandConfig device.commands} \
              "''${XDG_CONFIG_HOME:-"${homeDir}/.config"}"/kdeconnect/"''${line[0]}"/kdeconnect_runcommand/config
          fi
        '') cfg.devices
      )}
    done
  '';
in
{
  options.services.kdeconnect = {
    devices = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              name = lib.mkOption {
                type = lib.types.str;
                description = ''
                  Name of the device:
                '';
                default = name;
              };
              commands = lib.mkOption {
                type = (pkgs.formats.json { }).type;
                description = ''
                  Attribute set of commands this device
                  is allowed to run.
                '';
                default = { };
              };
            };
          }
        )
      );
      description = ''
        KDE Connect device configuration.

        This option requires the device to be
        paired beforehand.
      '';
      default = { };
    };
  };
  config = lib.mkIf (cfg.devices != { }) {
    systemd.user = {
      services = {
        kdeconnect-setup = {
          Unit = {
            Description = "KDE Connect config setup";
            After = [
              "graphical-session.target"
              "xdg-desktop-autostart.target"
            ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = script;
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
