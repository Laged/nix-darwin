# nix-darwin

Declarative macOS system configuration with nix-darwin, home-manager, and stylix theming.

## Features

- **Stylix theming** - Consistent base16 colors across terminal, Firefox, and apps
- **Aerospace** - Tiling window manager with vim-style keybindings
- **Chromeless Firefox** - Minimal UI with Vimium support, Cmd+L to show navbar
- **Ghostty/Alacritty** - GPU-accelerated terminals with Nerd Font support
- **Dynamic wallpaper** - Auto-generated 4x4 color grid based on theme

## Installation

### 1. Install Determinate Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Restart your terminal after installation.

### 2. Clone this repository

```bash
git clone https://github.com/Laged/nix-darwin.git ~/nix-darwin
cd ~/nix-darwin
```

### 3. Update configuration for your machine

Edit `flake.nix` and update:
- `username` - your macOS username
- `hostname` in `darwinConfigurations` - your Mac's hostname (run `hostname` to check)

### 4. Build and apply

First run (bootstraps nix-darwin):

```bash
nix run nix-darwin -- switch --flake .#YOUR-HOSTNAME
```

Subsequent runs:

```bash
darwin-rebuild switch --flake .#YOUR-HOSTNAME
```

### 5. Post-install

- **Log out and back in** for all system defaults to take effect
- **Install Vimium manually** in Firefox: visit `addons.mozilla.org/firefox/addon/vimium-ff/` and enable "Access your data for all websites"

## Keybindings (Aerospace)

| Keybinding | Action |
|------------|--------|
| `Cmd+Alt+Space` | Open Alacritty |
| `Cmd+Alt+Enter` | Open Ghostty |
| `Cmd+Alt+B` | Open Firefox |
| `Cmd+Alt+H/J/K/L` | Focus left/down/up/right |
| `Cmd+Alt+Shift+H/J/K/L` | Move window left/down/up/right |
| `Cmd+Alt+F` | Fullscreen (tiling) |
| `Cmd+Alt+G` | macOS native fullscreen |
| `Cmd+Alt+Y` | Move window to next monitor |
| `Cmd+Alt+T` | Toggle floating/tiling |
| `Cmd+Alt+Q` | Close window |
| `Cmd+Alt+1-9` | Switch to workspace |
| `Cmd+Alt+Shift+1-9` | Move window to workspace |

## Firefox

- **Chromeless UI** - tabs/navbar hidden by default
- **Cmd+L** - Show navbar to enter URL
- **Vimium** - Vim keybindings for navigation (manual install required)
- **DuckDuckGo** - Default start page

## Structure

```
.
├── flake.nix           # Main flake configuration
├── flake.lock          # Locked dependencies
└── modules/
    ├── aerospace.nix   # Tiling window manager config
    ├── home.nix        # Home-manager (dotfiles, apps)
    ├── llm.nix         # AI/LLM tools (Claude Code, nixd)
    └── theme.nix       # Stylix theming + wallpaper
```

## Updating

```bash
cd ~/nix-darwin
nix flake update
darwin-rebuild switch --flake .#YOUR-HOSTNAME
```

## Troubleshooting

**"darwin-rebuild: command not found"**
Run the bootstrap command again:
```bash
nix run nix-darwin -- switch --flake .#YOUR-HOSTNAME
```

**Firefox shows troubleshoot dialog**
This is cleared automatically on rebuild. Just rebuild again.

**Spotlight (Cmd+Space) not working**
Rebuild to re-apply system defaults, then log out/in.
