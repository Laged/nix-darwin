{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0.1";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, determinate }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.vim
            pkgs.bat
            pkgs.curl
            pkgs.eza
            pkgs.neofetch
            pkgs.nixpkgs-fmt
          ];
        # Homebrew
        homebrew = {
          enable = true;

          taps = [ ];
          brews = [ ];
          casks = [ ];
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        programs.zsh.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Enable sudo authentication with Touch ID.
        security.pam.enableSudoTouchIdAuth = true;
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Mattis-MacBook-Pro
      darwinConfigurations."Mattis-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [ configuration determinate.darwinModules.default ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Mattis-MacBook-Pro".pkgs;

      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
