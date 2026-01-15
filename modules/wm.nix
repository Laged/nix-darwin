{ config, lib, pkgs, ... }:

# Window Manager selector module
# Allows choosing between aerospace, yabai, amethyst, or none

let
  cfg = config.windowManager;
in {
  imports = [
    ./aerospace.nix
    ./yabai.nix
    ./amethyst.nix
  ];

  options.windowManager = {
    type = lib.mkOption {
      type = lib.types.enum [ "aerospace" "yabai" "amethyst" "none" ];
      default = "none";
      description = ''
        Which tiling window manager to use.
        - aerospace: i3-like WM using Accessibility API (no SIP changes needed)
        - yabai: Advanced tiling WM with scripting addition (requires partial SIP disable for full features)
        - amethyst: xmonad-style tiling WM (no SIP changes needed)
        - none: No tiling window manager
      '';
    };
  };

  config = {
    # Enable the selected window manager
    programs.aerospace.enable = cfg.type == "aerospace";
    programs.yabai.enable = cfg.type == "yabai";
    programs.amethyst.enable = cfg.type == "amethyst";

    # Common notification about which WM is active
    system.activationScripts.wmNotify = lib.mkIf (cfg.type != "none") {
      text = ''
        echo "Window Manager: ${cfg.type} is configured"
      '';
    };
  };
}
