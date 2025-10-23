{ pkgs, ... }:
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
      preOpenCommands = "(sleep 120; poweroff -f) &";
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
    graphics.extraPackages32 = [ pkgs.intel-media-driver-32 ];
    graphics.extraPackages = [
      pkgs.intel-media-driver
      pkgs.intel-compute-runtime
      pkgs.vpl-gpu-rt
    ];
    sensor.iio.enable = true;
  };

  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.thermald.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
