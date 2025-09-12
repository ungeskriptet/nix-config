{ lib, ... }:
{
  options = {
    myuser.realName = lib.mkOption {
      type = lib.types.str;
      description = "Real name of the user";
      default = "David Wronek";
    };
  };
}
