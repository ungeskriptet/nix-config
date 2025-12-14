{ pkgs, ... }:
{
  boot = {
    kernelParams = [ "i915.enable_guc=2" ];
    kernelModules = [ "kvm-intel" ];
    initrd = {
      availableKernelModules = [
        "ahci"
        "rtsx_usb_sdmmc"
        "sd_mod"
        "sr_mod"
        "usbhid"
        "usb_storage"
        "xhci_pci"
      ];
      kernelModules = [ "i915" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/root";
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
    graphics = {
      extraPackages32 = [ pkgs.intel-media-driver-32 ];
      extraPackages = [
        pkgs.intel-media-driver
        pkgs.intel-compute-runtime
        pkgs.vpl-gpu-rt
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
