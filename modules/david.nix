{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.nix-config;
in
{
  options.nix-config = {
    david = {
      enable = lib.mkEnableOption "David's configs";
      profile = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum [ "personal" ]);
        description = ''
          Which profile to use for David's configs.
        '';
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.david.enable (
    lib.mkMerge (
      [
        (lib.mkIf (cfg.deviceType == "desktop") {
          nix-config = {
            enableVirt = true;
            enablePlasma = true;
          };
          home-manager.users.david = {
            hm-config.david = {
              desktop.enable = true;
              plasma.enable = true;
            };
          };
          programs.obs-studio = {
            enable = true;
            enableVirtualCamera = true;
          };
        })
        (lib.mkIf (cfg.david.profile == "personal") {
          # Automatically inject payload when a Nintendo Switch is connected
          systemd.tmpfiles.rules = [ "d /var/lib/fusee-nano 0777 root root -" ];
          services = {
            udev.extraRules = with pkgs; ''
              ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7321", RUN+="${lib.getExe fusee-nano} /var/lib/fusee-nano/payload.bin"
            '';
          };
        })
      ]
      ++ (map
        (user: {
          home-manager.users.${user} = {
            imports = [ ../home/david/module-list.nix ];
            hm-config.david.profile = lib.mkIf (cfg.david.profile == "personal") "personal";
            sops = {
              defaultSopsFile = "${inputs.self}/secrets/user-${config.users.userName}.yaml";
            };
          };
        })
        [
          config.users.userName
          config.users.rootUser
        ]
      )
    )
  );
}
