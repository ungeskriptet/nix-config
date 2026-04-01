{ writeShellScriptBin }:
writeShellScriptBin "switch-nixos" ''
  help () {
    cat <<EOF
  Wrapper for nixos-rebuild

  Options:
  -f | --flake    Flake URL (Default: path:/etc/nixos#$(hostname))
  -t | --target   Deploy to remote host through SSH
  -h | --help     Show help and exit
  EOF
  }

  # Defaults
  target=""
  flake="path:/etc/nixos#$(hostname)"

  while [ $# -gt 0 ]; do
    case "$1" in
      --flake|-f) flake="$2"; shift 2 ;;
      --target|-t) target="--target-host $2"; shift 2 ;;
      --help|-h) help; exit ;;
      *) break ;;
    esac
  done

  if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Warning: Couldn't find ssh-agent socket."
    echo "nixos-rebuild might prompt for SSH key password"
  fi

  NIX_SSHOPTS=(
    "-oIdentityAgent=$SSH_AUTH_SOCK"
    "-oStrictHostKeyChecking=no"
    "-oUserKnownHostsFile=/dev/null"
  )

  NIX_SSHOPTS="''${NIXOS_SSHOPTS[*]}" nixos-rebuild \
    switch -L --flake $flake $target
''
