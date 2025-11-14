{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.programs.silverfort;
  selfPkgs = inputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.programs.silverfort = {
    enable = lib.mkEnableOption "Silverfort";
  };
  config = lib.mkIf cfg.enable {

    environment.systemPackages = [ selfPkgs.silverfort-client ];

    security.pki.certificates = [
      ''
        -----BEGIN CERTIFICATE-----
        MIIJCzCCBvOgAwIBAgITFQAHQpYk44QVLtDO0gAAAAdCljANBgkqhkiG9w0BAQsF
        ADBIMRMwEQYKCZImiZPyLGQBGRYDbmV0MRcwFQYKCZImiZPyLGQBGRYHbGV4LWNv
        bTEYMBYGA1UEAxMPTGV4Q29tLVN1YkNBLUlTMB4XDTI1MDYwNjA3NDUxNVoXDTI2
        MDYwNjA3NDUxNVowgY8xCzAJBgNVBAYTAkRFMREwDwYDVQQIEwhCYXZhcmlpYTEP
        MA0GA1UEBxMGTXVuaWNoMSQwIgYDVQQKExtCRUxFTlVTIExPQiBJbmZvcm1hdGlj
        IEdtYkgxGDAWBgNVBAsTD0ludGVybmFsU2VydmljZTEcMBoGA1UEAxMTc2Rtcy1w
        ci5sZXgtY29tLm5ldDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAMxQ
        6LbCTD1MAUqTYTfNswLZV3bVVyko+FlDDgyKVpGY6QqGIXDdiD1aG13G1a1REwp2
        S+9qIx3tRK9SEdgDpf7PFWM8Ma4EqNINbaCBiSpsbFsA5BPR2BIyQN0CR6SV9t6H
        JfEJCTq+eH48tyMWqL/4JFLdbNm1/JROB/4yTtMBDpdX7H8fugrQeSVqQCo/mbB+
        UvUrxEjC056yF9mSjcqxZTUBGkYDP+laTyOzQI9nliPo3v+bXIRqssajSnSbhxgx
        BEnwb4uZcNBAwvShQPTx3mY5nMkBPnk3gYFlE0FttqhihIdX3Lc4K6U54UVWXKmx
        c5ow3yRsTTakkv4ZTIwGh1ZkoCjOHVO4W3NMmBx40zBvTaOUl3bxySPmFcQVqw5R
        hN17B47qP1EsrdfHaFL0TjpcVHmrQ3aAz4k+dX4rApkZkwjSmMzQ8smyNgMuVbFO
        ARZ6ttmW1fQxxTcr/tu9IgOIvK95c2hglp3KJioQrdtZaJ24blcDH3bjZt/j8sYR
        xOWatJoIWi72ktXCCM/KkusfeKrui+b/5tBSvGkSHRgQYae6DMa64GssPRQ5EemI
        b1WvJOW1Q8JSnGeSo1eupDla4QvHmREGIfxu3qWWce0K0oyoMoU4J4hFBC6uI+vF
        7/uIWwNx4C0MKhh4K7AkhUhwLYyaGvANC/mGki3VAgMBAAGjggOkMIIDoDCBmAYD
        VR0RBIGQMIGNghNzZG1zLXByLmxleC1jb20ubmV0ghZzZG1zLXByLTAxLmxleC1j
        b20ubmV0ghZzZG1zLXByLTAyLmxleC1jb20ubmV0ghRzZG1zLWRldi5sZXgtY29t
        Lm5ldIIXc2Rtcy1kZXYtMDEubGV4LWNvbS5uZXSCF3NkbXMtZGV2LTAyLmxleC1j
        b20ubmV0MB0GA1UdDgQWBBT1ebauc/RtDh4sc0SO1ELXMCN4NzAfBgNVHSMEGDAW
        gBRv0/Ape4+Kq39xBdHczMjZHqaAdzCCAQsGA1UdHwSCAQIwgf8wgfyggfmggfaG
        gbtsZGFwOi8vL0NOPUxleENvbS1TdWJDQS1JUyxDTj1hZGNlcnQtaXMtMDEsQ049
        Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv
        bmZpZ3VyYXRpb24sREM9bGV4LWNvbSxEQz1uZXQ/Y2VydGlmaWNhdGVSZXZvY2F0
        aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50hjZo
        dHRwOi8vYWRjZXJ0LWV4dC5sZXgtY29tLm5ldC9jZXJ0L0xleENvbS1TdWJDQS1J
        Uy5jcmwwggEgBggrBgEFBQcBAQSCARIwggEOMIGuBggrBgEFBQcwAoaBoWxkYXA6
        Ly8vQ049TGV4Q29tLVN1YkNBLUlTLENOPUFJQSxDTj1QdWJsaWMlMjBLZXklMjBT
        ZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9uLERDPWxleC1jb20s
        REM9bmV0P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0
        aW9uQXV0aG9yaXR5MFsGCCsGAQUFBzAChk9odHRwOi8vYWRjZXJ0LWV4dC5sZXgt
        Y29tLm5ldC9jZXJ0L2FkY2VydC1pcy0wMS5sZXgtY29tLm5ldF9MZXhDb20tU3Vi
        Q0EtSVMuY3J0MAsGA1UdDwQEAwIFoDA7BgkrBgEEAYI3FQcELjAsBiQrBgEEAYI3
        FQiFquJFgYq/AtWfLIOPuQuHpPU1NOGcUIbcvhICAWQCARcwHQYDVR0lBBYwFAYI
        KwYBBQUHAwIGCCsGAQUFBwMBMCcGCSsGAQQBgjcVCgQaMBgwCgYIKwYBBQUHAwIw
        CgYIKwYBBQUHAwEwDQYJKoZIhvcNAQELBQADggIBAHe5cmIVvJ0JOBu5EdwWQLbw
        FtIgKT62XkMkmNSSxovn93Xl+mvYUqYkYUO8brv94P4irBNmlRNYWXia0zx9Zztf
        iuP/bBUExn+TKetItxoTS7Ip+uovXH/66q7SFmwfNwk1fSnbYg+LA2nrRcctpexq
        8CLI8ba8tly0R6RGCTtyLrV7aFQ6IKEzG6VgM7Bw1HRRWyECaP4oz464O/ElrjpT
        owxVeg7/FDHA0dbr+9DT3bJAhpwyh/xTQBFTIoPTcNG2npbqMm1ZMbjZETDh2JyK
        4QzcorfieF6NDe9Fb24HGt45Uecu+GMrw+XdigSmXufuS4VF5TtZNtZjWLqsF07A
        wmAUeVbR0aJsP56segTcH0yAQ8Skb9v2ChI5YIQoxHnXFHXmQ/dU8z/MhSJXBasU
        Kt109PYlE2hzoZ5JoV8qBNY3l6sFvD73vpsQh2WfDhoko5DMC4AxRDnpm0XkstVe
        80dEOOdB/4NsHjPvnTxKs7NIsV0O9KdmHkzh5/NuGpi8RGUBFyFhCNiWD1IEJqMS
        +1EPu898jwyBmjJ+qkpPLQzeihPh6ph2LyTLsbJOO7S/EjDn5mWJxE/InFxr4dEB
        wKdX5hYFlUge0skmESgc4X99SXVW32FaGtWf3W/2jmDaqomoZ8TJcK4xDnP+ZMiu
        l5QhCGXdZQcqgGYegvl8
        -----END CERTIFICATE-----
      ''
    ];
  };
}
