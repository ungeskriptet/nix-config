{
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./common.nix
    ./firefox
  ];

  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  sops = {
    secrets."groovestats/apikey" = { };
    templates."GrooveStats.ini".content = ''
      [GrooveStats]
      ApiKey=${config.sops.placeholder."groovestats/apikey"}
      IsPadPlayer=1
    '';
  };

  home.file = {
    ".itgmania/Save/LocalProfiles/00000000/GrooveStats.ini".source =
      config.lib.file.mkOutOfStoreSymlink
        config.sops.templates."GrooveStats.ini".path;
  };
}
