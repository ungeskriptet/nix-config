{ nixos-raspberrypi }:
[
  (
    { ... }:
    {
      nixpkgs.overlays = [
        nixos-raspberrypi.overlays.bootloader
        nixos-raspberrypi.overlays.vendor-kernel
        nixos-raspberrypi.overlays.vendor-firmware
        nixos-raspberrypi.overlays.kernel-and-firmware
        (self: super: {
          raspberrypi-utils = nixos-raspberrypi.packages.aarch64-linux.raspberrypi-utils;
          raspberrypi-udev-rules = nixos-raspberrypi.packages.aarch64-linux.raspberrypi-udev-rules;
        })
      ];
    }
  )
  nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  nixos-raspberrypi.nixosModules.raspberry-pi-5.bluetooth
]
