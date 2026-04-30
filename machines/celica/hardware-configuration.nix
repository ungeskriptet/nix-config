{ ... }:
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/62e9777b-21d3-4484-b6ea-2f310d1fa6d5";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/6AD8-F715";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };
}
