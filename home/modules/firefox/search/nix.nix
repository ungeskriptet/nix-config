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
  noogle = {
    name = "Noogle";
    urls = [
      {
        template = "https://noogle.dev/q";
        params = [
          {
            name = "term";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    definedAliases = [ ":nl" ];
  };
  nix-github = {
    name = "Nix code (GitHub)";
    urls = [
      {
        template = "https://github.com/search";
        params = [
          {
            name = "q";
            value = "language%3Anix+{searchTerms}";
          }
          {
            name = "type";
            value = "code";
          }
        ];
      }
    ];
    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
    definedAliases = [ ":nc" ];
  };
}
