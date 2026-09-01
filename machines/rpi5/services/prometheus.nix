{
  config,
  ...
}:
let
  fqdn = "prometheus.${domain}";
  domain = config.networking.domain;
in
{
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

  services = {
    prometheus = {
      enable = true;
      listenAddress = "[::1]";
      port = 8077;
      extraFlags = [
        "--web.enable-remote-write-receiver"
      ];
    };
  };
}
