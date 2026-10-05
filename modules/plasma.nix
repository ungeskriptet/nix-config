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
    enablePlasma = lib.mkEnableOption "Plasma";
  };
  config = lib.mkIf cfg.enablePlasma {
    services = {
      desktopManager.plasma6.enable = true;
      displayManager.plasma-login-manager.enable = true;
    };

    environment = {
      plasma6.excludePackages = (
        with pkgs.kdePackages;
        [
          baloo
          baloo-widgets
          elisa
          kate
          khelpcenter
        ]
      );
      systemPackages = with pkgs; [ kdePackages.yakuake ];
      sessionVariables = {
        PINENTRY_KDE_USE_WALLET = "1";
      };
    };

    environment = {
      etc."xdg/baloofilerc".source = (pkgs.formats.ini { }).generate "baloorc" {
        "Basic Settings" = {
          "Indexing-Enabled" = false;
        };
      };
    };

    systemd.user.services.ssh-add = {
      wantedBy = [ "default.target" ];
      requires = [ "ssh-agent.service" ];
      after = [ "ssh-agent.service" ];
      script = ''
        ${pkgs.openssh}/bin/ssh-add -q < /dev/null
      '';
      unitConfig.ConditionUser = "!@system";
      serviceConfig.Restart = "on-failure";
    };
  };
}
