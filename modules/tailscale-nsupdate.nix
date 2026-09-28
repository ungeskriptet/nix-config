{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.tailscale-nsupdate;
in
{
  options.services.tailscale-nsupdate = {
    enable = lib.mkEnableOption "automatic DNS updates for Tailscale";
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
    systemd.services.tailscale-nsupdate = {
      description = "Tailscale nsupdate";
      wantedBy = [ "multi-user.target" ];
      requires = [ config.systemd.services.tailscaled.name ];
      path = with pkgs; [
        dnsutils
        iproute2
        jq
      ];
      script = ''
        set -euo pipefail
        get_addresses() {
          case "$1" in
            inet) rr="A" ;;
            inet6) rr="AAAA" ;;
          esac
          addrs=$(ip --json a | jq -r 'map(
            select(.ifname | contains("tailscale0"))
          ) | .[] | .addr_info | map(
            select(.scope == "global") | select(.family == "'"$1"'")
          ).[].local')
          if [ -n "$addrs" ]; then
            echo "update delete ${cfg.fqdn} $rr"
          fi
          for addr in $addrs; do
            echo "update add ${cfg.fqdn} 600 $rr $addr"
          done
        }
        tsig_key=$(cat "$CREDENTIALS_DIRECTORY"/${cfg.fqdn}-nsupdate)
        ipv4=$(get_addresses inet)
        ipv6=$(get_addresses inet6)
        if [ -n "$ipv4" -o -n "$ipv6" ]; then
          echo "server ${cfg.nameServer}
        $ipv6
        $ipv4
        " | nsupdate -y "$tsig_key"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        LoadCredential = [ "${cfg.fqdn}-nsupdate:${cfg.tsigKeyFile}" ];
      };
    };
  };
}
