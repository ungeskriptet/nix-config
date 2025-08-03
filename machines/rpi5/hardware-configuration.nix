{ pkgs, ... }:

{
  boot = {
    kernelParams = [ "video=HDMI-A-1:1280x720M@60" ];
    kernel.sysctl = {
      "kernel.panic" = 60;
      "kernel.hung_task_panic" = true;
    };
  };

  services.udev.packages = [
    (pkgs.raspberrypi-udev-rules.override { withCpuGovernorConfig = true; })
  ];

  systemd.tmpfiles.packages = [
    (pkgs.raspberrypi-udev-rules.override { withCpuGovernorConfig = true; })
  ];

  fileSystems = {
    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = [
        "noatime"
        "noauto"
        "x-systemd.automount"
        "x-systemd.idle-timeout=1min"
      ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024;
      randomEncryption.enable = true;
    }
  ];
  zramSwap.enable = true;

  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = "aarch64-linux";
}
