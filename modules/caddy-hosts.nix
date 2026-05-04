{ lib, config, ... }:
let
  cfg = config.services.caddy;
  paths = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    description = "List of paths.";
    default = [ "*" ];
  };
  fileServerOptions = lib.types.submodule {
    options = {
      inherit paths;
      browse = lib.mkEnableOption "the directory listing";
    };
  };
  rootDirOptions = lib.types.submodule (
    { name, ... }:
    {
      options = {
        inherit paths;
        dir = lib.mkOption {
          type = lib.types.oneOf [
            lib.types.path
            lib.types.str
          ];
          description = "The directory to host.";
          default = name;
        };
      };
    }
  );
  reverseProxyOptions = lib.types.submodule (
    { name, ... }:
    {
      options = {
        inherit paths;
        address = lib.mkOption {
          type = lib.types.str;
          description = "The address to reverse proxy.";
          default = name;
        };
        insecureTLS = lib.mkEnableOption "insecure TLS";
        hostHeader = lib.mkOption {
          type = lib.types.str;
          description = ''
            The host header to pass to the upstream application.
          '';
          default = "";
        };
      };
    }
  );
  caddyHostOptions = lib.types.submodule (
    { name, ... }:
    {
      options = {
        fqdns = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "List of fully qualified domain names.";
          default = [ name ];
        };
        hostEntry = {
          ipv6 = lib.mkOption {
            type = lib.types.str;
            description = "IPv6 address for this host";
            default = "::1";
          };
          ipv4 = lib.mkOption {
            type = lib.types.str;
            description = "IPv4 address for this host";
            default = "127.0.0.1";
          };
        };
        enableTLS = lib.mkEnableOption "TLS" // {
          default = true;
        };
        lanOnly = {
          inherit paths;
          enable = lib.mkEnableOption "access only from LAN";
        };
        reverseProxies = lib.mkOption {
          type = lib.types.attrsOf reverseProxyOptions;
          description = "Attribute set of reverse proxies.";
          default = { };
        };
        basicAuth = {
          user = lib.mkOption {
            type = lib.types.str;
            description = "The user for basic auth.";
            default = "";
          };
          hash = lib.mkOption {
            type = lib.types.str;
            description = ''
              Hash for the basic auth user.
              Use `mkpasswd -m bcrypt` to generate the hash.
            '';
            default = "";
          };
        };
        rootDirs = lib.mkOption {
          type = lib.types.attrsOf rootDirOptions;
          description = "Attribute set of root directories.";
          default = { };
        };
        fileServer = lib.mkOption {
          type = lib.types.listOf fileServerOptions;
          description = "List of file servers.";
          default = [ ];
        };
        index = lib.mkOption {
          type = lib.types.str;
          description = "The default file to serve.";
          default = "";
        };
        extraConfig = lib.mkOption {
          type = lib.types.lines;
          description = "Additional configuration for this host.";
          default = "";
        };
      };
    }
  );
in
{
  imports = [ ./acme.nix ];

  options.services.caddy.hosts = lib.mkOption {
    description = "Attribute set of Caddy hosts.";
    default = { };
    type = lib.types.attrsOf caddyHostOptions;
  };

  config = {
    assertions = [
      {
        assertion = lib.all (x: (x.user != "" -> x.hash != "") && (x.hash != "" -> x.user != "")) (
          lib.mapAttrsToList (_: v: v.basicAuth) cfg.hosts
        );
        message = "Basic auth requires both user and hash to be set.";
      }
    ];
    networking.hosts = lib.mkMerge (
      lib.mapAttrsToList (
        _: host:
        lib.genAttrs [ host.hostEntry.ipv6 host.hostEntry.ipv4 ] (
          _: builtins.filter (x: x != "*.${config.networking.domain}") host.fqdns
        )
      ) cfg.hosts
    );

    services.caddy.virtualHosts = lib.mkMerge (
      lib.mapAttrsToList (
        _: host:
        let
          scheme = if host.enableTLS then "https://" else "http://";
          fqdns = lib.concatStringsSep ", " host.fqdns;
          mkMatcher =
            {
              name,
              paths,
              lanOnly ? false,
            }:
            ''
              @${name} {
                ${lib.concatStringsSep "\n" (map (path: "path ${path}") paths)}
                ${lib.optionalString lanOnly "not remote_ip private_ranges"}
              }
            '';
        in
        {
          "${scheme}${fqdns}".extraConfig = ''
            ${lib.optionalString host.enableTLS ''
              tls ${config.acme.tlsCert} ${config.acme.tlsKey}
            ''}
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _: v:
                let
                  name = lib.strings.sanitizeDerivationName v.address;
                in
                ''
                  ${mkMatcher {
                    inherit name;
                    paths = v.paths;
                  }}
                  reverse_proxy @${name} ${v.address} {
                    ${lib.optionalString (v.hostHeader != "") ''
                      header_up Host ${v.hostHeader}
                    ''}
                    ${lib.optionalString v.insecureTLS ''
                      transport http {
                        tls
                        tls_insecure_skip_verify
                      }
                    ''}
                  }
                ''
              ) host.reverseProxies
            )}
            ${lib.optionalString host.lanOnly.enable ''
              ${mkMatcher {
                name = "lan";
                paths = host.lanOnly.paths;
                lanOnly = true;
              }}
              respond @lan "Hi! sorry not allowed :(" 403
            ''}
            ${lib.optionalString (host.basicAuth.user != "" && host.basicAuth.hash != "") ''
              basic_auth {
                ${host.basicAuth.user} ${host.basicAuth.hash}
              }
            ''}
            ${lib.concatStringsSep "\n" (
              lib.mapAttrsToList (
                _: v:
                let
                  name = lib.strings.sanitizeDerivationName v.dir;
                in
                ''
                  ${mkMatcher {
                    inherit name;
                    paths = v.paths;
                  }}
                  root @${name} ${v.dir}
                ''
              ) host.rootDirs
            )}
            ${lib.concatStringsSep "\n" (
              map (
                x:
                let
                  index = toString (lib.lists.findFirstIndex (y: x == y) null host.fileServer);
                in
                ''
                  ${mkMatcher {
                    name = "file_server_paths_${index}";
                    paths = x.paths;
                  }}
                  file_server @file_server_paths_${index} ${lib.optionalString x.browse "browse"}
                ''
              ) host.fileServer
            )}
            ${lib.optionalString (host.index != "") ''
              try_files ${host.index}
            ''}
            ${host.extraConfig}
          '';
        }
      ) cfg.hosts
    );
  };
}
