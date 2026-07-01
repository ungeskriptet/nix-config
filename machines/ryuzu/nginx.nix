{
  lib,
  pkgs,
  ...
}:
let
  streamHtml = ''
    <!DOCTYPE html>
    <html>
    <head>
      <title>Live Stream</title>
      <script src="https://cdn.jsdelivr.net/npm/hls.js@latest"></script>
    </head>
    <body>
    <video id="video" width="720" controls></video>
    <script>
        if(Hls.isSupported()) {
            var video = document.getElementById("video");
            var hls = new Hls();
            var host = window.location.host;
            var proto = window.location.protocol;
            hls.loadSource(proto + "//" + host + "/hls/live/index.m3u8");
            hls.attachMedia(video);
            hls.on(Hls.Events.MANIFEST_PARSED,function() {
                video.play();
            });
        }
    </script>
    </body>
    </html>
  '';
in
{
  config = {
    environment.etc."nginx/html/watch/stream.html".text = streamHtml;

    systemd = {
      tmpfiles.rules = [ "d /var/lib/nginx-rtmp/hls 0777 root root -" ];
      services.nginx = {
        wantedBy = lib.mkForce [ ];
        serviceConfig.ReadWritePaths = [ "/var/lib/nginx-rtmp/hls" ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8598 ];

    services.nginx = {
      enable = true;
      package = pkgs.nginxStable.override {
        modules = [ pkgs.nginxModules.rtmp ];
      };
      appendConfig = ''
        rtmp {
          server {
            listen [::1]:1935;
            application live {
              live on;
              hls on;
              hls_path /var/lib/nginx-rtmp/hls;
              hls_nested on;
              hls_fragment 1;
              hls_playlist_length 5;
            }
          }
        };
      '';
      recommendedGzipSettings = true;
      virtualHosts = {
        "_" = {
          serverName = "_";
          listen = [
            {
              addr = "[::]";
              port = 8598;
            }
            {
              addr = "0.0.0.0";
              port = 8598;
            }
          ];
          locations."/watch" = {
            root = "/etc/nginx/html";
            extraConfig = ''
              try_files $uri /watch/stream.html;
            '';
          };
          locations."/hls" = {
            root = "/var/lib/nginx-rtmp";
            extraConfig = ''
              types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
              }
              add_header Cache-Control no-cache;
              add_header Access-Control-Allow-Origin *;
            '';
          };
        };
      };
    };
  };
}
