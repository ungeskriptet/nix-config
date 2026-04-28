{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/baa48611-e2d9-4925-84fb-d6e5aedf281c";
      fsType = "btrfs";
      options = [ "compress=zstd:3" ];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/BD1C-3055";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
    "/var" = {
      device = "/dev/disk/by-uuid/fe2fdded-486d-4ec1-9fc3-d19fa447f75c";
      fsType = "btrfs";
      options = [ "compress=zstd:3" ];
    };
  };

  zramSwap.memoryPercent = 50;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
      randomEncryption.enable = true;
    }
  ];
}
