{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/packages-desktop.nix
  ];

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  networking.networkmanager.enable = true;

  # Required for WireGuard
  networking.firewall.checkReversePath = false;

  # Automatically inject payload when a Nintendo Switch is connected
  systemd.tmpfiles.rules = [ "d /var/lib/fusee-nano 0777 root root -" ];
  services.udev.extraRules = with pkgs; ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0955", ATTR{idProduct}=="7321", RUN+="${lib.getExe fusee-nano} /var/lib/fusee-nano/payload.bin"
  '';
}
