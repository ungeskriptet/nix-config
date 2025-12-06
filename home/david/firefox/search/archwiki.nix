{ ... }:
{
  archwiki = {
    name = "ArchWiki";
    urls = [
      {
        template = "https://wiki.archlinux.org/index.php";
        params = [
          {
            name = "search";
            value = "{searchTerms}";
          }
        ];
      }
    ];
    icon = "https://wiki.archlinux.org/favicon.ico";
    definedAliases = [ ":aw" ];
  };
}
