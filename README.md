# MacOS Dotfiles using Nix-Darwin and Home Manager

Based on https://gist.github.com/jmatsushita/5c50ef14b4b96cb24ae5268dab613050

## Installation
**Note:**
Currently my username `bnrwrr` is hardcoded in the config in multiple places.
You should replace these with your own username.  

[Install Nix](https://nixos.org/manual/nix/unstable/installation/installation.html)  
[Install Homebrew](https://brew.sh) for packages not in Nixpkg.  
Note: We manage Homebrew packages with Home Manager [config](./nix-darwin/home.nix) but need to install it separately.  
  
Copy this repo to `~/.config`  
For building the config the first time, run  
```sh
cd ~/.config/nix-darwin
nix build .#darwinConfigurations.macbook-air.system
./result/sw/bin/darwin-rebuild switch --flake .
```  
**Note:**  
`macbook-air.system` is the hostname of my system.  
You should replace it with your hostname in [flake.nix](./nix-darwin/flake.nix) and the command above.  
  
For future updates, you can use the alias `update` defined in the zsh config.
