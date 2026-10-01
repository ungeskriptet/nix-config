{
  wrapFirefox,
  firefox-unwrapped,
  unzip,
  zip,
}:
wrapFirefox (
  (firefox-unwrapped.overrideAttrs (prev: {
    nativeBuildInputs = [
      unzip
      zip
    ];

    phases = [
      "patchPhase"
      "fixupPhase"
      "installCheckPhase"
    ];

    patchPhase = ''
      cp -r "${firefox-unwrapped.out}" "$out"
      chmod -R u+w "$out"

      patchdir=$(mktemp -d)
      unzip -qd "$patchdir" "$out"/lib/firefox/omni.ja || [ $? -eq 2 ]

      substituteInPlace "$patchdir"/modules/AppConstants.sys.mjs \
        --replace-fail 'MOZ_REQUIRE_SIGNING: true,' 'MOZ_REQUIRE_SIGNING: false,' \
        --replace-fail 'MOZ_ALLOW_ADDON_SIDELOAD: false,' 'MOZ_ALLOW_ADDON_SIDELOAD: true,'

      rm "$out"/lib/firefox/omni.ja
      pushd "$patchdir"
      zip -qrXD "$out"/lib/firefox/omni.ja *
      popd

      mv -f "$out"/bin/.firefox-wrapped "$out"/bin/firefox

      touch "$symbols"
    '';

  })).override
  {
    enableAddonSideload = true;
    enableAddonSigning = false;
  }
) { }
