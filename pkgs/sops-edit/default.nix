{
  writeShellApplication,
  keep-sorted,
  sops,
  ssh-to-age,
}:
writeShellApplication {
  name = "sops-edit";
  runtimeInputs = [
    keep-sorted
    sops
    ssh-to-age
  ];
  text = ''
    unset SOPS_AGE_KEY_FILE
    unset SOPS_AGE_KEY_CMD
    unset SOPS_AGE_KEY

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

    if ! (sops edit "$1" || [[ $? -eq 200 ]]); then
      decrypt () {
        read -srp "Password: " pass
        echo -n "$pass" |
          ssh-to-age -stdinpass -private-key -i "$HOME"/.ssh/id_ed25519
      }
      unset SOPS_AGE_KEY_FILE
      SOPS_AGE_KEY="$(decrypt)"
      export SOPS_AGE_KEY
      sops edit "$1" || [[ $? -eq 200 ]]
    fi

    add-keep-sorted-tags () {
      echo -n "# keep-sorted"
      echo " start block=yes"
      sops decrypt "$1"
      echo -n "# keep-sorted"
      echo " end"
    }
    readarray secrets < <(add-keep-sorted-tags "$1" | keep-sorted -)
    unset "secrets[0]"
    unset "secrets[-1]"
    IFS=
    # shellcheck disable=SC2094
    sops encrypt --filename-override "$1" <<<"''${secrets[*]}" > "$1"
  '';
}
