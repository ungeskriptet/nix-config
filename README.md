# David's NixOS configs
Configuration files for my NixOS machines.

## Installation
Below are installation instructions for special hosts.

### nix-on-droid
1. Install Nix-on-Droid from [F-Droid](https://f-droid.org/packages/com.termux.nix/)
2. Launch the app and enable flakes during the setup
3. Execute the following command:
   ```
   nix run https://codeberg.org/ungeskriptet/nix-config/archive/master.tar.gz#nix-on-droid-setup
   ```
