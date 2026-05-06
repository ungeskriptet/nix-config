{
  config,
  ...
}:
let
  domain = config.networking.domain;
in
{
  services = {
    caddy = {
      enable = true;
      hosts = {
        "*.${domain}" = {
          extraConfig = ''
            redir * https://${domain}/ temporary
          '';
        };
        "7590.${domain}" = {
          lanOnly.enable = true;
          reverseProxies."https://192.168.64.15" = {
            insecureTLS = true;
          };
        };
        "drasl.${domain}" = {
          reverseProxies."https://[fd64::3]" = { };
        };
        "fritz.${domain}" = {
          reverseProxies."https://[fd64::52e6:36ff:fe06:6e73]" = {
            insecureTLS = true;
          };
        };
        "omao.${domain}" = {
          reverseProxies."https://51kmze6tyra6b5gb.myfritz.net:40555" = { };
        };
        "options.${domain}" = {
          rootDirs.manual.dir = "${config.system.build.manual.manualHTML}/share/doc/nixos";
          fileServers = [ { } ];
          index = "/options.html";
        };
        ${domain} = {
          rootDirs."/var/lib/caddy/www" = { };
          fileServers = [
            { }
            {
              browse = true;
              paths = [ "/files/*" ];
            }
          ];
          extraConfig = ''
            redir /files /files/ permanent
            redir /private /private/ permanent
          '';
        };
      };
      virtualHosts = {
        "https://${domain}".extraConfig = ''
          handle_path /private/* {
            basic_auth {
              david $2b$05$9l2gtUS.pMa6brsBOfUl7eGOwVtifl0dbcEpg4mcr6CsG2Fk4Aqxi
            }
            root * /var/lib/caddy/private
            file_server browse
          }
        '';
      };
    };
  };
}
