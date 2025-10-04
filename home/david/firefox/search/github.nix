{ ... }:
{
  github = {
    name = "GitHub";
    urls = [
      {
        template = "https://github.com/search";
        params = [
          {
            name = "q";
            value = "{searchTerms}";
          }
          {
            name = "type";
            value = "code";
          }
        ];
      }
    ];
    icon = "https://github.githubassets.com/assets/pinned-octocat-093da3e6fa40.svg";
    definedAliases = [ ":gh" ];
  };
}
