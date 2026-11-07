{
  writeShellApplication,
  sops,
  ssh-to-age,
}:
writeShellApplication {
  name = "sops-edit";
  runtimeInputs = [
    sops
    ssh-to-age
  ];
  text = ''
    file="''${1##*/}"

    case "$file" in
      user-*.yaml)
        export SOPS_AGE_KEY_FILE="$HOME/.config/sops-nix/key.txt"
        ;;
      host-*.yaml)
        export SOPS_AGE_KEY_CMD="sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key"
        ;;
      *)
        echo "Invalid file"
        exit
    esac

    if ! (sops edit "$1" || [ $? -eq 200 ]); then
      unset SOPS_AGE_KEY_FILE
      export SOPS_AGE_KEY_CMD="ssh-to-age -private-key -i $HOME/.ssh/id_ed25519"
      sops edit "$1"
    fi
  '';
}
