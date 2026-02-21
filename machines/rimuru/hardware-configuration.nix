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
      device = "/dev/disk/by-uuid/e5672b62-e1cf-459a-9503-b7f2c063d406";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/8BD2-80B7";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/0898dbd2-bf9c-4f81-b848-a3b547446bd2"; }
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
