# David's NixOS configs
Configuration files for my NixOS machines.

## Desktop
Devices: xiatian

### Installation:
1. Put device into setup mode by wiping the PK key
2. Install NixOS and enable flakes
3. Setup age key:
    ```
    mkdir -p /var/lib/sops-nix
    sudo nix-shell -p neovim --run "nvim /var/lib/sops-nix/key.txt"
    chmod 400 /var/lib/sops-nix/key.txt
    ```
4. Generate and enroll secure boot keys:
    ```
    sudo nix-shell -p sbctl --run "sbctl create-keys"
    sudo nix-shell -p sbctl --run "sbctl enroll-keys -m"
    ```
5. Deploy:
    ```
    nix-shell -p git --run "git clone https://github.com/ungeskriptet/nix-config.git"
    cd nix-config
    sudo nixos-rebuild boot --flake "path:.#<HOSTNAME>"
    sudo reboot
    ```

## Server
Devices: rpi5

### Services:
 - AdGuard Home
 - Caddy with LEGO for TLS certificates
 - ESPHome
 - Home Assistant
 - MollySocket (For Signal push notifications on degoogled Android phones)
 - Nextcloud
 - ntfy.sh (UnifiedPush provider)
 - [samsung-update-bot](https://github.com/samsung-sm8650/update-bot)
 - soju and gamja (IRC)
 - Sshwifty
 - Stalwart (E-Mail)
 - Vaultwarden
 - Wireguard
 - [yuribot](https://github.com/ungeskriptet/yuribot)

### Installation:
1. Generate the installer image (make sure to add your public SSH key into the flake):
    ```
    git clone https://github.com/nvmd/nixos-raspberrypi.git
    cd nixos-raspberrypi
    vim flake.nix
    sudo nix build ".#installerImages.rpi5"
    ```
2. Flash the image to a USB drive (preferred) or SD card:
    ```
    zstd -c -d result/sd-image/nixos-installer-rpi5-kernelboot.img.zst | pv -Yo /dev/sdX
    ```
3. Boot the Raspberry Pi and download this configuration:
    ```
    sudo -i
    nix-shell -p git
    git clone https://github.com/ungeskriptet/nix-config.git
    cd nix-config
    ```
4. Setup age key:
    ```
    mkdir -p /root/.config/sops/age
    vim /root/.config/sops/age/keys.txt
    chmod 400 /root/.config/sops/age/keys.txt
    ```
5. Edit secrets:
    ```
    nix-shell -p sops --run "EDITOR=vim sops secrets/secrets.yaml"
    ```
6. Deploy:
    ```
    nixos-rebuild boot --flake "path:.#rpi5"
    reboot
    ```
