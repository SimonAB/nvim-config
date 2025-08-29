# Quick Start Guide

Get up and running with StellarVIM in under 5 minutes.

## Prerequisites

### Required Tools
```bash
# Install Neovim 0.12+ (latest version recommended)
brew install neovim

# Install essential tools
brew install ripgrep fd  # For Telescope fuzzy finding
brew install lazygit     # Git interface
brew install node        # For language servers
```

### Optional Tools (Academic Workflow)
```bash
# LaTeX support
brew install --cask mactex-no-gui

# PDF viewer for LaTeX sync
brew install --cask skim

# Typst typesetting
brew install typst

# Julia programming
brew install julia
```

## Installation

### Option 1: Direct Clone (Recommended)
```bash
git clone https://github.com/your-repo/stellarvim ~/.config/nvim
cd ~/.config/nvim
```

### Option 2: Manual Setup
```bash
mkdir -p ~/.config
git clone https://github.com/your-repo/stellarvim ~/.config/nvim
cd ~/.config/nvim
```

## First Launch

```bash
# Start Neovim - plugins will install automatically
nvim

# Or use the server script for better LaTeX integration
./scripts/start_nvim_server.sh
```

### What Happens on First Launch

1. **Plugin Installation**: vim-pack will clone and install all plugins
2. **Theme Setup**: Automatically detects and applies your system theme
3. **LSP Setup**: Mason installs recommended language servers
4. **Dashboard**: Mini.starter shows available commands

## Basic Usage

### Core Navigation
```vim
<Space>           # Leader key
<Ctrl-h/j/k/l>    # Navigate between windows
<Shift-h/l>       # Navigate between buffers
<C-t>             # Toggle terminal
```

### File Operations
```vim
<Space>f          # Find files (Telescope)
<Space>F          # Find files by frequency
<Space>g          # Live grep in project
<Space>e          # Toggle file explorer
```

### LSP Operations
```vim
gd                # Go to definition
K                 # Show documentation
<Space>Lf         # Format document
<Space>Lr         # Show references
```

### Academic Workflow
```vim
<Space>Jr         # Julia REPL operations
<Space>Q          # Quarto operations
<Space>Kp         # Markdown preview
<LocalLeader>lv   # LaTeX forward search
```

## Configuration

### Theme Switching
```vim
<Space>Yc         # Cycle through available themes
<Space>Yse        # Set spell language to English (British)
<Space>Ysf        # Set spell language to French
```

### Mason LSP Management
```vim
<Space>MA         # Install academic LSP servers
<Space>MR         # Install all recommended servers
<Space>MU         # Update all packages
<Space>MS         # Show Mason status
```

## Customization

### Personal Settings
Create `~/.config/nvim/lua/user.lua`:
```lua
-- Your personal overrides
vim.g.my_setting = "value"
```

### Keymap Changes
Add to `~/.config/nvim/lua/user.lua`:
```lua
vim.keymap.set("n", "<leader>mykey", ":MyCommand<CR>", { desc = "My custom command" })
```

## Troubleshooting

### Common Issues

**Slow Startup**
- Check Mason status: `<Space>MS`
- Run performance test: `:luafile scripts/performance_test.lua`

**LSP Not Working**
- Install servers: `<Space>MA`
- Check Mason: `:Mason`

**Theme Issues**
- Reload config: `<Space>Cs`
- Check theme: `:colorscheme`

### Getting Help

- **Which-Key**: Press `<Space>` to see all available commands
- **Keymap Search**: `<Space>Sk` to search keymaps
- **Plugin Help**: `:help <plugin-name>` for documentation

## Next Steps

1. **Explore Features**: Use Which-Key (`<Space>`) to discover commands
2. **Configure LSP**: Set up language servers for your projects
3. **Customize**: Add your preferred keymaps and settings
4. **Learn**: Check [Advanced Usage](advanced/) for power features

---

🎯 **Tip**: The configuration is designed to be discoverable - press `<Space>` and wait to see all available commands grouped by functionality.
