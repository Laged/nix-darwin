# Stylix theme configuration (Darwin level)
# Chalk theme - soft pastel dark theme
{ config, pkgs, ... }:

let
  # Base16 color scheme - referenced by wallpaper generator
  colors = {
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

  # Wallpaper generator script - detects resolution and creates 4x4 grid
  wallpaperGenerator = pkgs.writeShellScript "generate-wallpaper" ''
    set -e
    OUTPUT="$1"

    # Get total display dimensions (handles multiple monitors)
    read WIDTH HEIGHT <<< $(${pkgs.python3}/bin/python3 -c "
import subprocess, re
out = subprocess.check_output(['system_profiler', 'SPDisplaysDataType']).decode()
resolutions = re.findall(r'Resolution: (\d+) x (\d+)', out)
if resolutions:
    # Sum widths, use max height (for side-by-side monitors)
    total_w = sum(int(r[0]) for r in resolutions)
    max_h = max(int(r[1]) for r in resolutions)
    print(total_w, max_h)
else:
    print(3840, 2160)  # fallback
")

    # Calculate grid dimensions (fit to height, center horizontally)
    PAD=60          # outer padding
    GAP=24          # gap between squares
    GRID_INNER=$((HEIGHT - 2 * PAD))  # available space for squares + gaps
    SQUARE=$(( (GRID_INNER - 3 * GAP) / 4 ))  # size of each square
    GRID_SIZE=$((4 * SQUARE + 3 * GAP + 2 * PAD))  # total grid size
    X_OFF=$(( (WIDTH - GRID_SIZE) / 2 + PAD ))  # x offset to center
    Y_OFF=$PAD  # y offset (top padding)

    # Generate rectangles for each color
    DRAWS=""
    COLORS=("${colors.base00}" "${colors.base01}" "${colors.base02}" "${colors.base03}" \
            "${colors.base04}" "${colors.base05}" "${colors.base06}" "${colors.base07}" \
            "${colors.base08}" "${colors.base09}" "${colors.base0A}" "${colors.base0B}" \
            "${colors.base0C}" "${colors.base0D}" "${colors.base0E}" "${colors.base0F}")

    for i in {0..15}; do
      ROW=$((i / 4))
      COL=$((i % 4))
      X1=$((X_OFF + COL * (SQUARE + GAP)))
      Y1=$((Y_OFF + ROW * (SQUARE + GAP)))
      X2=$((X1 + SQUARE - 1))
      Y2=$((Y1 + SQUARE - 1))
      DRAWS="$DRAWS -fill '#''${COLORS[$i]}' -draw 'rectangle $X1,$Y1 $X2,$Y2'"
    done

    eval "${pkgs.imagemagick}/bin/magick -size ''${WIDTH}x''${HEIGHT} xc:black $DRAWS '$OUTPUT'"
  '';

  # Static fallback for stylix (generated at build time)
  wallpaperStatic = pkgs.runCommand "theme-wallpaper.png" { buildInputs = [ pkgs.imagemagick ]; } ''
    magick -size 3840x2160 xc:black \
      -fill '#${colors.base00}' -draw "rectangle 840,75 1319,554" \
      -fill '#${colors.base01}' -draw "rectangle 1350,75 1829,554" \
      -fill '#${colors.base02}' -draw "rectangle 1860,75 2339,554" \
      -fill '#${colors.base03}' -draw "rectangle 2370,75 2849,554" \
      -fill '#${colors.base04}' -draw "rectangle 840,585 1319,1064" \
      -fill '#${colors.base05}' -draw "rectangle 1350,585 1829,1064" \
      -fill '#${colors.base06}' -draw "rectangle 1860,585 2339,1064" \
      -fill '#${colors.base07}' -draw "rectangle 2370,585 2849,1064" \
      -fill '#${colors.base08}' -draw "rectangle 840,1095 1319,1574" \
      -fill '#${colors.base09}' -draw "rectangle 1350,1095 1829,1574" \
      -fill '#${colors.base0A}' -draw "rectangle 1860,1095 2339,1574" \
      -fill '#${colors.base0B}' -draw "rectangle 2370,1095 2849,1574" \
      -fill '#${colors.base0C}' -draw "rectangle 840,1605 1319,2084" \
      -fill '#${colors.base0D}' -draw "rectangle 1350,1605 1829,2084" \
      -fill '#${colors.base0E}' -draw "rectangle 1860,1605 2339,2084" \
      -fill '#${colors.base0F}' -draw "rectangle 2370,1605 2849,2084" \
      $out
  '';
in {
  stylix = {
    enable = true;

    # Use the color scheme
    base16Scheme = colors;

    # Static wallpaper for stylix (dynamic one set in activation)
    image = wallpaperStatic;

    polarity = "dark";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
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

  # Generate and set macOS desktop wallpaper dynamically based on resolution
  system.activationScripts.postActivation.text = ''
    echo "Generating wallpaper for current display resolution..."
    WALLPAPER_PATH="/tmp/stylix-wallpaper.png"
    ${wallpaperGenerator} "$WALLPAPER_PATH"
    echo "Setting desktop wallpaper..."
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_PATH\" as POSIX file"
  '';
}
