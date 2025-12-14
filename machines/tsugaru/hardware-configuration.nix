{
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    kernelModules = [ "kvm-intel" ];
    extraModprobeConfig = ''
      options nouveau modeset=0
    '';
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_modeset"
    ];
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "rtsx_pci_sdmmc"
      ];
      initrd.kernelModules = [ "i915" ];
    };
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

  zramSwap.enable = true;

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
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    bluetooth.enable = true;
    cpu.intel.updateMicrocode = true;
    graphics = {
      extraPackages32 = with pkgs; [
        (driversi686Linux.intel-vaapi-driver.override { enableHybridCodec = true; })
      ];
      extraPackages = with pkgs; [
        (intel-vaapi-driver.override { enableHybridCodec = true; })
      ];
    };
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
    fstrim.enable = true;
    fwupd.enable = true;
    thermald.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
