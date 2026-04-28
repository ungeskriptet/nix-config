{ ... }:
{
  boot = {
    loader.systemd-boot.consoleMode = "max";
    kernel.sysctl = {
      "vm.swappiness" = 10;
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
    "/mnt/data-ssd" = {
      device = "/dev/disk/by-id/nvme-KXG60ZNV1T02_KIOXIA_Z0BA302UKEV2_1-part1";
      fsType = "ext4";
      neededForBoot = true;
    };
    "/nix" = {
      device = "/mnt/data-ssd/nix";
      fsType = "none";
      options = [ "bind" ];
    };
  };

  zramSwap.memoryPercent = 85;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024;
      options = [ "discard" ];
      randomEncryption.enable = true;
    }
  ];
}
