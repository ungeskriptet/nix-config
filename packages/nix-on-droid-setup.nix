{
  lib,
  writeShellScriptBin,
  git,
  openssh,
  ssh-to-age,
}:
writeShellScriptBin "nix-on-droid-setup" ''
  set -euo pipefail

  export PATH="$PATH:${
    lib.makeBinPath [
      git
      openssh
    ]
  }"
  export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"
  export NIX_SSHOPTS="-oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"

  mkdir -p ~/.ssh ~/.config/sops-nix

  echo "Paste decrypted Ed25519 SSH private key:"
  KEY=""
  while read -s line; do
    KEY+="$line"$'\n'
    [ "$line" = "-----END OPENSSH PRIVATE KEY-----" ] && break
  done

  # Key will later be encrypted by Home Manager
  echo "$KEY" > ~/.ssh/id_ed25519

  ${lib.getExe ssh-to-age} -private-key -o ~/.config/sops-nix/key.txt <<< "$KEY"

  chmod 600 ~/.ssh/id_ed25519 ~/.config/sops-nix/key.txt

  rm -rf ~/.config/nix-on-droid
  ${lib.getExe git} clone git@codeberg.org:ungeskriptet/nix-config.git ~/.config/nix-on-droid

  echo "Use rpi5 as build host?"
  while :; do
    read -p "[y/n]: " RPI5_BUILD
    if [ "$RPI5_BUILD" = "n" ]; then
      echo "Enter custom build host (leave blank to build locally):"
      read REMOTE_BUILDER
      break
    elif [ "$RPI5_BUILD" = "y" ]; then
      REMOTE_BUILDER="root@fd64::2"
      break
    fi
  done

  if [ -z "$REMOTE_BUILDER" ]; then
    nix-on-droid switch --flake ~/.config/nix-on-droid#nix-on-droid
  else
    nix-on-droid switch --flake ~/.config/nix-on-droid#nix-on-droid --builders "$REMOTE_BUILDER"
  fi
''
