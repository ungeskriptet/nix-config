{ ... }:

{
  boot = {
    kernelParams = [ "amd_pstate=active" ];
    initrd.kernelModules = [ "amdgpu" ];
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
  };
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/root";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-partlabel/EFI";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32*1024;
    randomEncryption.enable = true;
  }];

  hardware = {
    bluetooth.enable = true;
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  nixpkgs.hostPlatform = "x86_64-linux";
}
