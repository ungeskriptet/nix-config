{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ "i915" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/4b23f0f4-5e0c-45cc-8bb7-c0554f6413ae";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/3103-22DD";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      randomEncryption.enable = true;
    }
  ];

  zramSwap.enable = true;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      extraPackages32 = with pkgs; [
        (driversi686Linux.intel-vaapi-driver.override { enableHybridCodec = true; })
      ];
      extraPackages = with pkgs; [
        (intel-vaapi-driver.override { enableHybridCodec = true; })
      ];
    };
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
    thermald.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
