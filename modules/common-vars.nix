{ lib, ... }:
{
  options = {
    vars = {
      domain = lib.mkOption {
        type = lib.types.str;
        description = "The default domain to use.";
        default = "david-w.eu";
      };
    };
  };
}
