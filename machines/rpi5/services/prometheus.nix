{
  config,
  ...
}:
let
  fqdn = "prometheus.${domain}";
  domain = config.networking.domain;
in
{
  sops.secrets = {
    "stalwart/prometheus-pass".owner = "root";
  };

  networking = {
    hosts = {
      "::1" = [
        fqdn
      ];
      "127.0.0.1" = [
        fqdn
      ];
    };
  };

  systemd.services = {
    prometheus.serviceConfig = {
      LoadCredential = [
        "stalwart:${config.sops.secrets."stalwart/prometheus-pass".path}"
      ];
    };
  };

  services = {
    prometheus = {
      enable = true;
      listenAddress = "[::1]";
      port = 8077;
      extraFlags = [
        "--web.enable-remote-write-receiver"
      ];
      scrapeConfigs = [
        {
          job_name = "stalwart";
          metrics_path = "/metrics/prometheus";
          scheme = "https";
          static_configs = [
            {
              targets = [ "mail.${domain}:443" ];
            }
          ];
          basic_auth = {
            username = "prometheus";
            password_file = "/run/credentials/prometheus.service/stalwart";
          };
        }
      ];
    };
  };
}
