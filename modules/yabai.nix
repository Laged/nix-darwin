{ config, lib, pkgs, ... }:

let
  cfg = config.programs.yabai;

  # Yabai config
  yabairc = pkgs.writeText "yabairc" ''
    #!/usr/bin/env sh
    # Yabai configuration - managed by nix-darwin
    # Requires SIP to be partially disabled for scripting addition

    # Load scripting addition (requires SIP disabled)
    yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
    sudo yabai --load-sa

    # ============================================================
    # GLOBAL SETTINGS
    # ============================================================
    # Binary space partitioning layout (like i3/sway)
    yabai -m config layout bsp

    # New window spawns to the right (vertical split) or bottom (horizontal split)
    yabai -m config window_placement second_child

    # Floating windows stay on top
    yabai -m config window_topmost off

    # Window opacity (requires SIP disabled)
    yabai -m config window_opacity on
    yabai -m config window_opacity_duration 0.0
    yabai -m config active_window_opacity 1.0
    yabai -m config normal_window_opacity 0.95

    # Window borders - Tokyo Night colors
    yabai -m config window_border on
    yabai -m config window_border_width 3
    yabai -m config active_window_border_color 0xff7aa2f7
    yabai -m config normal_window_border_color 0xff414868

    # Shadows (off for cleaner look)
    yabai -m config window_shadow off

    # Split ratio
    yabai -m config split_ratio 0.50
    yabai -m config auto_balance off

    # Mouse settings
    yabai -m config mouse_follows_focus on
    yabai -m config focus_follows_mouse autofocus
    yabai -m config mouse_modifier alt
    yabai -m config mouse_action1 move
    yabai -m config mouse_action2 resize
    yabai -m config mouse_drop_action swap

    # ============================================================
    # GAPS (like i3-gaps)
    # ============================================================
    yabai -m config top_padding 8
    yabai -m config bottom_padding 8
    yabai -m config left_padding 8
    yabai -m config right_padding 8
    yabai -m config window_gap 8

    # ============================================================
    # WINDOW RULES (floating for dialogs/utilities)
    # ============================================================
    # System apps
    yabai -m rule --add app="^System Preferences$" manage=off
    yabai -m rule --add app="^System Settings$" manage=off
    yabai -m rule --add app="^Finder$" manage=off
    yabai -m rule --add app="^Archive Utility$" manage=off
    yabai -m rule --add app="^Calculator$" manage=off
    yabai -m rule --add app="^Dictionary$" manage=off
    yabai -m rule --add app="^Activity Monitor$" manage=off
    yabai -m rule --add app="^Disk Utility$" manage=off
    yabai -m rule --add app="^System Information$" manage=off
    yabai -m rule --add app="^Preview$" manage=off

    # App Store and preferences windows
    yabai -m rule --add app="^App Store$" manage=off
    yabai -m rule --add title="^Preferences$" manage=off
    yabai -m rule --add title="^Settings$" manage=off

    echo "yabai configuration loaded"
  '';

  # skhd config (hotkey daemon - yabai doesn't have built-in hotkeys)
  skhdrc = pkgs.writeText "skhdrc" ''
    # skhd configuration for yabai - managed by nix-darwin
    # Keybindings match aerospace config for consistency

    # ============================================================
    # LAUNCH APPLICATIONS
    # ============================================================
    # alt-space: Alacritty, alt-enter: Ghostty
    alt - space : ~/.local/state/home-manager/gcroots/current-home/home-path/bin/alacritty
    alt - return : open -n /Applications/Ghostty.app
    alt - b : open -a "Arc"
    shift + alt - b : open -n -a "Arc"

    # Screenshot (interactive selection to clipboard)
    shift + alt - s : screencapture -ic

    # ============================================================
    # FOCUS (alt + hjkl)
    # ============================================================
    alt - h : yabai -m window --focus west
    alt - j : yabai -m window --focus south
    alt - k : yabai -m window --focus north
    alt - l : yabai -m window --focus east

    # ============================================================
    # MOVE WINDOWS (alt + shift + hjkl)
    # ============================================================
    shift + alt - h : yabai -m window --swap west
    shift + alt - j : yabai -m window --swap south
    shift + alt - k : yabai -m window --swap north
    shift + alt - l : yabai -m window --swap east

    # ============================================================
    # LAYOUT MANAGEMENT
    # ============================================================
    # Toggle fullscreen
    alt - f : yabai -m window --toggle zoom-fullscreen

    # Toggle native macOS fullscreen
    shift + alt - f : yabai -m window --toggle native-fullscreen

    # Toggle float and center window
    alt - t : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2

    # Rotate tree (like changing split orientation)
    alt - e : yabai -m space --rotate 90

    # Mirror tree
    alt - w : yabai -m space --mirror y-axis

    # Balance window sizes
    alt - 0x18 : yabai -m space --balance  # alt + =

    # Close focused window
    alt - q : yabai -m window --close

    # ============================================================
    # RESIZE MODE (hold alt + r, then hjkl)
    # ============================================================
    # Resize windows
    ctrl + alt - h : yabai -m window --resize left:-50:0; yabai -m window --resize right:-50:0
    ctrl + alt - j : yabai -m window --resize bottom:0:50; yabai -m window --resize top:0:50
    ctrl + alt - k : yabai -m window --resize top:0:-50; yabai -m window --resize bottom:0:-50
    ctrl + alt - l : yabai -m window --resize right:50:0; yabai -m window --resize left:50:0

    # ============================================================
    # WORKSPACE NAVIGATION (alt + number)
    # ============================================================
    alt - 1 : yabai -m space --focus 1
    alt - 2 : yabai -m space --focus 2
    alt - 3 : yabai -m space --focus 3
    alt - 4 : yabai -m space --focus 4
    alt - 5 : yabai -m space --focus 5
    alt - 6 : yabai -m space --focus 6
    alt - 7 : yabai -m space --focus 7
    alt - 8 : yabai -m space --focus 8
    alt - 9 : yabai -m space --focus 9
    alt - 0 : yabai -m space --focus 10

    # Workspace back and forth
    alt - tab : yabai -m space --focus recent

    # ============================================================
    # MOVE WINDOW TO WORKSPACE (alt + shift + number)
    # ============================================================
    shift + alt - 1 : yabai -m window --space 1; yabai -m space --focus 1
    shift + alt - 2 : yabai -m window --space 2; yabai -m space --focus 2
    shift + alt - 3 : yabai -m window --space 3; yabai -m space --focus 3
    shift + alt - 4 : yabai -m window --space 4; yabai -m space --focus 4
    shift + alt - 5 : yabai -m window --space 5; yabai -m space --focus 5
    shift + alt - 6 : yabai -m window --space 6; yabai -m space --focus 6
    shift + alt - 7 : yabai -m window --space 7; yabai -m space --focus 7
    shift + alt - 8 : yabai -m window --space 8; yabai -m space --focus 8
    shift + alt - 9 : yabai -m window --space 9; yabai -m space --focus 9
    shift + alt - 0 : yabai -m window --space 10; yabai -m space --focus 10

    # ============================================================
    # MOVE WORKSPACE TO MONITOR
    # ============================================================
    shift + alt - 0x2B : yabai -m space --display prev  # alt + shift + ,
    shift + alt - 0x2F : yabai -m space --display next  # alt + shift + .

    # ============================================================
    # SERVICE (reload config)
    # ============================================================
    shift + alt - c : yabai --restart-service; skhd --restart-service
  '';

  # Sudoers file for yabai scripting addition (no password needed)
  yabaiSudoers = pkgs.writeText "yabai-sudoers" ''
    ${config.system.primaryUser} ALL=(root) NOPASSWD: sha256:${builtins.hashFile "sha256" "${pkgs.yabai}/bin/yabai"} ${pkgs.yabai}/bin/yabai --load-sa
  '';

in {
  options.programs.yabai = {
    enable = lib.mkEnableOption "Yabai tiling window manager with skhd";
  };

  config = lib.mkIf cfg.enable {
    # Install yabai and skhd
    environment.systemPackages = with pkgs; [
      yabai
      skhd
    ];

    # Enable yabai and skhd services
    services.yabai = {
      enable = true;
      enableScriptingAddition = true;
      package = pkgs.yabai;
      config = {
        layout = "stack";
        window_placement = "second_child";
        window_origin_display = "focused";
        window_insertion_point = "focused";
        window_animation_duration = 0.0;
        window_animation_easing = "ease_out_circ";
        window_opacity = "on";
        window_opacity_duration = 0.0;
        active_window_opacity = 1.0;
        normal_window_opacity = 0.95;
        window_border = "on";
        window_border_width = 3;
        active_window_border_color = "0xff7aa2f7";
        normal_window_border_color = "0xff414868";
        window_shadow = "off";
        split_ratio = 0.50;
        auto_balance = "on";
        mouse_follows_focus = "on";
        focus_follows_mouse = "autofocus";
        mouse_modifier = "alt";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
        top_padding = 8;
        bottom_padding = 8;
        left_padding = 8;
        right_padding = 8;
        window_gap = 8;
      };
      extraConfig = ''
        # Signal to immediately balance on window creation
        yabai -m signal --add event=window_created action="yabai -m space --balance"

        # Window rules
        yabai -m rule --add app="^System Preferences$" manage=off
        yabai -m rule --add app="^System Settings$" manage=off
        yabai -m rule --add app="^Finder$" manage=off
        yabai -m rule --add app="^Archive Utility$" manage=off
        yabai -m rule --add app="^Calculator$" manage=off
        yabai -m rule --add app="^Activity Monitor$" manage=off
        yabai -m rule --add app="^Preview$" manage=off
        yabai -m rule --add app="^App Store$" manage=off
        yabai -m rule --add title="^Preferences$" manage=off
        yabai -m rule --add title="^Settings$" manage=off

        echo "yabai configuration loaded"
      '';
    };

    services.skhd = {
      enable = true;
      package = pkgs.skhd;
      skhdConfig = ''
        # skhd configuration for yabai - managed by nix-darwin
        # Keybindings match aerospace config for consistency

        # Launch Applications
        # Launch alacritty and immediately tile using native macOS shortcut
        alt - space : ~/.local/state/home-manager/gcroots/current-home/home-path/bin/alacritty & sleep 0.1 && osascript -e 'tell application "System Events" to key code 123 using {control down, fn down}'
        alt - return : open -n /Applications/Ghostty.app
        alt - b : open -a "Arc"
        shift + alt - b : open -n -a "Arc"
        shift + alt - s : screencapture -ic

        # Focus (alt + hjkl)
        alt - h : yabai -m window --focus west
        alt - j : yabai -m window --focus south
        alt - k : yabai -m window --focus north
        alt - l : yabai -m window --focus east

        # Move Windows (alt + shift + hjkl)
        shift + alt - h : yabai -m window --swap west
        shift + alt - j : yabai -m window --swap south
        shift + alt - k : yabai -m window --swap north
        shift + alt - l : yabai -m window --swap east

        # Layout
        alt - f : yabai -m window --toggle zoom-fullscreen
        shift + alt - f : yabai -m window --toggle native-fullscreen
        alt - t : yabai -m window --toggle float; yabai -m window --grid 4:4:1:1:2:2
        alt - e : yabai -m space --rotate 90
        alt - w : yabai -m space --mirror y-axis
        alt - 0x18 : yabai -m space --balance
        alt - q : yabai -m window --close

        # Resize (ctrl + alt + hjkl)
        ctrl + alt - h : yabai -m window --resize left:-50:0; yabai -m window --resize right:-50:0
        ctrl + alt - j : yabai -m window --resize bottom:0:50; yabai -m window --resize top:0:50
        ctrl + alt - k : yabai -m window --resize top:0:-50; yabai -m window --resize bottom:0:-50
        ctrl + alt - l : yabai -m window --resize right:50:0; yabai -m window --resize left:50:0

        # Workspaces (alt + number)
        alt - 1 : yabai -m space --focus 1
        alt - 2 : yabai -m space --focus 2
        alt - 3 : yabai -m space --focus 3
        alt - 4 : yabai -m space --focus 4
        alt - 5 : yabai -m space --focus 5
        alt - 6 : yabai -m space --focus 6
        alt - 7 : yabai -m space --focus 7
        alt - 8 : yabai -m space --focus 8
        alt - 9 : yabai -m space --focus 9
        alt - 0 : yabai -m space --focus 10
        alt - tab : yabai -m space --focus recent

        # Move to Workspace (alt + shift + number)
        shift + alt - 1 : yabai -m window --space 1; yabai -m space --focus 1
        shift + alt - 2 : yabai -m window --space 2; yabai -m space --focus 2
        shift + alt - 3 : yabai -m window --space 3; yabai -m space --focus 3
        shift + alt - 4 : yabai -m window --space 4; yabai -m space --focus 4
        shift + alt - 5 : yabai -m window --space 5; yabai -m space --focus 5
        shift + alt - 6 : yabai -m window --space 6; yabai -m space --focus 6
        shift + alt - 7 : yabai -m window --space 7; yabai -m space --focus 7
        shift + alt - 8 : yabai -m window --space 8; yabai -m space --focus 8
        shift + alt - 9 : yabai -m window --space 9; yabai -m space --focus 9
        shift + alt - 0 : yabai -m window --space 10; yabai -m space --focus 10

        # Move Workspace to Monitor
        shift + alt - 0x2B : yabai -m space --display prev
        shift + alt - 0x2F : yabai -m space --display next

        # Reload config
        shift + alt - c : yabai --restart-service; skhd --restart-service
      '';
    };

    # System defaults for tiling WM
    system.activationScripts.extraActivation.text = ''
      echo "Applying yabai-friendly system defaults..."

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

      # Disable space switching animation (important for yabai)
      defaults write com.apple.dock workspaces-swoosh-animation-off -bool true

      echo "System defaults applied - log out/in for full effect"
    '';
  };
}
