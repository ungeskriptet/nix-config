{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.nm-nsupdate;
  domain = config.networking.domain;
in
{
  options.services.nm-nsupdate = {
    enable = lib.mkEnableOption "automatic DNS updates for NetworkManager";
    user = lib.mkOption {
      type = lib.types.str;
      description = ''
        SSH user.
      '';
    };
    server = lib.mkOption {
      type = lib.types.str;
      description = ''
        SSH server IP or domain name.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    services.nm-nsupdate = {
      user = lib.mkDefault "nsupdate";
      server = lib.mkDefault domain;
    };
    sops.secrets."nm-nsupdate/privkey".owner = "root";
    systemd.services.NetworkManager-dispatcher.serviceConfig = {
      LoadCredential = [ ("privkey:" + config.sops.secrets."nm-nsupdate/privkey".path) ];
    };
    networking.networkmanager = {
      dispatcherScripts = [
        {
          source =
            let
              ip = lib.getExe' pkgs.iproute2 "ip";
              jq = lib.getExe' pkgs.jq "jq";
              ssh = lib.getExe' pkgs.openssh "ssh";
            in
            pkgs.writeText "nm-nsupdate" ''
              if [ "$2" != "up" ]; then
                exit
              fi
              get_addresses() {
                ${ip} --json a | ${jq} -r \
                  'map(
                     select(
                       .operstate == "UP"
                     ) | .addr_info | map(
                       select(
                         .scope == "global"
                       ) | select(
                         .family == "'"$1"'"
                       ) .local
                     )
                   ) | add | join(",")'
              }
              args=()
              ipv6=$(get_addresses inet6)
              ipv4=$(get_addresses inet)
              [[ -n "$ipv6" ]] && args+=(ipv6 "$ipv6")
              [[ -n "$ipv4" ]] && args+=(ipv4 "$ipv4")
              [[ ''${#args[@]} -gt 0 ]] && \
              ${ssh} \
                -F/dev/null \
                -i/run/credentials/NetworkManager-dispatcher.service/privkey \
                -oUserKnownHostsFile=/dev/null \
                -oStrictHostKeyChecking=false \
                -oBatchMode=yes \
                -oServerAliveInterval=15 \
                -oConnectTimeout=15 \
                -oTCPKeepAlive=all \
                '${cfg.user}@${cfg.server}' \
                -- "''${args[@]}"
            '';
          type = "basic";
        }
      ];
    };
  };
}
