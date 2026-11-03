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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVyRhYr6ZJdY3wAlHJzC6yHrzW1he8QNmo/OmYhEbaG david-w.eu"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDwbbh5g3ustRbSg1T8etYXTwVLC5QRTuhGhhT23sJwE david@key4"
        ];
      };
    };
  };
}
