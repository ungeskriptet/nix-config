{ lib, config, ... }:
let
  domain = config.networking.domain;
  mkSources =
    mergedName: sources:
    (lib.mapAttrs (name: url: {
      inherit url;
      type = "feed";
      filters = [
        "unseen"
        "includesourcetitle"
        "includelink"
        "embedimage"
      ];
    }) sources)
    // {
      ${mergedName} = {
        type = "merge";
        sources = lib.mapAttrsToList (name: _: name) sources;
      };
    };
in
{
  services = {
    goeland = {
      enable = true;
      schedule = "hourly";
      settings = {
        loglevel = "info";
        email = {
          host = "mail.${domain}";
          port = 465;
          username = "goeland@${domain}";
          encryption = "ssl";
          authentication = "plain";
          include-header = true;
          include-title = true;
          include-footer = false;
        };
        sources = mkSources "merged" {
          # keep-sorted start
          browsery = "https://biskupova.televiziastb.sk/browsery_rss.php";
          cccEvents = "https://events.ccc.de/feed";
          gamo2 = "https://nitter.net/GamoTwo/rss";
          haiku = "https://www.haiku-os.org/index.xml";
          haveibeenpwned = "https://haveibeenpwned.com/feed/breaches";
          iidxOfficial = "https://nitter.net/IIDX_OFFICIAL/rss";
          limob = "https://linmob.net/feed.xml";
          lineageos = "https://lineageos.org/feed.xml";
          lineageosHudson = "https://github.com/LineageOS/hudson/commits/main/lineage-build-targets.atom";
          nixosAnnouncements = "https://nixos.org/blog/announcements-rss.xml";
          nixosNews = "https://nixos.org/blog/newsletters-rss.xml";
          nixosStories = "https://nixos.org/blog/stories-rss.xml";
          phoronix = "https://www.phoronix.com/rss.php";
          plasma = "https://blogs.kde.org/index.xml";
          postmarketos = "https://postmarketos.org/blog/feed.atom";
          postmarketosEdge = "https://postmarketos.org/edge/feed.atom";
          reactos = "https://reactos.org/index.xml";
          # keep-sorted end
        };
        pipes = {
          default = {
            source = "merged";
            destination = "email";
            email_from = "Goeland <goeland@${domain}>";
            email_to = [ "rss@${domain}" ];
          };
        };
      };
    };
  };

  systemd.services.goeland = {
    environment = {
      GOELAND_EMAIL_PASSWORD_FILE = "%d/smtppass";
    };
    serviceConfig.LoadCredential = [ "smtppass:${config.sops.secrets."goeland/smtppass".path}" ];
  };

  sops.secrets = {
    "goeland/smtppass".owner = "root";
  };
}
