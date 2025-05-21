{ config, lib, pkgs, ... }:

let
  samfirmJs = pkgs.buildNpmPackage rec {
    name = "samfirm.js";

    src = pkgs.fetchFromGitHub {
      owner = "DavidArsene";
      repo = "samfirm.js";
      rev = "5e2537c2452c3033259a1e4399d9bb755e99f1da";
      hash = "sha256-81nWdIXJMXy5P37K9A3hAdLrYAEtqPJy7baM1Z22tzs=";
    };
    npmDepsHash = "sha256-os75tFpyxzxGpt5Era+K+zgMJyfwD4u0AtTRLC/fPUQ=";

    installPhase = ''
      runHook preInstall
      install -Dm555 dist/index.js $out/bin/samfirm.js
      runHook postInstall
    '';

    meta = {
      description = "Samsung firmware download tool";
      homepage = "https://github.com/DavidArsene/samfirm.js";
      platforms = lib.platforms.all;
      mainprogram = "samfirm.js";
    };
    
  };
in
{
  environment.systemPackages = [ samfirmJs ];
}
