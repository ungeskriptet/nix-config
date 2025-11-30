{ config, ... }:
{
  services = {
    mosquitto = {
      enable = true;
      persistence = false;
      listeners = [
        {
          acl = [ "pattern readwrite #" ];
          users.openbeken.hashedPassword = "$7$101$oUTohobjJ/t9DVvC$85iyf5i90rqxgVS2EXgDpFSUBUA3+pNZWUpCxOzcA9IGR++fqcIWgjyZxemvT67uOB5ORarOQzu5UO2P0Eh55w==";
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 1883 ];
}
