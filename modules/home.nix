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

      # Firefox settings
      settings = {
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Privacy settings
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "browser.send_pings" = false;

        # UI tweaks
        "browser.uidensity" = 1;  # Compact mode
        "browser.tabs.firefox-view" = false;
        "browser.toolbars.bookmarks.visibility" = "newtab";

        # New tab page
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # Performance
        "gfx.webrender.all" = true;
        "layers.acceleration.force-enabled" = true;

        # Disable annoying features
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.pocket.enabled" = false;
      };

      # userChrome.css for custom styling (Stylix colors + square corners)
      userChrome = ''
        /* Firefox userChrome.css - Minimal UI with Stylix colors */
        /* Square corners everywhere */

        :root {
          --lwt-accent-color: ${colors.base00} !important;
          --lwt-text-color: ${colors.base05} !important;
          --toolbar-bgcolor: ${colors.base00} !important;
          --toolbar-color: ${colors.base05} !important;
          --tabs-border-color: ${colors.base03} !important;
          --tab-selected-bgcolor: ${colors.base01} !important;
        }

        /* Remove ALL border radius */
        *, *::before, *::after {
          border-radius: 0 !important;
        }

        /* Main toolbar */
        #navigator-toolbox {
          background: var(--toolbar-bgcolor) !important;
          border-bottom: 1px solid ${colors.base03} !important;
        }

        #nav-bar {
          background: var(--toolbar-bgcolor) !important;
          border: none !important;
          box-shadow: none !important;
        }

        /* URL bar - square */
        #urlbar-background {
          background: ${colors.base01} !important;
          border: 1px solid ${colors.base03} !important;
          border-radius: 0 !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          border-color: ${colors.base0D} !important;
        }

        /* Tabs toolbar */
        #TabsToolbar {
          background: ${colors.base01} !important;
        }

        /* Tab styling - completely square */
        .tabbrowser-tab {
          border-radius: 0 !important;
          margin: 0 !important;
          padding: 0 !important;
        }

        .tab-background {
          border-radius: 0 !important;
          margin: 0 !important;
          background: ${colors.base01} !important;
          border: none !important;
        }

        .tabbrowser-tab[selected="true"] .tab-background {
          background: ${colors.base00} !important;
          border-bottom: 2px solid ${colors.base0D} !important;
        }

        .tab-line {
          display: none !important;
        }

        /* Tab close button */
        .tab-close-button {
          border-radius: 0 !important;
        }

        /* Sidebar */
        #sidebar-box {
          background: ${colors.base00} !important;
          border-right: 1px solid ${colors.base03} !important;
        }

        /* Findbar */
        findbar {
          background: ${colors.base00} !important;
          border-top: 1px solid ${colors.base03} !important;
        }

        /* Autocomplete popup */
        #PopupAutoComplete,
        .autocomplete-richlistbox {
          background: ${colors.base00} !important;
          border-radius: 0 !important;
        }

        /* Buttons */
        toolbarbutton {
          border-radius: 0 !important;
        }

        /* Remove tab separator lines */
        .tabbrowser-tab::after,
        .tabbrowser-tab::before {
          display: none !important;
        }
      '';

      # userContent.css for web content
      userContent = ''
        /* Firefox userContent.css - Dark scrollbars */
        @-moz-document url-prefix("about:"), url-prefix("chrome:") {
          * {
            scrollbar-color: ${colors.base03} ${colors.base00};
          }
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
