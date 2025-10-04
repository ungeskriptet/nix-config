{ pkgs }:
{
  nix-options = {
    name = "NixOS Options";
    urls = [
      {
        template = "https://search.nixos.org/options";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    definedAliases = [ ":no" ];
  };
  nix-packages = {
    name = "Nix Packages";
    urls = [
      {
        template = "https://search.nixos.org/packages";
        params = [
          {
            name = "channel";
            value = "unstable";
          }
          {
            name = "query";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    definedAliases = [ ":np" ];
  };
  mynixos = {
    name = "MyNixOS";
    urls = [
      {
        template = "https://mynixos.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://mynixos.com/favicon.ico";
    definedAliases = [ ":my" ];
  };
}
