{
  lib,
  ...
}:

{
  boot = {
    extraModprobeConfig = ''
      options nouveau modeset=0
    '';
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/23be29d9-b303-4d76-a4c8-3a2ac2d7bb1e";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/6CA4-1CAB";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };
  };

  # Bug: Fix audio after sleep
  systemd.services.reloadaudio = {
    description = "Reload audio after sleep";
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
    script = ''
      echo 1 > /sys/bus/pci/devices/0000:00:1b.0/remove
      sleep 1
      echo 1 > /sys/bus/pci/rescan
    '';
  };

  hardware = {
    nvidia = {
      prime.offload.enable = lib.mkForce false;
      powerManagement = {
        enable = lib.mkForce false;
        finegrained = lib.mkForce false;
      };
    };
  };

  services = {
    udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
    '';
  };
}
