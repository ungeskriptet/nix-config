{ config, inputs, ... }:

{
  imports = [
    inputs.samsung-grab.nixosModules.samsung-grab
  ];

  sops.secrets."samsung-grab/url".owner = "samsung-grab";

  services.samsung-grab = {
    enable = true;
    username = "ungeskriptet";
    notifyFile = config.sops.secrets."samsung-grab/url".path;
  };
}
