{ lib, pkgs, ... }:
{
  boot = {
    kernelParams = [ "i915.enable_guc=2" ];
    kernelModules = [
      "hp-wmi"
      "kvm-intel"
    ];
    initrd.availableKernelModules = [
      "xhci_pci"
      "nvme"
    ];
    initrd.luks.devices."NIXOS_ROOTFS" = {
      device = "/dev/disk/by-partlabel/root";
      preOpenCommands = "(sleep 300; poweroff -f) &";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/NIXOS_ROOTFS";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  zramSwap.enable = true;
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      randomEncryption.enable = true;
    }
  ];

  hardware = {
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics.extraPackages = with pkgs; [
      intel-compute-runtime-legacy1
      intel-media-driver
      (intel-media-sdk.overrideAttrs (prev: {
        doCheck = false;
        cmakeFlags = lib.remove "-DBUILD_TESTS=ON" prev.cmakeFlags;
      }))
    ];
    sensor.iio.enable = true;
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.thermald.enable = true;

  nixpkgs = {
    hostPlatform = "x86_64-linux";
    config.allowInsecurePredicate = pkg: builtins.elem (lib.getName pkg) [ "intel-media-sdk" ];
  };
}
