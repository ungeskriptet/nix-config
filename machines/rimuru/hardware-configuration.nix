{ ... }:
{
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

  systemd.sleep.settings.Sleep = {
    MemorySleepMode = "s2idle";
  };
}
