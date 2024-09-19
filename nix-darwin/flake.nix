{
  description = "Binary's darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Environment/system management
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  # HACK: remove `mac-app-util` when https://github.com/nix-community/home-manager/issues/1341 gets fixed
  outputs = { self, darwin, nixpkgs, nixpkgs-unstable, home-manager, mac-app-util, ... }@inputs:
    let

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ singleton (
          # Sub in x86 version of packages that don't build on Apple Silicon yet
          final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            inherit (final.rosetta)
              niv;
          })
        );
      };
    in
    {
      # My `nix-darwin` configs

      darwinConfigurations = rec {
        macbook-air = darwinSystem {
          system = "aarch64-darwin";
          modules = attrValues self.darwinModules ++ [

            # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
            mac-app-util.darwinModules.default

            # Main `nix-darwin` config
            ./configuration.nix
            # `home-manager` module
            home-manager.darwinModules.home-manager
            {
              nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.bnrwrr.imports = [

                # HACK: remove when https://github.com/nix-community/home-manager/issues/1341 gets fixed
                mac-app-util.homeManagerModules.default

                ./home.nix
              ];
            }
          ];
        };
      };

      # Overlays --------------------------------------------------------------- {{{

      overlays = {
        # Overlays to add various packages into package set
        # Overlay useful on Macs with Apple Silicon
        apple-silicon = final: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          rosetta = import inputs.nixpkgs-unstable {
            system = "x86_64-darwin"; inherit (nixpkgsConfig) config;
          };
        };

        unstable-packages = final: prev: {
          unstable = import nixpkgs-unstable {
            system = prev.system;
          };
        };
      };

      # My `nix-darwin` modules that are pending upstream, or patched versions waiting on upstream
      # fixes.
      darwinModules = { };
    };
}
