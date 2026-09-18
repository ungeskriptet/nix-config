{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:
let
  cfg = config.nix-config;
in
{
  imports = [
    ./nixpkgs-config.nix
    ./vars.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  options.nix-config.hardware = {
    enable = lib.mkEnableOption "hardware configs";
    platform = lib.mkOption {
      type = lib.types.enum [
        "amd"
        "intel"
      ];
      description = "The hardware platform.";
    };
  };

  config = lib.mkIf cfg.hardware.enable (
    lib.mkMerge [
      {
        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          kernelModules = [ "ntsync" ];
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot = {
              enable = lib.mkDefault true;
              bootCounting = {
                enable = true;
                tries = 3;
              };
            };
          };
          initrd.availableKernelModules = [
            "ahci"
            "nvme"
            "usbhid"
          ];
        };
        hardware = {
          enableRedistributableFirmware = true;
          bluetooth.enable = true;
        };
        services = {
          fstrim.enable = true;
          fwupd.enable = true;
        };
        zramSwap.enable = true;
      }

      (lib.mkIf (cfg.deviceType == "desktop") {
        hardware = {
          sensor.iio.enable = true;
          graphics = {
            enable = true;
            enable32Bit = true;
          };
        };
      })

      (lib.mkIf (cfg.hardware.platform == "amd") {
        boot = {
          kernelModules = [ "kvm-amd" ];
          kernelParams = [ "amd_pstate=active" ];
        };
        hardware.cpu = {
          amd.updateMicrocode = true;
        };
      })

      (lib.mkIf (cfg.hardware.platform == "intel") {
        services.thermald.enable = true;
        boot = {
          kernelParams = [ "i915.enable_guc=2" ];
          kernelModules = [ "kvm-intel" ];
          initrd.kernelModules = [ "i915" ];
        };
        hardware = {
          graphics.extraPackages = with pkgs; [
            intel-compute-runtime-legacy1
            intel-media-driver
            (intel-media-sdk.overrideAttrs (prev: {
              doCheck = false;
              cmakeFlags = lib.remove "-DBUILD_TESTS=ON" prev.cmakeFlags;
            }))
          ];
          cpu = {
            intel.updateMicrocode = true;
          };
        };
        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
        nixpkgs.allowPackages = [ "intel-media-sdk" ];
      })
    ]
  );
}
