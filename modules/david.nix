{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nix-config;
in
{
  options.nix-config = {
    david = lib.mkEnableOption "David's configs";
  };

  config = lib.mkIf cfg.david {
    nix-config = {
      enableVirt = true;
      enablePlasma = lib.mkIf (cfg.deviceType == "desktop") true;
    };
    # Automatically inject payload when a Nintendo Switch is connected
    systemd.tmpfiles.rules = [ "d /var/lib/fusee-nano 0777 root root -" ];
    services = {
      udev.extraRules = with pkgs; ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7321", RUN+="${lib.getExe fusee-nano} /var/lib/fusee-nano/payload.bin"
      '';
    };
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };

    home-manager = {
      users.david = {
        imports = [ ../home/david/module-list.nix ];
        hm-config.desktop = lib.mkIf (cfg.deviceType == "desktop") true;
      };
    };
  };
}
