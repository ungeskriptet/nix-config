{ lib, pkgs, ... }:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    jvmOpts = "-Xmx16G -Xms2G";
    package = pkgs.papermcServers.papermc-1_21_5;
  };

  # Start the Minecraft server manually when needed
  systemd.services.minecraft-server.wantedBy = lib.mkForce [ ];
}
