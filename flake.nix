{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        # flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, rust-overlay }:
  let
    rustpkgs = import nixpkgs {
      inherit localSystem;
      overlays = [ (import rust-overlay) ];
    };
    rustToolchain = rustpkgs.pkgsBuildHost.rust-bin.nightly.latest.default.override {
      targets = [
        "aarch64-unknown-linux-gnu"
      ];
      extensions = [
        "complete"
      ];
    };
    configuration = { pkgs, my-neovim, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      # or `nix repl -f '<nixpkgs>'`
      environment.systemPackages =
        [
          pkgs.vim
          (pkgs.callPackage ./neovim/neovim.nix {})
          pkgs.nerd-fonts.monoid
          pkgs.kitty
          pkgs.diceware

        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Orvars-MacBook-Air
    darwinConfigurations."Orvars-MacBook-Air" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
