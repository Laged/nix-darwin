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

    profiles.default = {
      isDefault = true;

      # Firefox settings - minimal UI
      settings = {
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;

        # Minimal UI
        "browser.uidensity" = 1;  # Compact mode
        "browser.tabs.firefox-view" = false;
        "browser.toolbars.bookmarks.visibility" = "never";  # Never show bookmarks bar

        # Clean new tab page
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;  # Hide search on new tab

        # Performance
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;

        # Disable annoying features
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.pocket.enabled" = false;
        "browser.tabs.tabmanager.enabled" = false;  # Hide tab dropdown
        "browser.download.autohideButton" = true;  # Auto-hide download button
      };

      # userChrome.css - Ultra minimal Firefox UI
      userChrome = ''
        /* Minimal Firefox - Stylix themed, square corners */

        :root {
          --uc-navbar-height: 40px;
          --lwt-accent-color: ${colors.base00} !important;
          --lwt-text-color: ${colors.base05} !important;
          --toolbar-bgcolor: ${colors.base00} !important;
          --toolbar-color: ${colors.base05} !important;
        }

        /* Remove ALL border radius */
        *, *::before, *::after {
          border-radius: 0 !important;
        }

        /* ===== HIDE NAVBAR BY DEFAULT ===== */
        #nav-bar {
          min-height: 0 !important;
          max-height: 0 !important;
          height: 0 !important;
          padding: 0 !important;
          margin: 0 !important;
          overflow: hidden !important;
          opacity: 0;
          transition: all 0.15s ease !important;
        }

        /* Show navbar on hover or when URL bar is focused */
        #navigator-toolbox:hover #nav-bar,
        #navigator-toolbox:focus-within #nav-bar {
          min-height: var(--uc-navbar-height) !important;
          max-height: var(--uc-navbar-height) !important;
          height: var(--uc-navbar-height) !important;
          opacity: 1;
        }

        /* ===== HIDE EXTRA ELEMENTS ===== */
        #PersonalToolbar,           /* Bookmarks bar */
        #titlebar-spacer,           /* Titlebar spacers */
        .titlebar-buttonbox-container, /* Window buttons (we use WM) */
        #alltabs-button,            /* All tabs dropdown */
        #firefox-view-button,       /* Firefox view */
        #tracking-protection-icon-container, /* Shield icon */
        #identity-icon-box,         /* Site identity */
        #page-action-buttons,       /* Page actions */
        .tab-close-button,          /* Tab close buttons */
        #star-button-box,           /* Bookmark star */
        #urlbar-zoom-button,        /* Zoom indicator */
        #reader-mode-button,        /* Reader mode */
        #picture-in-picture-button, /* PiP button */
        .tab-secondary-label        /* Tab subtitle */
        {
          display: none !important;
        }

        /* ===== TABS BAR ===== */
        #TabsToolbar {
          background: ${colors.base00} !important;
          border: none !important;
        }

        #tabbrowser-tabs {
          background: ${colors.base00} !important;
        }

        .tabbrowser-tab {
          margin: 0 !important;
          padding: 0 4px !important;
          min-height: 32px !important;
        }

        .tab-background {
          margin: 0 !important;
          background: transparent !important;
          border: none !important;
        }

        .tabbrowser-tab[selected="true"] .tab-background {
          background: ${colors.base01} !important;
        }

        .tab-line { display: none !important; }

        /* ===== NAVIGATOR TOOLBOX ===== */
        #navigator-toolbox {
          background: ${colors.base00} !important;
          border-bottom: none !important;
        }

        /* ===== URL BAR (when visible) ===== */
        #nav-bar {
          background: ${colors.base00} !important;
          border: none !important;
        }

        #urlbar-background {
          background: ${colors.base01} !important;
          border: 1px solid ${colors.base02} !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          border-color: ${colors.base0D} !important;
        }

        /* ===== MISC ===== */
        #sidebar-box {
          background: ${colors.base00} !important;
        }

        findbar {
          background: ${colors.base00} !important;
        }

        /* Autocomplete dropdown */
        .urlbarView {
          background: ${colors.base00} !important;
        }

        .urlbarView-row[selected] {
          background: ${colors.base01} !important;
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
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nix-darwin#Mattis-MacBook-Pro";
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
      add_newline = true;
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
