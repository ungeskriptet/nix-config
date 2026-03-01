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
        "ehci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "rtsx_pci_sdmmc"
      ];
      kernelModules = [ "i915" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0027d892-3b9a-4d91-8324-938a3b3c2818";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/B6F3-FDB2";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

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
