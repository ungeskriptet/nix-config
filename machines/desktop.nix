{ ... }:

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
}
