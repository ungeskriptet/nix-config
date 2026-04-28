{ ... }:
{
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
}
