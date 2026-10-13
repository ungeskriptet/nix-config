{ inputs, ... }:
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  programs = {
    plasma = {
      enable = true;
      overrideConfig = true;
      configFile = {
        kscreenlockerrc.Daemon = {
          Autolock = false;
          LockOnResume = false;
          Timeout = 0;
        };
      };
      powerdevil.AC.autoSuspend.action = "nothing";
    };
  };

  home = {
    username = "htpc";
    homeDirectory = "/home/htpc";
    stateVersion = "26.05";
  };
}
