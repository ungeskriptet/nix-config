{ lib, ... }:
{
  options = {
    vars = {
      domain = lib.mkOption {
        type = lib.types.str;
        description = "The default domain to use.";
        default = "david-w.eu";
      };
      sshPubKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Trusted SSH public keys.";
        default = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls main@bitwarden"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwbbh5g3ustRbSg1T8etYXTwVLC5QRTuhGhhT23sJwE david@key4"
        ];
      };
    };
  };
}
