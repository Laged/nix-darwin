# Home Manager configuration
# Manages user-level dotfiles and applications
{ config, pkgs, lib, ... }:

let
  username = "laged";
  # Stylix colors for Firefox userChrome (Stylix doesn't generate userChrome)
  colors = config.lib.stylix.colors.withHashtag;
in {
  # Stylix auto-enables most targets when programs are enabled
  # Firefox needs profile names specified
  stylix.targets.firefox.profileNames = [ "default" ];

  home = {
    username = username;
    homeDirectory = lib.mkForce "/Users/${username}";
    stateVersion = "24.05";

    # Suppress "Last login" message in terminal
    file.".hushlogin".text = "";

    # User packages (in addition to system packages)
    packages = with pkgs; [
      # Development tools
      gh           # GitHub CLI
      lazygit      # Terminal UI for git
      htop         # Process viewer
      tree         # Directory listing
      wget         # File download

      # Modern CLI tools
      zoxide       # Smarter cd
      starship     # Cross-shell prompt
    ];
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  # ============================================
  # Ghostty (Homebrew-installed, Stylix auto-themes)
  # ============================================
  programs.ghostty = {
    enable = true;
    package = null; # Use Homebrew-installed Ghostty
    # Stylix auto-generates colors, fonts, opacity
    settings = {
      window-decoration = false;
      window-padding-x = 12;
      window-padding-y = 12;
      macos-titlebar-style = "hidden";
      cursor-style = "block";
      cursor-style-blink = false;
      copy-on-select = true;
    };
  };

  # ============================================
  # Firefox Browser
  # ============================================
  programs.firefox = {
    enable = true;
    package = null; # Use Homebrew-installed Firefox

    # Install extensions via policies (works with Homebrew Firefox)
    policies = {
      ExtensionSettings = {
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          installation_mode = "force_installed";
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
        };
      };
    };

    profiles.default = {
      isDefault = true;

      # Firefox settings - minimal UI
      settings = {
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Homepage & new tab = DuckDuckGo start page
        "browser.startup.homepage" = "https://start.duckduckgo.com";
        "browser.newtabpage.enabled" = false;  # Use homepage for new tabs
        "browser.startup.page" = 1;  # Open homepage on startup

        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;

        # Minimal UI
        "browser.uidensity" = 1;  # Compact mode
        "browser.tabs.firefox-view" = false;
        "browser.toolbars.bookmarks.visibility" = "never";  # Never show bookmarks bar

        # Performance
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;

        # Disable annoying features
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.pocket.enabled" = false;
        "browser.tabs.tabmanager.enabled" = false;  # Hide tab dropdown
        "browser.download.autohideButton" = true;  # Auto-hide download button

        # Prevent troubleshoot/safe mode dialog
        "browser.sessionstore.resume_from_crash" = false;
        "browser.sessionstore.max_resumed_crashes" = 0;
        "toolkit.startup.max_resumed_crashes" = -1;
        "browser.safebrowsing.enabled" = false;
        "browser.slowStartup.notificationDisabled" = true;
        "browser.slowStartup.maxSamples" = 0;
        "browser.startup.homepage_override.mstone" = "ignore";

        # Allow sideloaded extensions (from profile folder)
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
        "extensions.installDistroAddons" = true;
      };

      # userChrome.css - Chromeless Firefox (shows navbar on Cmd+L focus)
      userChrome = ''
        /* Hide tabs and bookmarks always */
        #TabsToolbar,
        #PersonalToolbar,
        #toolbar-menubar {
          visibility: collapse !important;
        }

        /* Hide titlebar elements */
        #titlebar,
        .titlebar-buttonbox-container,
        .titlebar-spacer {
          display: none !important;
        }

        /* Navbar: transparent and zero-height by default */
        #nav-bar {
          opacity: 0 !important;
          max-height: 0 !important;
          overflow: hidden !important;
          transition: opacity 0.1s, max-height 0.1s !important;
        }

        /* Show navbar when URL bar is focused (Cmd+L) */
        #nav-bar:focus-within {
          opacity: 1 !important;
          max-height: 40px !important;
        }

        /* Toolbox container */
        #navigator-toolbox {
          min-height: 0 !important;
        }
      '';

      # userContent.css - minimal new tab, dark scrollbars
      userContent = ''
        /* Dark scrollbars */
        @-moz-document url-prefix("about:"), url-prefix("chrome:") {
          * { scrollbar-color: ${colors.base02} ${colors.base00}; }
        }

        /* Minimal new tab page */
        @-moz-document url("about:newtab"), url("about:home") {
          body { background: ${colors.base00} !important; }
          .search-wrapper,
          .search-handoff-button,
          .logo-and-wordmark,
          .wordmark { display: none !important; }
        }
      '';
    };
  };

  # Copy Firefox files (dereference symlinks - Firefox may not follow them)
  home.activation.firefoxChrome = lib.hm.dag.entryAfter ["writeBoundary"] ''
    FIREFOX_DIR="$HOME/Library/Application Support/Firefox/Profiles"
    DEFAULT_PROFILE="$FIREFOX_DIR/default"

    # Dereference symlinks in the chrome folder
    if [ -d "$DEFAULT_PROFILE/chrome" ]; then
      for f in "$DEFAULT_PROFILE/chrome"/*; do
        if [ -L "$f" ]; then
          REAL_FILE=$(readlink "$f")
          rm "$f"
          cp "$REAL_FILE" "$f"
        fi
      done
    fi

    # Clear Firefox crash state to prevent troubleshoot mode dialog
    rm -f "$DEFAULT_PROFILE/.parentlock" 2>/dev/null || true
    rm -rf "$DEFAULT_PROFILE/crashes" 2>/dev/null || true
    rm -f "$DEFAULT_PROFILE/sessionCheckpoints.json" 2>/dev/null || true

    # Install Firefox policies for Homebrew Firefox (for extensions)
    FIREFOX_APP="/Applications/Firefox.app"
    if [ -d "$FIREFOX_APP" ]; then
      DIST_DIR="$FIREFOX_APP/Contents/Resources/distribution"
      mkdir -p "$DIST_DIR"
      cat > "$DIST_DIR/policies.json" << 'POLICIES'
{
  "policies": {
    "ExtensionSettings": {
      "{d7742d87-e61d-4b78-b8a1-b469842139fa}": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi"
      }
    }
  }
}
POLICIES
    fi
  '';

  # ============================================
  # Git Configuration
  # ============================================
  programs.git = {
    enable = true;
    settings = {
      user.name = "laged";
      # user.email = "your@email.com"; # Uncomment and set
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      dark = true;
      side-by-side = true;
    };
  };

  # ============================================
  # Zsh Shell
  # ============================================
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      # Nix
      rebuild = "sudo darwin-rebuild switch --flake ~/Codings/laged/nix-darwin#Mattis-MacBook-Pro";
      update = "nix flake update ~/.config/nix-darwin && rebuild";

      # Modern replacements
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      find = "fd";
      grep = "rg";

      # Git
      g = "git";
      gs = "git status";
      gd = "git diff";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline";

      # Quick edit
      ez = "vim ~/.zshrc";
      en = "vim ~/.config/nix-darwin/flake.nix";
    };

    initContent = ''
      # Add home-manager packages to PATH
      export PATH="$HOME/.local/state/home-manager/gcroots/current-home/home-path/bin:$PATH"

      # Initialize zoxide (smarter cd)
      eval "$(zoxide init zsh)"

      # Initialize starship prompt
      eval "$(starship init zsh)"
    '';
  };

  # ============================================
  # Starship Prompt
  # ============================================
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$character"
      ];
      directory = {
        style = "blue bold";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        style = "purple";
        symbol = " ";
      };
      git_status = {
        style = "red bold";
      };
      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "cyan";
      };
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
    };
  };

  # ============================================
  # Alacritty (alternative fast terminal)
  # ============================================
  programs.alacritty = {
    enable = true;
    # Stylix auto-generates colors
    settings = {
      window = {
        decorations = "None";
        padding = { x = 12; y = 12; };
        dynamic_padding = true;
        # opacity managed by stylix
      };
      scrolling = {
        history = 10000;
        multiplier = 3;
      };
      cursor = {
        style = {
          shape = "Block";
          blinking = "Never";
        };
      };
    };
  };

  # ============================================
  # Bat (better cat)
  # ============================================
  programs.bat = {
    enable = true;
    config = {
      # theme managed by stylix
      style = "numbers,changes,header";
    };
  };

  # ============================================
  # FZF (fuzzy finder)
  # ============================================
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # ============================================
  # Direnv
  # ============================================
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
