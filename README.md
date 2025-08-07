# ✴︎ Modern Neovim Configuration for Academic Writing

A comprehensive Neovim configuration optimised for academic research workflows, featuring advanced LaTeX support with bidirectional PDF synchronisation, Julia LSP integration, Quarto document authoring, and intelligent terminal integration. Built for Neovim 0.12+ using modern vim.pack plugin management.

## 🎯 Key Features for Researchers

### LaTeX Bidirectional Synchronisation
**Seamless PDF-to-source navigation** via VimTeX and Skim (macOS):
- **Forward search**: Jump from LaTeX source to corresponding PDF location
- **Inverse search**: Click PDF to navigate to source code (Cmd+click in Skim)
- Real-time compilation with LuaLaTeX and synctex support
- Perfect for managing large documents, theses, and complex mathematical content

### Multi-Language Scientific Computing
- **Julia**: Enhanced LSP with auto-completion, REPL integration, and project management
- **LaTeX**: VimTeX with bibliography management and real-time compilation
- **Quarto**: Full document authoring with Molten Jupyter kernel integration
- **Python, R, Bash**: Multi-language code execution in unified documents
- **Otter**: Multi-language LSP support for code chunks in documents

### Academic Workflow Tools
- **Citation management**: Bibliography completion and reference jumping
- **Document navigation**: Telescope fuzzy finding across projects
- **Version control**: Integrated Git support with LazyGit
- **Terminal integration**: Smart code block execution with automatic navigation
- **Theme cycling**: Auto dark mode with multiple theme options

## 📁 Structure

```
~/.config/nvim/
├── init.lua              # Main configuration entry point
├── lua/
│   ├── config.lua        # Editor settings and VimTeX configuration
│   ├── keymaps.lua       # Comprehensive key mappings
│   └── plugins.lua       # Plugin management and LSP setup
├── scripts/              # Helper scripts for PDF sync
├── spell/                # Custom spelling dictionaries
└── Documentation files   # Comprehensive guides
```

## ⌨️ Complete Key Mappings

**Leader key**: `<Space>` | **Local Leader**: `,`

### Core Navigation & Editing
- `<Shift-h>` - Previous buffer
- `<Shift-l>` - Next buffer 
- `<Ctrl-h/j/k/l>` - Navigate windows (works in terminal mode)
- `<Shift-Arrow>` - Resize windows
- `<Esc>` - Clear search highlights
- `<Ctrl-s>` - Quick save

### Buffer Operations (`<leader>B`)
- `<leader>Bf` - Find buffers (Telescope)
- `<leader>Bj` - Jump to buffer (BufferLine pick)
- `<leader>Bb` - Previous buffer
- `<leader>Bn` - Next buffer
- `<leader>Bq` - Close buffer

### Configuration (`<leader>C`)
- `<leader>Cs` - Reload all configuration files
- `<leader>Cd` - Browse config directory
- `<leader>Cg` - Search config directory

### File Operations
- `<leader>f` - Find files (Telescope)
- `<leader>e` - Toggle file explorer (NvimTree)

### Git Operations (`<leader>G`)
- `<leader>Gg` - LazyGit interface
- `<leader>Gs` - Git status
- `<leader>Gp` - Git pull

### Julia Development (`<leader>J`)
#### Julia REPL (`<leader>Jr`)
- `<leader>Jrh` - Horizontal REPL
- `<leader>Jrv` - Vertical REPL
- `<leader>Jrf` - Floating REPL
#### Julia Project Management
- `<leader>Jp` - Project status (Pkg.status())
- `<leader>Ji` - Instantiate project
- `<leader>Ju` - Update project
- `<leader>Jt` - Run tests

### LSP Operations (`<leader>L`)
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>Ll` - List available servers
- `<leader>Lr` - Restart LSP
- `<leader>Lf` - Format document
- `<leader>LR` - Show references
- `<leader>Ld` - Buffer diagnostics
- `<leader>Lw` - Workspace diagnostics
- `<leader>Ls` - Document symbols
- `<leader>LS` - Workspace symbols

### Otter Multi-language (`<leader>O`)
- `<leader>Oa` - Activate Otter
- `<leader>Od` - Deactivate Otter

### Plugin Management (`<leader>P`)
- `<leader>Pi` - Install plugins
- `<leader>Pu` - Update plugins
- `<leader>Pc` - Compile plugins
- `<leader>Ps` - Sync plugins (install + update + compile)

### Quarto Operations (`<leader>Q`)
- `<leader>Qp` - Quarto preview
- `<leader>Qc` - Close preview
- `<leader>Qr` - Quarto render
#### Molten (Jupyter) (`<leader>Qm`)
- `<leader>Qmi` - Show image popup
- `<leader>Qml` - Evaluate line
- `<leader>Qme` - Evaluate operator
- `<leader>Qmn` - Initialise kernel
- `<leader>Qmk` - Stop kernel
- `<leader>Qmr` - Restart kernel
- `<leader>Qmv` - Evaluate visual selection
- `<leader>Qmf` - Re-evaluate cell
- `<leader>Qmh` - Hide output
- `<leader>Qms` - Show output
- `<leader>Qmd` - Delete cell
- `<leader>Qmb` - Open in browser

### Search Operations (`<leader>S`)
- `<leader>Sf` - Find files
- `<leader>St` - Text (Live Grep)
- `<leader>Sb` - Git branches
- `<leader>Sc` - Colourscheme
- `<leader>Sh` - Help tags
- `<leader>Sr` - Recent files
- `<leader>Sk` - Keymaps
- `<leader>SC` - Commands
- `<leader>Sl` - Resume last search

### Terminal Operations (`<leader>T`)
- `<Ctrl-t>` - Toggle terminal *[direct key]*
- `<Ctrl-i>` - Send current line to terminal *[direct key]*
- `<Ctrl-s>` - Send visual selection to terminal *[direct key]*
- `<Ctrl-c>` - Send current code block to terminal *[direct key]*
- `<leader>Tk` - Clear terminal
- `<leader>Td` - Kill terminal
- `<Alt-1>` - Horizontal terminal
- `<Alt-2>` - Vertical terminal  
- `<Alt-3>` - Float terminal

### Trouble Diagnostics (`<leader>X`)
- `<leader>Xw` - Workspace diagnostics
- `<leader>Xd` - Document diagnostics
- `<leader>Xl` - Location list
- `<leader>Xq` - Quickfix
- `<leader>Xx` - Toggle Trouble

### Toggle Options (`<leader>Y`)
- `<leader>Ys` - Toggle spell check
- `<leader>Yc` - Cycle colourscheme
- `<leader>Yw` - Toggle wrap
- `<leader>Yn` - Toggle line numbers

### Split Operations (`<leader>|`)
- `<leader>|v` - Vertical split
- `<leader>|h` - Horizontal split

### Individual Commands
- `<leader>q` - Close buffer (quick access)
- `<leader>?` - Which-key status
- `<leader>x` - Toggle checkbox (Obsidian)

## 🛠️ Installation

### Prerequisites

#### Install Homebrew (macOS Package Manager)
If you don't have Homebrew installed, visit [brew.sh](https://brew.sh) or run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Essential Requirements
```bash
# Install Neovim 0.12+ via Homebrew (macOS)
brew install neovim

# Or install development version for latest features
brew install --HEAD neovim

# Git (usually pre-installed on macOS)
brew install git

# Node.js for language servers
brew install node
```

#### Optional Dependencies for Full Features

**Language Servers and Tools:**
```bash
# Julia programming language
brew install julia

# LaTeX distribution
brew install --cask mactex-no-gui  # Smaller install without GUI apps
# OR: brew install --cask mactex    # Full install with GUI applications

# LaTeX language server
brew install texlab

# Python language server
npm install -g pyright

# R language server (if using R)
R -e "install.packages('languageserver')"

# Enhanced search tools for Telescope
brew install ripgrep fd

# Git interface
brew install lazygit
```

**PDF Viewer (macOS):**
```bash
# Skim for LaTeX bidirectional sync
brew install --cask skim
```

### Quick Setup

```bash
# Clone the repository
git clone https://github.com/SimonAB/nvim-config.git ~/.config/nvim

# Start Neovim (plugins will auto-install on first launch)
nvim
```

### LaTeX Inverse Search Setup (macOS)

1. **Configure Skim PDF viewer:**
   - Open Skim Preferences → Sync → PDF-TeX Sync
   - **Preset**: Custom
   - **Command**: `~/.config/nvim/scripts/skim_inverse_search.sh`
   - **Arguments**: `%line "%file"`

2. **Make script executable:**
   ```bash
   chmod +x ~/.config/nvim/scripts/skim_inverse_search.sh
   ```

### Language Server Setup

#### Julia LSP
```julia
# In Julia REPL
using Pkg
Pkg.add("LanguageServer")
```

#### Python LSP (Alternative)
```bash
# If you prefer python-lsp-server over pyright
pip install python-lsp-server[all]
```

#### LaTeX LSP (Alternative Installation Methods)
```bash
# Via Rust cargo if Homebrew version doesn't work
cargo install texlab

# Via conda
conda install -c conda-forge texlab
```

## 🎨 Themes

Built-in theme cycling with system dark mode detection:
- **Catppuccin** (Mocha variant)
- **OneDark** (Atom-inspired)
- **Tokyo Night** (vibrant dark theme)  
- **Nord** (arctic colour palette)
- **GitHub Dark/Light** (auto-switches with system)

**Cycle themes**: `<leader>Yc`  
**Auto dark mode**: Automatically switches light/dark variants based on macOS system appearance

## 📚 Documentation

- Press `<Space>` and wait to see available commands
- Use `<leader>Sk` to search all keymaps
- Check `<leader>?` for which-key status

### Additional Guides
- [Installation Guide](INSTALLATION_GUIDE.md)
- [Troubleshooting](TROUBLESHOOTING_GUIDE.md)

## 🐛 Common Issues

**LaTeX inverse search not working?**
- Ensure Skim is configured correctly
- Check `/tmp/inverse_search.log` for debugging

**Julia LSP not starting?**
- Install LanguageServer.jl: `using Pkg; Pkg.add("LanguageServer")`
- Verify Julia is in PATH

**Plugins not loading?**
- Restart Neovim (auto-installs on first run)
- Clear cache: `rm -rf ~/.local/share/nvim/pack/`

---

*Optimised for academic writing and research workflows. Based on LunarVim architecture.*


