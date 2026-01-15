# Stylix theme configuration (Darwin level)
# Chalk theme - soft pastel dark theme
{ pkgs, ... }:

{
  stylix = {
    enable = true;

    # Chalk - muted pastel dark scheme
    base16Scheme = {
      base00 = "151515"; # Background
      base01 = "202020"; # Lighter background
      base02 = "303030"; # Selection
      base03 = "505050"; # Comments
      base04 = "b0b0b0"; # Dark foreground
      base05 = "d0d0d0"; # Foreground
      base06 = "e0e0e0"; # Light foreground
      base07 = "f5f5f5"; # Lightest foreground
      base08 = "fb9fb1"; # Red (soft pink)
      base09 = "eda987"; # Orange (peach)
      base0A = "ddb26f"; # Yellow (gold)
      base0B = "acc267"; # Green (olive)
      base0C = "12cfc0"; # Cyan (teal)
      base0D = "6fc2ef"; # Blue (sky)
      base0E = "e1a3ee"; # Purple (lavender)
      base0F = "deaf8f"; # Brown (tan)
    };

    # Required image - generate a solid color
    image = pkgs.runCommand "chalk-wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
      magick -size 1920x1080 xc:#151515 $out
    '';

    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        terminal = 14;
        applications = 13;
      };
    };
  };
}
