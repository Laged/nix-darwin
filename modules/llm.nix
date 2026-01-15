# LLM Tools Module
# Manages Claude Code, LSP servers, and AI development tools
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.llm;

  # Claude Code settings with Nix LSP support
  claudeSettings = builtins.toJSON {
    # LSP configuration for various languages
    lsp = {
      nix = {
        command = "nixd";
        args = [ ];
      };
    };

    # Permissions (adjust as needed)
    permissions = {
      allow = [
        "Bash(git *)"
        "Bash(nix *)"
        "Bash(darwin-rebuild *)"
      ];
    };
  };

  # Claude Code MCP settings (Model Context Protocol servers)
  claudeMcpSettings = builtins.toJSON {
    mcpServers = {
      # Add MCP servers here as needed
    };
  };

in {
  options.programs.llm = {
    enable = lib.mkEnableOption "LLM development tools (Claude Code, LSP servers)";

    enableNixLsp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nix LSP servers (nixd, nil)";
    };
  };

  config = lib.mkIf cfg.enable {
    # System packages for LLM development
    environment.systemPackages = with pkgs; [
      # Nix LSP servers
      nixd
      nil

      # Code formatting
      nixfmt-rfc-style

      # Additional dev tools useful with Claude
      tree-sitter
    ];

    # Home-manager config for Claude settings
    home-manager.users.${config.system.primaryUser} = { pkgs, ... }: {
      # Claude Code global settings
      home.file.".claude/settings.json".text = claudeSettings;

      # Claude MCP settings
      home.file.".claude/mcp_settings.json".text = claudeMcpSettings;

      # Project-local Claude settings template
      home.file.".claude/project-template.json".text = builtins.toJSON {
        lsp = {
          nix = {
            command = "nixd";
            args = [ ];
          };
        };
      };

      # nixd configuration for better flake support
      xdg.configFile."nixd/nixd.json".text = builtins.toJSON {
        nixpkgs = {
          expr = "import <nixpkgs> { }";
        };
        formatting = {
          command = [ "nixfmt" ];
        };
        options = {
          # Point to darwin options for better completions
          darwin = {
            expr = "(builtins.getFlake \"${config.system.configurationRevision or "github:LnL7/nix-darwin"}\").darwinConfigurations.\"Mattis-MacBook-Pro\".options";
          };
          home-manager = {
            expr = "(builtins.getFlake \"github:nix-community/home-manager\").homeConfigurations.\"\".options";
          };
        };
      };
    };
  };
}
