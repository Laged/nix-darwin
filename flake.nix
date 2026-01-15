{
  description = "Declarative macOS system with nix-darwin + home-manager + stylix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    rust-overlay.url = "github:oxalica/rust-overlay";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs =
    inputs@{ self, nix-darwin, nixpkgs, home-manager, stylix, determinate, rust-overlay, llm-agents }:
    let
      username = "laged";
      system = "aarch64-darwin";

      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        nixpkgs.config.allowUnfree = true;
        nixpkgs.overlays = [ rust-overlay.overlays.default ];
        environment.systemPackages = let
          rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" "rust-analyzer" ];
          };
        in [
          pkgs.vim
          pkgs.bat
          pkgs.curl
          pkgs.eza
          pkgs.neofetch
          pkgs.nixfmt
          rust-toolchain
          pkgs.direnv
          pkgs.bun
          pkgs.ripgrep
          pkgs.fd
          pkgs.jq
          pkgs.fzf
          llm-agents.packages.${system}.claude-code
        ];

        # Fonts installed system-wide
        fonts.packages = with pkgs; [
          jetbrains-mono
          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          inter
          source-sans
        ];
        # Homebrew (for GUI apps not in nixpkgs)
        homebrew = {
          enable = true;
          global.lockfiles = true;
          casks = [
            "ghostty"
            "cursor"
            "firefox"
          ];
        };

        # Disable nix-darwin's nix management (Determinate manages it)
        nix.enable = false;

        # Enable alternative shell support in nix-darwin.
        programs.zsh.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Primary user for user-specific options (homebrew, etc.)
        system.primaryUser = "laged";

        # Enable sudo authentication with Touch ID.
        security.pam.services.sudo_local.touchIdAuth = true;

        # Configure direnv integration
        programs.direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        # Tiling window manager (aerospace, yabai, amethyst, or none)
        windowManager.type = "aerospace";

        # LLM development tools (Claude Code, Nix LSP)
        programs.llm.enable = true;
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Mattis-MacBook-Pro
      darwinConfigurations."Mattis-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { inherit inputs username; };
        modules = [
          configuration
          determinate.darwinModules.default
          ./modules/wm.nix
          ./modules/llm.nix

          # Stylix (auto-configures home-manager theming)
          stylix.darwinModules.stylix
          ./modules/theme.nix

          # Home Manager
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.${username} = import ./modules/home.nix;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Mattis-MacBook-Pro".pkgs;

      formatter.aarch64-darwin =
        nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
