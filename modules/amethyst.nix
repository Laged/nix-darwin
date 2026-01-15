{ config, lib, pkgs, ... }:

let
  cfg = config.programs.amethyst;

  # Amethyst config (JSON format)
  amethystConfig = pkgs.writeText "amethyst.json" (builtins.toJSON {
    # Modifier key: option (alt)
    mod1 = ["option"];
    mod2 = ["option" "shift"];

    # Layouts - cycle through these
    layouts = ["tall" "wide" "bsp" "fullscreen"];

    # Window margins/gaps
    window-margins = true;
    window-margin-size = 8;
    screen-padding-top = 8;
    screen-padding-bottom = 8;
    screen-padding-left = 8;
    screen-padding-right = 8;

    # Behavior
    float-small-windows = true;
    mouse-follows-focus = true;
    focus-follows-mouse = false;
    mouse-swaps-windows = true;
    mouse-resizes-windows = true;
    enables-layout-hud = true;
    enables-layout-hud-on-space-change = true;
    new-windows-to-main = false;
    follow-space-thrown-windows = true;

    # Floating apps (don't tile these)
    floating = [
      "com.apple.finder"
      "com.apple.systempreferences"
      "com.apple.SystemPreferences"
      "com.apple.calculator"
      "com.apple.ActivityMonitor"
      "com.apple.Preview"
      "com.apple.archiveutility"
      "com.apple.AppStore"
    ];

    # Window border (Amethyst 0.21+)
    # Colors need to be in hex format: 0xAARRGGBB
    window-border = true;
    window-border-width = 3;
    active-window-border-color = "0xFF7aa2f7";
    inactive-window-border-color = "0xFF414868";
  });

in {
  options.programs.amethyst = {
    enable = lib.mkEnableOption "Amethyst tiling window manager";
  };

  config = lib.mkIf cfg.enable {
    # Install Amethyst via Homebrew (not in nixpkgs)
    homebrew.casks = lib.mkAfter ["amethyst"];

    # skhd for app launching shortcuts (Amethyst doesn't have this)
    environment.systemPackages = [ pkgs.skhd ];

    services.skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # App launchers (Amethyst handles tiling)
        alt - space : ~/.local/state/home-manager/gcroots/current-home/home-path/bin/alacritty
        alt - return : open -n /Applications/Ghostty.app
        alt - b : open -a "Arc"
        shift + alt - b : open -n -a "Arc"
        shift + alt - s : screencapture -ic
      '';
    };

    # Copy config to user's home
    system.activationScripts.extraActivation.text = ''
      echo "Setting up Amethyst..."
      PRIMARY_USER="${config.system.primaryUser}"
      USER_HOME="/Users/$PRIMARY_USER"
      CONFIG_DIR="$USER_HOME/.amethyst"

      sudo -u "$PRIMARY_USER" mkdir -p "$CONFIG_DIR"

      # Copy config
      if [ -f "$USER_HOME/.amethyst.json" ]; then
        rm -f "$USER_HOME/.amethyst.json"
      fi
      sudo -u "$PRIMARY_USER" cp "${amethystConfig}" "$USER_HOME/.amethyst.json"
      echo "Amethyst config installed at $USER_HOME/.amethyst.json"

      # Apply system defaults for better tiling experience
      echo "Applying tiling-friendly system defaults..."

      # Enable dragging windows from anywhere with ctrl+cmd
      defaults write -g NSWindowShouldDragOnGesture -bool true

      # Disable ALL window animations
      defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
      defaults write -g NSWindowResizeTime -float 0.001
      defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

      # Speed up Mission Control animations
      defaults write com.apple.dock expose-animation-duration -float 0.1

      # Disable Dock animations
      defaults write com.apple.dock autohide-time-modifier -float 0
      defaults write com.apple.dock autohide-delay -float 0
      defaults write com.apple.dock launchanim -bool false

      # Disable Finder animations
      defaults write com.apple.finder DisableAllAnimations -bool true

      # Reduce motion globally
      defaults write com.apple.universalaccess reduceMotion -bool true

      # Disable smooth scrolling (snappier feel)
      defaults write -g NSScrollAnimationEnabled -bool false

      echo "System defaults applied - log out/in for full effect"
    '';
  };
}
