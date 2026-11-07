{
  runCommand,
  kdePackages,
}:
runCommand "telegram-show-hide"
  {
    nativeBuildInputs = [
      kdePackages.kpackage
      kdePackages.kwin
    ];
  }
  ''
    runHook preInstall

    mkdir -p package/contents/code
    cp ${./metadata.json} package/metadata.json
    cp ${./telegram-show-hide.js} package/contents/code/main.js

    kpackagetool6 --type=KWin/Script --install=./package --packageroot=$out/share/kwin/scripts

    runHook postInstall
  ''
