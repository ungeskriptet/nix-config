{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  go,
}:

let
  version = "0.3.23-beta-release";

  sshwifty-ui = buildNpmPackage {
    pname = "sshwifty-ui";
    inherit version;

    src = fetchFromGitHub {
      owner = "nirui";
      repo = "sshwifty";
      rev = version;
      hash = "sha256-uQEOUvy45zzaGE9u1dThLQMP3VGXs+cWmtVzX9M33Mw=";
    };

    npmDepsHash = "sha256-lgAoT5kYQ4RzgpTlFjEBsndPA2Iv6cMW2O18tALs2kE=";

    npmBuildScript = "generate";

    postInstall = ''
      for i in static_pages static_pages.go; do
        cp -r application/controller/$i \
	  $out/lib/node_modules/sshwifty-ui/application/controller
      done
    '';

    nativeBuildInputs = [ go ];
  };
in
buildGoModule rec {
  pname = "sshwifty";
  inherit version;

  src = sshwifty-ui + "/lib/node_modules/sshwifty-ui";

  vendorHash = "sha256-pSKtbbJhKuSm5q6KwUguG90uHqcRmzyhR6PRCrY7Mh4=";

  ldflags = [
    "-s -w -X github.com/nirui/sshwifty/application.version=${version}"
  ];

  postInstall = ''
    find $out/bin ! -name sshwifty -type f -exec rm -rf {} \;
  '';

  meta = {
    description = "WebSSH & WebTelnet client";
    homepage = "https://github.com/nirui/sshwifty";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ ungeskriptet ];
    mainProgram = "sshwifty";
  };
}
