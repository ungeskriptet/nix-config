{
  lib,
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
    map (email: { "email/${email}".mode = "0400"; }) [
      myEmail
      mainlining
    ]
  );

  accounts = {
    email =
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
          }
          // genEmailConfig myEmailHost myEmail config.sops.secrets."email/${myEmail}".path;
          mainlining =
            genEmailConfig mainliningHost mainlining
              config.sops.secrets."email/${mainlining}".path;
        };
      };

    calendar.accounts."Stalwart Calendar" = {
      primary = true;
      remote = {
        url = "https://${myEmailHost}/dav/cal/${lib.escapeURL myEmail}/default/";
        userName = myEmail;
        passwordCommand = "cat ${config.sops.secrets."email/${myEmail}".path}";
        type = "caldav";
      };
      thunderbird = {
        enable = true;
        profiles = [ "Default" ];
        color = "#dc8add";
      };
    };

    contact.accounts."Stalwart Address Book" = {
      remote = {
        url = "https://${myEmailHost}/dav/card/${lib.escapeURL myEmail}/default/";
        userName = myEmail;
        passwordCommand = "cat ${config.sops.secrets."email/${myEmail}".path}";
        type = "carddav";
      };
      thunderbird = {
        enable = true;
        profiles = [ "Default" ];
      };
    };
  };
}
