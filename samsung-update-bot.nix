{ config, lib, pkgs, ... }:

let
  updateBot = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "samsung-update-bot";
    version = "0.0.1";
    pyproject = true;
    nativeBuildInputs = [ pkgs.python3Packages.setuptools ];
    propagatedBuildInputs  = [ pkgs.python3Packages.requests ];
    src = pkgs.fetchFromGitHub {
      owner = "samsung-sm8650";
      repo = "update-bot";
      rev = "351400eb5e6606d5a46eff566d256f2a439a5133";
      hash = "sha256-oCeEiyElhfAg0+Qubyrw3268S6fVxRyIE76KUi5ym0A=";
    };
    meta.mainProgram = "samsung-update-bot";
  };

  stateDir = "/var/lib/samsung-update-bot/";
in
{
  sops.secrets."samsung-update-bot/token".owner = "samsung-update-bot";

  users = {
    groups.samsung-update-bot = { };
    users.samsung-update-bot = {
      isSystemUser = true;
      group = "samsung-update-bot";
      home = stateDir;
      createHome = true;
    };
  };

  systemd.services.samsung-update-bot = {
    enable = true;
    description = "Samsung OTA Update notifier";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "samsung-update-bot";
      WorkingDirectory = stateDir;
      ExecStart = "${lib.getExe updateBot} ${config.sops.secrets."samsung-update-bot/token".path}";
      Restart = "always";
      RestartSec = 60;
    };
  };
}
