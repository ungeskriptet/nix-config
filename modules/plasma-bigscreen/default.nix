{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.desktopManager.plasma-bigscreen;
in
{
  options.services.desktopManager.plasma-bigscreen = {
    enable = lib.mkEnableOption "Plasma Bigscreen";
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      description = ''
        Password hash for the HTPC user
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    boot = {
      loader.timeout = 0;
    };

    users = {
      mutableUsers = false;
      users.htpc = {
        isNormalUser = true;
        description = "HTPC";
        hashedPassword = cfg.hashedPassword;
      };
    };

    home-manager = {
      users.htpc = {
        imports = [ ./home.nix ];
      };
    };

    networking = {
      firewall = {
        allowedUDPPorts = [ 1900 ];
        allowedTCPPorts = [ 4040 ];
      };
    };

    services = {
      desktopManager.plasma6.enable = true;
      displayManager = {
        sessionPackages = with pkgs; [ kdePackages.plasma-bigscreen ];
        defaultSession = "plasma-bigscreen-wayland";
        autoLogin = {
          user = config.users.users.htpc.name;
          enable = true;
        };
        plasma-login-manager = {
          enable = true;
          settings = {
            Autologin.Relogin = true;
          };
        };
      };
      pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      logind.settings.Login = {
        HandlePowerKey = "ignore";
        HandlePowerKeyLongPress = "ignore";
        HandleSuspendKey = "ignore";
        HandleSuspendKeyLongPress = "ignore";
      };
    };

    xdg.portal.configPackages = with pkgs.kdePackages; [
      plasma-bigscreen
      plasma-workspace
    ];

    programs = {
      kdeconnect.enable = true;
      kde-pim.enable = false;
    };

    environment = {
      systemPackages =
        with pkgs.kdePackages;
        [
          plasma-bigscreen
          plasma-nm # Required to fix `"org.kde.plasma.networkmanagement" is not installed`
        ]
        ++ (with pkgs; [ vacuum-tube ]);
      plasma6.excludePackages = with pkgs.kdePackages; [
        # keep-sorted start
        ark
        aurorae
        baloo-widgets
        discover
        dolphin
        dolphin-plugins
        elisa
        gwenview
        kate
        khelpcenter
        ktexteditor
        kwin-x11
        okular
        plasma-desktop
        print-manager
        qrca
        spectacle
        # keep-sorted end
      ];
    };

    nixpkgs.overlays = [
      (final: prev: {
        vacuum-tube = prev.vacuum-tube.overrideAttrs (prevPkg: {
          postPatch = ''
            ${if (prevPkg ? postPatch) then prevPkg.postPatch else ""}
            substituteInPlace src/preload/modules/h5vcc/dial/http.js \
              --replace-fail \
              "server.listen(0, (err) => {" "server.listen(4040, (err) => {"
          '';
        });
      })
    ];
  };
}
