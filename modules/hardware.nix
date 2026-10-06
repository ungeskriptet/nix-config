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
        "oldintel"
        "newintel"
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

      (lib.mkIf (lib.hasSuffix "intel" cfg.hardware.platform) {
        services.thermald.enable = true;
        boot = {
          kernelModules = [ "kvm-intel" ];
          initrd.kernelModules = [ "i915" ];
        };
        environment.sessionVariables = {
          LIBVA_DRIVER_NAME = "iHD";
        };
        hardware = {
          graphics.extraPackages = with pkgs; [
            intel-media-driver
          ];
          cpu = {
            intel.updateMicrocode = true;
          };
        };
      })

      (lib.mkIf (cfg.hardware.platform == "oldintel") {
        boot = {
          kernelParams = [ "i915.enable_guc=2" ];
        };
        hardware = {
          graphics.extraPackages = with pkgs; [
            intel-compute-runtime-legacy1
            (intel-media-sdk.overrideAttrs (prev: {
              doCheck = false;
              cmakeFlags = lib.remove "-DBUILD_TESTS=ON" prev.cmakeFlags;
            }))
          ];
        };
        nixpkgs.allowPackages = [ "intel-media-sdk" ];
      })

      (lib.mkIf (cfg.hardware.platform == "newintel") {
        hardware = {
          graphics.extraPackages = with pkgs; [
            vpl-gpu-rt
            intel-compute-runtime
          ];
        };
      })
    ]
  );
}
