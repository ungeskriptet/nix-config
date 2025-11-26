{
  lib,
  pkgs,
  config,
  ...
}:
let
  myEmail = "moe@david-w.eu";
  myEmailHost = "mail.david-w.eu";
  mainlining = "david.wronek@mainlining.org";
  mainliningHost = "mail.mainlining.org";
in
{
  sops.secrets = lib.mergeAttrsList (
    builtins.map (email: { "email/${email}".mode = "0400"; }) [
      myEmail
      mainlining
    ]
  );

  accounts.email =
    let
      genEmailConfig =
        host: email: pass:
        builtins.mapAttrs
          (proto: port: {
            port = port;
            host = host;
            authentication = "plain";
          })
          {
            imap = 993;
            smtp = 465;
          }
        // {
          address = email;
          userName = email;
          realName = config.myuser.realName;
          passwordCommand = "cat ${pass}";
          jmap.host = host;
        };
    in
    {
      maildirBasePath = "${config.xdg.dataHome}/mail";
      accounts = {
        myEmail = {
          primary = true;
          aerc.enable = true;
          thunderbird.enable = true;
        }
        // genEmailConfig myEmailHost myEmail config.sops.secrets."email/${myEmail}".path;
        mainlining = {
          aerc.enable = true;
          thunderbird.enable = true;
        }
        // genEmailConfig mainliningHost mainlining config.sops.secrets."email/${mainlining}".path;
      };
    };

  programs = {
    aerc = {
      enable = true;
      extraConfig = {
        general.unsafe-accounts-conf = true;
        filters = {
          "text/plain" = "${pkgs.aerc}/libexec/aerc/filters/colorize";
          "text/html" =
            "${pkgs.aerc}/libexec/aerc/filters/html -o display_link_number=true | ${pkgs.aerc}/libexec/aerc/filters/colorize";
        };
      };
    };
    thunderbird = {
      enable = true;
      profiles."Default".isDefault = true;
    };
  };
}
