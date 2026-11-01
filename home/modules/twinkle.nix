{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.programs.twinkle;
in
{
  options.programs.twinkle = {
    enable = lib.mkEnableOption "Twinkle";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      twinkle
    ];

    xdg.autostart = {
      enable = true;
      entries = with pkgs; [
        "${twinkle}/share/applications/twinkle.desktop"
      ];
    };
  };
}
