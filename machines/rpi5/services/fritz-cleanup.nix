{ config, ... }:
{
  imports = [ ../../../modules/fritz-cleanup ];

  sops.secrets."fritz-cleanup/envfile".owner = "root";

  services.fritz-cleanup = {
    enable = true;
    environmentFile = config.sops.secrets."fritz-cleanup/envfile".path;
    environment = {
      FRITZ_URL = "https://fritz.${config.networking.domain}";
      FRITZ_USERNAME = "david";
    };
  };
}
