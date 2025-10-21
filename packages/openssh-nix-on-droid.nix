{ openssh }:
openssh.overrideAttrs {
  postPatch = ''
    ${openssh.postPatch}
    # Get sftp working in Nix-on-Droid
    substituteInPlace sftp-server.c --replace-fail \
      "platform_disable_tracing(1);" "platform_disable_tracing(0);"
  '';
}
