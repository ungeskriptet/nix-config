{ config, inputs, lib, pkgs, vars, ... }:

{
  sops = {
    secrets."users/david".neededForUsers = true;
    secrets."users/david".owner = "root";
  };

  users = {
    mutableUsers = false;
    users.david = {
      isNormalUser = true;
      description = "David";
      extraGroups =
        [ "wheel" ]
        ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
        ++ lib.optionals config.programs.wireshark.enable [ "wireshark" ]
        ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirt" ];
      hashedPasswordFile = config.sops.secrets."users/david".path;
      openssh.authorizedKeys.keys = vars.sshPubKeys;
    } // lib.optionalAttrs config.programs.zsh.enable { shell = pkgs.zsh; };
    users.root = {
      openssh.authorizedKeys.keys = vars.sshPubKeys;
    } // lib.optionalAttrs config.programs.zsh.enable { shell = pkgs.zsh; };
  };
}
