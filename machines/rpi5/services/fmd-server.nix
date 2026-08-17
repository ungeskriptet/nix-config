{
  config,
  ...
}:
let
  fqdn = "fmd.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets."fmd-server/env".owner = "root";

  systemd.services = {
    caddy = {
      wants = [ config.systemd.services.fmd-server.name ];
      serviceConfig.SupplementaryGroups = [ "fmd-server" ];
    };
  };

  services = {
    caddy.hosts.${fqdn} = {
      reverseProxies."unix//run/fmd-server/fmd.sock" = { };
    };

    fmd-server = {
      enable = true;
      environmentFile = config.sops.secrets."fmd-server/env".path;
      settings = {
        UnixSocketPath = "/run/fmd-server/fmd.sock";
        UnixSocketChmod = "0660";
        MetricsAddrPort = "";
      };
    };
  };
}
