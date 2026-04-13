{ ... }:
{
  boot = {
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "amd_pstate=active" ];
    loader.systemd-boot.consoleMode = "max";
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
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

  zramSwap = {
    enable = true;
    memoryPercent = 85;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 64 * 1024;
      options = [ "discard" ];
      randomEncryption.enable = true;
    }
  ];

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
