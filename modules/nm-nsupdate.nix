{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.nm-nsupdate;
in
{
  options.services.nm-nsupdate = {
    enable = lib.mkEnableOption "automatic DNS updates for NetworkManager";
    nameServer = lib.mkOption {
      type = lib.types.str;
      description = "Nameserver to use.";
    };
    fqdn = lib.mkOption {
      type = lib.types.str;
      description = "FQDN to update.";
    };
    tsigKeyFile = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to a file containing the TSIG key.
        Format should be `[hmac:]keyname:secret`.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.NetworkManager-dispatcher.serviceConfig = {
      LoadCredential = [ "${cfg.fqdn}-nsupdate:${cfg.tsigKeyFile}" ];
    };
    networking.networkmanager = {
      enable = true;
      dispatcherScripts = [
        {
          source =
            let
              jq = lib.getExe pkgs.jq;
              nsupdate = lib.getExe' pkgs.dnsutils "nsupdate";
            in
            pkgs.writeText "nm-nsupdate" ''
              if [ "$2" != "up" ]; then
                exit
              fi
              get_addresses() {
                case "$1" in
                  inet) rr="A" ;;
                  inet6) rr="AAAA" ;;
                esac
                addrs=$(ip --json a | ${jq} -r \
                  'map(
                     .addr_info | map(
                       select(
                         .scope == "global"
                       ) | select(
                         .family == "'"$1"'"
                       ) .local
                     )
                   ) | add | add(.[] + " ") // empty')
                if [ -n "$addrs" ]; then
                  echo "update delete ${cfg.fqdn} $rr"
                fi
                for addr in $addrs; do
                  echo "update add ${cfg.fqdn} 600 $rr $addr"
                done
              }
              tsig_key=$(cat /run/credentials/NetworkManager-dispatcher.service/${cfg.fqdn}-nsupdate)
              ipv4=$(get_addresses inet)
              ipv6=$(get_addresses inet6)
              if [ -n "$ipv4" -o -n "$ipv6" ]; then
                echo "server ${cfg.nameServer}
              $ipv6
              $ipv4
              " | ${nsupdate} -y "$tsig_key"
              fi
            '';
          type = "basic";
        }
      ];
    };
  };
}
