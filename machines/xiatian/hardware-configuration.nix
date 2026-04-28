{ ... }:
{
  boot = {
    kernelModules = [ "hp-wmi" ];
    initrd.luks.devices."NIXOS_ROOTFS" = {
      device = "/dev/disk/by-partlabel/root";
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

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      randomEncryption.enable = true;
    }
  ];
}
