{
  lib,
  rustPlatform,
  fetchFromGitHub,
  callPackage,

  # Package arguments
  stalwartEnterprise ? false,
  withFoundationdb ? false,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "stalwart";
  version = "0.16.4";

  src = fetchFromGitHub {
    owner = "stalwartlabs";
    repo = "stalwart";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4RcXRlDkxDiYQMHffvioIZ47FIaZkU6qVVkEkMAjd2Q=";
  };

  cargoHash = "sha256-vytgtOuwjA9LycsrgHxBMF/D3hHGD1tgLWXia5vgS9U=";

  nativeBuildInputs = [
    rustPlatform.bindgenHook
  ];

  buildNoDefaultFeatures = true;
  buildFeatures = [
    "sqlite"
    "postgres"
    "mysql"
    "rocks"
    "s3"
    "redis"
    "azure"
    "nats"
  ]
  ++ lib.optionals withFoundationdb [ "foundationdb" ]
  ++ lib.optionals stalwartEnterprise [ "enterprise" ];

  postInstall = ''
    mkdir -p $out/lib/systemd/system

    substitute resources/systemd/stalwart-mail.service $out/lib/systemd/system/stalwart.service \
      --replace-fail "__PATH__/bin/stalwart" "$out/bin/stalwart" \
      --replace-fail "__PATH__/etc/config.json" "/etc/stalwart/config.json"
  '';

  doCheck = false;

  passthru = {
    cli = callPackage ./cli.nix { stalwart = finalAttrs.finalPackage; };
    spam-filter = callPackage ./spam-filter.nix { stalwart = finalAttrs.finalPackage; };
    webui = callPackage ./webui.nix { stalwart = finalAttrs.finalPackage; };
    migrate-v016 = callPackage ./migrate-v016.nix { stalwart = finalAttrs.finalPackage; };
  };

  meta = {
    description = "Secure, modern, all-in-one mail and collaboration server";
    longDescription = ''
      Secure, scalable and fluent in every protocol (IMAP, JMAP, SMTP, CalDAV, CardDAV, WebDAV).
    '';
    homepage = "https://stalw.art/";
    changelog = "https://github.com/stalwartlabs/stalwart/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = [
      lib.licenses.agpl3Only
    ]
    ++ lib.optionals stalwartEnterprise [
      {
        fullName = "Stalwart Enterprise License 1.0 (SELv1) Agreement";
        url = "https://github.com/stalwartlabs/stalwart/blob/main/LICENSES/LicenseRef-SEL.txt";
        free = false;
        redistributable = false;
      }
    ];

    mainProgram = "stalwart";
    maintainers = with lib.maintainers; [
      happysalada
      onny
      oddlama
      pandapip1
      norpol
    ];
  };

})
