{ pkgs, lib, ... }:

{
  boot = {
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = lib.mkDefault true;
    };
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
  };

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

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024;
      randomEncryption.enable = true;
    }
  ];

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    enableRedistributableFirmware = true;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
