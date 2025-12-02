{
  config,
  ...
}:
{
  imports = [
    ./common.nix
    ./firefox
    ./email/desktop.nix
    ../common-allusers.nix
  ];

  sops = {
    secrets."groovestats/apikey" = { };
    templates."GrooveStats.ini".content = ''
      [GrooveStats]
      ApiKey=${config.sops.placeholder."groovestats/apikey"}
      IsPadPlayer=1
    '';
  };

  home.file = {
    ".itgmania/Save/LocalProfiles/00000000/GrooveStats.ini" = {
      source = config.lib.file.mkOutOfStoreSymlink config.sops.templates."GrooveStats.ini".path;
      force = true;
    };
  };
}
