{ config, inputs, ... }:
let
  hassUrl = "https://home.${config.networking.domain}";
in
{
  imports = [
    inputs.phonetrack-notify.nixosModules.phonetrack-notify
  ];

  sops.secrets."phonetrack-notify/token".owner = "root";

  services.phonetrack-notify = {
    enable = true;
    address = "[::1]:8094";
    hassUrl = hassUrl;
    hassTokenFile = config.sops.secrets."phonetrack-notify/token".path;
  };
}
