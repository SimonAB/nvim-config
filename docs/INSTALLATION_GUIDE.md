# Installation Guide

Installation instructions for BabaVim on macOS.

## System Requirements

- **Operating System**: macOS 10.15+ (tested on macOS 13+)
- **Neovim**: 0.12 or later (required for vim.pack plugin management)
- **Terminal**: [Ghostty](https://github.com/ghostty-org/ghostty), [iTerm2](https://iterm2.com/), or [Warp](https://www.warp.dev/) (256-colour support)
- **Internet Connection**: Required for plugin installation

## Prerequisites

### Homebrew Package Manager

Install dependencies via Homebrew. If Homebrew is not installed:

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

Homebrew: https://brew.sh/

Add Homebrew to PATH per installation instructions.

## Core Dependencies

### 1. Neovim 0.12+

```bash
# Install via Homebrew
brew install neovim

# Verify version
nvim --version  # Must show 0.12.0 or later

# Build from source (alternative)
git clone https://github.com/neovim/neovim
cd neovim
make CMAKE_BUILD_TYPE=Release
sudo make install
```

### 2. Essential Command-Line Tools

```bash
# Ripgrep (for Telescope live grep)
brew install ripgrep

# fd (for Telescope file finding)
brew install fd

# Git (for plugin management)
brew install git

# LazyGit (for Git interface)
brew install lazygit

# Cargo (for blink.cmp compilation)
brew install rust
```

Verify installation:
```bash
rg --version     # ripgrep 14.0.0+
fd --version     # fd 9.0.0+
git --version    # git 2.40.0+
cargo --version  # cargo 1.70.0+
```

## Configuration Installation

### Clone Repository

```bash
# Backup existing configuration (if any)
mv ~/.config/nvim ~/.config/nvim.backup

# Clone this configuration
git clone https://github.com/SimonAB/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
```

### First Launch

```bash
# Launch Neovim - plugins install automatically
nvim

# Expected behaviour:
# 1. vim.pack clones plugins from GitHub (~2-3 minutes)
# 2. blink.cmp compiles (~30 seconds)
# 3. Dashboard appears
```

If plugins don't install automatically:
```vim
:lua require('core.plugin-manager').install_all_plugins()
```

## Document Processing Tools

### LaTeX Workflow

```bash
# Full TeX distribution (3.5 GB)
brew install --cask mactex

# BasicTeX (100 MB, manual package installation required)
brew install --cask basictex

# PDF viewer with SyncTeX support
brew install --cask skim

# LaTeX language server (optional, can install via Mason)
brew install texlab
```

Verify LaTeX installation:
```bash
pdflatex --version
latexmk --version
```

#### Configure Skim for SyncTeX

1. Open Skim
2. Navigate to **Preferences** → **Sync** → **PDF-TeX Sync**
3. Configure sync settings:
   - **Preset**: Custom
   - **Command**: `/Users/<username>/.config/nvim/scripts/skim_inverse_search.sh`
     - **Important**: Use absolute path, no tilde (~) or symlinks
     - Replace `<username>` with your actual username
   - **Arguments**: `%line "%file"`

Test SyncTeX:
```bash
cd ~/Documents/latex-test
nvim test.tex
```

In Neovim:
- `\ll` to compile
- `\lv` for forward search (Neovim → PDF)

In Skim:
- Cmd+Shift+Click for inverse search (PDF → Neovim)

### Markdown Workflow

```bash
# Node.js (for markdown-preview plugin)
brew install node

# Optional: Pandoc for advanced Markdown conversion
brew install pandoc
```

Test Markdown preview:
```bash
nvim test.md
```

In Neovim: `<Space>Kp` to start preview

### Typst Workflow

```bash
# Typst compiler
brew install typst

# Verify installation
typst --version
```

Test Typst:
```bash
nvim test.typ
```

In Neovim: `\tp` to toggle preview

### Quarto Workflow

```bash
# Quarto publishing system
brew install --cask quarto

# Verify installation
quarto check
```

## Language Support

### Julia

```bash
# Install Julia
brew install julia

# Verify installation
julia --version  # 1.9.0+ recommended
```

Configure Julia environment:
```julia
# Launch Julia
julia

# Install language server
using Pkg
Pkg.add("LanguageServer")
Pkg.add("SymbolServer")

# For Quarto/Jupyter integration
Pkg.add("IJulia")
```

Install Julia LSP via Mason (in Neovim):
```vim
:Mason
" Search for 'julials' and install
```

### Python

```bash
# Python 3 (usually pre-installed on macOS)
python3 --version  # 3.8+ required

# pip for package management
python3 -m ensurepip --upgrade
```

Install Python LSP via Mason:
```vim
:Mason
" Install: pyright, ruff-lsp
```

### R

```bash
# R programming language
brew install r

# Verify installation
R --version
```

Install R language server:
```r
# Launch R
R

# Install languageserver
install.packages("languageserver")
```

Install R LSP via Mason:
```vim
:Mason
" Search for 'r_language_server' and install
```

## Language Server Installation

### Via Mason (Recommended)

Mason provides a unified interface for installing language servers.

```vim
# Open Mason
:Mason

# Or use leader keymaps
<Space>MA            " Install academic LSP servers (automated)
<Space>MR            " Install all recommended servers
<Space>MU            " Update all packages
```

### Recommended Language Servers

#### Academic Writing
- **texlab**: LaTeX language server
- **marksman**: Markdown language server
- **ltex-ls**: Grammar/spell checking (LanguageTool)

#### Programming
- **lua-language-server**: Lua/Neovim configuration
- **pyright**: Python type checking
- **ruff-lsp**: Python linting
- **julials**: Julia language server
- **r-languageserver**: R language server

#### Data/Configuration
- **yaml-language-server**: YAML
- **json-lsp**: JSON
- **taplo**: TOML

### Manual LSP Installation

If Mason installation fails, install manually:

```bash
# Lua LSP
brew install lua-language-server

# Python LSP
npm install -g pyright

# LaTeX LSP
brew install texlab
```

## Optional Tools

### Obsidian Integration

```bash
# Install Obsidian
brew install --cask obsidian
```

Configure vault path in `lua/keymaps.lua`:
```lua
local obsidian_path = "/path/to/your/vault"
```

### Database Tools

```bash
# SQLite (for Telescope frecency)
brew install sqlite3
```

### Additional Utilities

```bash
# Tree-sitter CLI (for parser updates)
npm install -g tree-sitter-cli

# Neovim remote (for advanced workflows)
pip3 install neovim-remote

# GitHub CLI (for gh integration)
brew install gh
```

## Verification

### Check Neovim Health

```vim
:checkhealth
```

Review each section for warnings or errors.

### Verify Plugin Installation

```vim
:lua print(vim.inspect(vim.fn.glob('~/.local/share/nvim/pack/plugins/*/*', 0, 1)))
```

Expected: List of installed plugins

### Test LSP Functionality

```vim
# Open a Python file
:e test.py

# Check LSP status
:LspInfo

# Verify LSP is attached
<Space>Ll          " List active LSP servers
```

## Troubleshooting

### Plugins Not Installing

**Symptom**: Blank Neovim or plugin errors

**Solution**:
```bash
# Check plugin directory
ls ~/.local/share/nvim/pack/plugins/

# Manual installation
nvim -c "lua require('core.plugin-manager').install_all_plugins()" -c "q"

# Check for errors
nvim -c "messages" -c "q"
```

### blink.cmp Compilation Failure

**Symptom**: Completion not working

**Solution**:
```bash
# Ensure Cargo is installed
cargo --version

# Manually compile
cd ~/.local/share/nvim/pack/plugins/start/blink.cmp
cargo build --release

# Alternative: Use nvim-cmp instead
# Edit lua/plugins.lua to disable blink.cmp
```

### LSP Not Starting

**Symptom**: No code intelligence, diagnostics, or completion

**Solution**:
```vim
# Check Mason installation
:Mason

# Verify language server is installed
:LspInfo

# Check log file
:lua print(vim.lsp.get_log_path())

# Manual server installation
<Space>MA          " Install academic servers
```

### LaTeX SyncTeX Issues

**Symptom**: Forward/inverse search not working

**Solution**:
```bash
# Verify script path in Skim preferences
# Must be absolute path:
/Users/<username>/.config/nvim/scripts/skim_inverse_search.sh

# Test script manually
~/.config/nvim/scripts/skim_inverse_search.sh 10 "/absolute/path/to/test.tex"

# Check debug log
tail -f /tmp/inverse_search.log
```

### Terminal Emulator Issues

**Symptom**: Colours wrong, icons not displaying, keymaps not working

**Solution**:
```bash
# Verify terminal supports 256 colours
echo $TERM  # Should be xterm-256color or similar

# Test colours
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash

# Install a Nerd Font for icons
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font

# Configure terminal to use Nerd Font
```

**Recommended terminals**:
- [Ghostty](https://github.com/ghostty-org/ghostty) - Fast, native macOS terminal
- [iTerm2](https://iterm2.com/) - Feature-rich terminal with extensive customisation
- [Warp](https://www.warp.dev/) - Modern terminal with AI features

**Terminal.app**: macOS built-in terminal has 256-colour support but requires configuration:
1. Terminal → Preferences → Profiles
2. Select or create a profile
3. Advanced tab → Set "Declare terminal as:" to `xterm-256color`
4. Text tab → Install a Nerd Font for proper icon display

Recommended terminals: iTerm2, Warp, Ghostty (better font rendering, icon support).

## Updating

### Update Configuration

```bash
cd ~/.config/nvim
git pull origin main
```

### Update Plugins

```vim
<Space>CUa         " Update all plugins
:lua require('core.plugin-manager').update_all_plugins()
```

### Update Language Servers

```vim
<Space>MU          " Update all Mason packages
:MasonUpdate
```

## Uninstallation

### Complete Removal

```bash
# Remove configuration
rm -rf ~/.config/nvim

# Remove data (plugins, LSP servers, etc.)
rm -rf ~/.local/share/nvim

# Remove state (logs, swap files)
rm -rf ~/.local/state/nvim

# Remove cache
rm -rf ~/.cache/nvim
```

### Restore Backup

```bash
mv ~/.config/nvim.backup ~/.config/nvim
```

## Platform-Specific Notes

### macOS Apple Silicon (M1/M2/M3)

All tools install natively on Apple Silicon. No Rosetta required.

### macOS Intel

Standard installation. Ensure Homebrew is installed for x86_64 architecture.

### Linux Support

This configuration is configured for macOS but should work on Linux with modifications:
- Replace Skim with Zathura or Okular for LaTeX preview
- Adjust paths in shell scripts
- Install tools via apt/dnf instead of brew

## Next Steps

After installation:

1. Configure language servers: `<Space>MA`
2. Select theme: `<Space>YTp`
3. Test LaTeX workflow: Compile test document
4. Customise keymaps: Add mappings to `lua/keymaps.lua`
5. Review documentation: Keymaps reference, troubleshooting guide

---

See [Quick Start Guide](quickstart.md) and [Keymaps Reference](reference/keymaps.md).
