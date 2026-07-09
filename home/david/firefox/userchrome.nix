{ config, ... }:
let
  cfg = config.programs.firefox;
in
{
  programs.firefox.profiles.${cfg.defaultProfile}.userChrome = ''
    /*
     * Hide "This connection is not secure" message
     */
    #PopupAutoComplete > richlistbox > richlistitem[originaltype="insecureWarning"],
    #PopupAutoComplete[resultstyles="insecureWarning"] {
      visibility: collapse;
    }
  '';
}
