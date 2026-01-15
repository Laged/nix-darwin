{ config, lib, pkgs, ... }:

let
  cfg = config.programs.aerospace;

  # Aerospace config (i3/sway-like tiling for macOS)
  aerospace-config = pkgs.writeText "aerospace.toml" ''
    # AeroSpace - i3/sway-like tiling window manager for macOS
    # Managed by nix-darwin

    # ============================================================
    # STARTUP & BEHAVIOR
    # ============================================================
    start-at-login = true

    # Run on startup: start window borders (JankyBorders) - Tokyo Night colors, square corners
    after-startup-command = [
        'exec-and-forget borders active_color=0xff7aa2f7 inactive_color=0xff414868 width=3.0 style=square'
    ]

    # Normalizations (like i3's default behavior)
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # Accordion layout padding (set to 0 to disable accordion indicators)
    accordion-padding = 30

    # Default layout for new workspaces
    default-root-container-layout = 'tiles'
    default-root-container-orientation = 'auto'

    # Mouse behavior
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    on-focus-changed = ['move-mouse window-lazy-center']

    # ============================================================
    # GAPS (like i3-gaps)
    # ============================================================
    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    outer.top = 8
    outer.right = 8

    # ============================================================
    # MAIN MODE KEYBINDINGS
    # ============================================================
    [mode.main.binding]

    # Disable macOS "hide application" shortcut (interferes with tiling)
    cmd-h = []

    # --- Launch Applications ---
    # cmd-alt-space: Alacritty, cmd-alt-enter: Ghostty, cmd-alt-b: Firefox
    cmd-alt-space = 'exec-and-forget open -n ~/.local/state/home-manager/gcroots/current-home/home-path/Applications/Alacritty.app'
    cmd-alt-enter = 'exec-and-forget open -n /Applications/Ghostty.app'
    cmd-alt-b = 'exec-and-forget open -n -a "Firefox"'

    # --- Screenshot (interactive selection to clipboard) ---
    cmd-alt-shift-s = 'exec-and-forget screencapture -ic'

    # --- Focus (cmd + alt + hjkl) ---
    cmd-alt-h = 'focus left'
    cmd-alt-j = 'focus down'
    cmd-alt-k = 'focus up'
    cmd-alt-l = 'focus right'

    # --- Move Windows (cmd + alt + shift + hjkl) ---
    cmd-alt-shift-h = 'move left'
    cmd-alt-shift-j = 'move down'
    cmd-alt-shift-k = 'move up'
    cmd-alt-shift-l = 'move right'

    # --- Join Windows (combine into container) ---
    # Use join-with instead of split (works with normalization enabled)
    cmd-alt-shift-v = 'join-with up'
    cmd-alt-shift-g = 'join-with left'

    # --- Layout Management ---
    cmd-alt-f = 'fullscreen'
    cmd-alt-shift-f = 'macos-native-fullscreen'
    cmd-alt-t = 'layout floating tiling'
    cmd-alt-e = 'layout tiles horizontal vertical'
    cmd-alt-w = 'layout accordion horizontal vertical'

    # --- Balance window sizes (make all windows equal) ---
    cmd-alt-equal = 'balance-sizes'

    # --- Close focused window ---
    cmd-alt-q = 'close'

    # --- Resize Mode (like i3) ---
    cmd-alt-r = 'mode resize'

    # --- Service Mode (for config reload, etc.) ---
    cmd-alt-shift-c = 'mode service'

    # --- Workspace Navigation (cmd + alt + number) ---
    cmd-alt-1 = 'workspace 1'
    cmd-alt-2 = 'workspace 2'
    cmd-alt-3 = 'workspace 3'
    cmd-alt-4 = 'workspace 4'
    cmd-alt-5 = 'workspace 5'
    cmd-alt-6 = 'workspace 6'
    cmd-alt-7 = 'workspace 7'
    cmd-alt-8 = 'workspace 8'
    cmd-alt-9 = 'workspace 9'
    cmd-alt-0 = 'workspace 10'

    # --- Workspace Back and Forth (like i3) ---
    cmd-alt-tab = 'workspace-back-and-forth'

    # --- Move Window to Workspace (cmd + alt + shift + number) ---
    cmd-alt-shift-1 = 'move-node-to-workspace 1'
    cmd-alt-shift-2 = 'move-node-to-workspace 2'
    cmd-alt-shift-3 = 'move-node-to-workspace 3'
    cmd-alt-shift-4 = 'move-node-to-workspace 4'
    cmd-alt-shift-5 = 'move-node-to-workspace 5'
    cmd-alt-shift-6 = 'move-node-to-workspace 6'
    cmd-alt-shift-7 = 'move-node-to-workspace 7'
    cmd-alt-shift-8 = 'move-node-to-workspace 8'
    cmd-alt-shift-9 = 'move-node-to-workspace 9'
    cmd-alt-shift-0 = 'move-node-to-workspace 10'

    # --- Move Workspace to Monitor ---
    cmd-alt-shift-comma = 'move-workspace-to-monitor prev'
    cmd-alt-shift-period = 'move-workspace-to-monitor next'

    # ============================================================
    # RESIZE MODE
    # ============================================================
    [mode.resize.binding]
    h = 'resize width -50'
    j = 'resize height +50'
    k = 'resize height -50'
    l = 'resize width +50'
    minus = 'resize smart -50'
    equal = 'resize smart +50'
    enter = 'mode main'
    esc = 'mode main'

    # ============================================================
    # SERVICE MODE (config management)
    # ============================================================
    [mode.service.binding]
    r = ['reload-config', 'mode main']
    esc = 'mode main'
    f = ['flatten-workspace-tree', 'mode main']
    b = ['balance-sizes', 'mode main']

    # ============================================================
    # WINDOW RULES (floating for dialogs/utilities)
    # ============================================================
    # Finder as floating
    [[on-window-detected]]
    if.app-id = 'com.apple.finder'
    run = 'layout floating'

    # System Preferences/Settings as floating
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.SystemPreferences'
    run = 'layout floating'
  '';

in {
  options.programs.aerospace = {
    enable = lib.mkEnableOption "Aerospace i3/sway-like tiling window manager";
  };

  config = lib.mkIf cfg.enable {
    # Install aerospace and JankyBorders via homebrew
    homebrew.taps = lib.mkAfter [ "nikitabobko/tap" "FelixKratz/formulae" ];
    homebrew.casks = lib.mkAfter [ "nikitabobko/tap/aerospace" ];
    homebrew.brews = lib.mkAfter [ "FelixKratz/formulae/borders" ];

    # Symlink aerospace config and apply system defaults
    system.activationScripts.extraActivation.text = ''
      echo "Setting up Aerospace..."
      PRIMARY_USER="${config.system.primaryUser}"
      USER_HOME="/Users/$PRIMARY_USER"
      CONFIG_DIR="$USER_HOME/.config/aerospace"

      sudo -u "$PRIMARY_USER" mkdir -p "$CONFIG_DIR"

      # Symlink config
      if [ -L "$CONFIG_DIR/aerospace.toml" ] || [ -f "$CONFIG_DIR/aerospace.toml" ]; then
        rm -f "$CONFIG_DIR/aerospace.toml"
      fi
      sudo -u "$PRIMARY_USER" ln -sf "${aerospace-config}" "$CONFIG_DIR/aerospace.toml"
      echo "Aerospace config installed at $CONFIG_DIR/aerospace.toml"

      # Reload Aerospace config if running
      if pgrep -x "AeroSpace" > /dev/null; then
        sudo -u "$PRIMARY_USER" /opt/homebrew/bin/aerospace reload-config || true
        echo "Aerospace config reloaded"
      fi

      # Apply recommended system defaults for better tiling experience
      echo "Applying Aerospace-friendly system defaults..."

      # Enable dragging windows from anywhere with ctrl+cmd
      defaults write -g NSWindowShouldDragOnGesture -bool true

      # Disable ALL window animations
      defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
      defaults write -g NSWindowResizeTime -float 0.001

      # Disable opening/closing window animations
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

      # Disable Spotlight/Finder search cmd+option+space shortcut (conflicts with Alacritty)
      # Must run as user, not root
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
      sudo -u "$PRIMARY_USER" defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"
      # Apply changes immediately
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

      echo "System defaults applied - log out/in for full effect"
    '';
  };
}
