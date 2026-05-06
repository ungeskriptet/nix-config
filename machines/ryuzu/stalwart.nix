{
  pkgs,
  inputs,
  ...
}:
{
  disabledModules = [ "services/mail/stalwart.nix" ];
  imports = [ ../../modules/stalwart.nix ];

  services.stalwart = {
    enable = true;
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.stalwart;
    recoveryMode = {
      forceEnable = false;
      user = "recovery-admin";
      passwordFile = pkgs.writeText "stalwart-password" "12345678";
    };
    datastore = {
      "@type" = "Sqlite";
      path = "/var/lib/stalwart/sqlite.db";
    };
    plan = {
      enableDefaultPlan = true;
      sequence = [
        {
          "@type" = "destroy";
          object = "Domain";
        }
        {
          "@type" = "destroy";
          object = "Account";
        }
        {
          "@type" = "destroy";
          object = "DkimSignature";
        }
        {
          "@type" = "create";
          object = "Domain";
          value.dom-a.name = "example.org";
        }
        {
          "@type" = "create";
          object = "Account";
          value = {
            restore-1 = {
              "@type" = "User";
              credentials = {
                "0" = {
                  "@type" = "Password";
                  secret = "$argon2id$v=19$m=19456,t=2,p=1$YUVTU2xQSFJPNXRtYVl4aFNCVzRHVUxh$cSWLVQ2GW+odnlcArxhMq5KX+nNPXbiGPsVojGkl1lk";
                };
              };
              domainId = "#dom-a";
              name = "admin";
              roles."@type" = "Admin";
            };
          };
        }
      ];
    };
  };
}
