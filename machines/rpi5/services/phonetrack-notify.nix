{ config, inputs, ... }:
{
  imports = [
    inputs.phonetrack-notify.nixosModules.phonetrack-notify
  ];

  sops.secrets."phonetrack-notify/token".owner = "root";

  services.phonetrack-notify = {
    enable = true;
    hassUrl = "https://home.david-w.eu";
    hassTokenFile = config.sops.secrets."phonetrack-notify/token".path;
  };
}
