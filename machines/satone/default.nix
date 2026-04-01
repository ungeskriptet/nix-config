{ pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./networking.nix
    ../common.nix
  ];

  networking.hostName = "satone";

  security.sudo.wheelNeedsPassword = false;

  nix-config.david = true;

  users.hashedPassword = "$y$j9T$cZHO15OQwSLEWl8NUj/vE0$9xqhvcR51F7lg/jFgZXyHHH3o1ifVjVlPTlSstJtdM/";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "kernel.panic" = 60;
      "kernel.hung_task_panic" = true;
    };
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
