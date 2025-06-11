{
  baseDomain = "david-w.eu";
  lanDomain = "fritz.box";
  routerIP = "192.168.64.1";

  sshPubKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP+HHP+nC6vrDwqEbTgiNhFnaqD3WEBgZMq7FUPWV0Ls main@bitwarden"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOyckAtDOO5eRG9xYOzRWLNnGtBCq/Om/sLPEFLBtT8 david@key4"
  ];

  rpi5 = {
    lanIP = "192.168.64.2";
    lanIPv6 = "fd64::2";
  };
}
