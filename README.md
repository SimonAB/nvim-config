# ✴︎ StellarVIM: Neovim Configuration for Academic Writing

A comprehensive Neovim configuration optimised for academic research workflows, featuring advanced LaTeX support with bidirectional PDF synchronisation, Julia, Python, and R LSP integration, Quarto document authoring, intelligent terminal integration, and markdown preview capabilities. Built for Neovim 0.12+ using modern vim.pack plugin management with a modular, maintainable structure.

## 🎯 Key Features for Researchers

### Multi-Language Scientific Computing
- **Julia**: Enhanced LSP with auto-completion, REPL integration, and project management
- **Python, R, Bash**: Multi-language code execution in unified documents
- **Quarto**: Full document authoring with Molten Jupyter kernel integration
- **Otter**: Multi-language LSP support for code chunks in documents
- **LaTeX**: VimTeX with bibliography management and real-time compilation

### Document Processing & Preview
- **Markdown Preview**: Live preview with `<leader>Kp` featuring KaTeX math rendering and responsive design
- **LaTeX Support**: VimTeX with bibliography management and real-time compilation
- **Typst Support**: Low-latency Typst document preview with PDF compilation
- **Quarto Integration**: Full document authoring with multi-language support

### LaTeX Bidirectional Synchronisation
**Seamless PDF-to-source navigation** via VimTeX and Skim (macOS):
- **Forward search**: Jump from LaTeX source to corresponding PDF location
- **Inverse search**: Click PDF to navigate to source code (Cmd+click in Skim)
- Real-time compilation with LuaLaTeX and synctex support
- Perfect for managing large documents, theses, and complex mathematical content

### Academic Workflow Tools
- **Citation management**: Bibliography completion and reference jumping
- **Document navigation**: Telescope fuzzy finding across projects
- **Version control**: Integrated Git support with LazyGit
- **Terminal integration**: Smart code block execution with automatic navigation
- **Theme cycling**: Auto dark mode with multiple theme options
- **Obsidian integration**: Seamless vault management with image pasting

## 📁 Modular Structure

```
~/.config/nvim/
├── init.lua                    # Main configuration entry point
├── lua/
│   ├── config.lua              # Core editor settings and VimTeX configuration
│   ├── keymaps.lua             # Comprehensive key mappings
│   ├── plugins.lua             # Plugin management and installation
│   ├── require.lua             # Plugin loading orchestration
│   └── plugins/                # Individual plugin configurations
│       ├── auto-dark-mode-nvim.lua
│       ├── awesome-vim-colorschemes.lua
│       ├── blink-cmp.lua
│       ├── bufferline-nvim.lua
│       ├── catppuccin.lua
│       ├── github-nvim-theme.lua
│       ├── gitsigns-nvim.lua
│       ├── lualine-nvim.lua
│       ├── markdown-preview-nvim.lua
│       ├── mason-nvim.lua
│       ├── mini-nvim/
│       │   ├── config.lua
│       │   ├── dashboard-content.lua
│       │   ├── dashboard.lua
│       │   ├── init.lua
│       │   ├── plugin-manager.lua
│       │   └── utils.lua
│       ├── mini-nvim.lua
│       ├── nord-vim.lua
│       ├── nvim-lspconfig.lua
│       ├── nvim-tree.lua
│       ├── nvim-treesitter.lua
│       ├── nvim-web-devicons.lua
│       ├── obsidian-nvim.lua
│       ├── onedark-nvim.lua
│       ├── otter-nvim.lua
│       ├── plenary-nvim.lua
│       ├── quarto-nvim.lua
│       ├── telescope.lua
│       ├── toggleterm-nvim.lua
│       ├── tokyonight-nvim.lua
│       ├── trouble-nvim.lua
│       ├── typst-preview-nvim.lua
│       ├── vimtex.lua
│       └── which-key-nvim.lua
├── scripts/                    # Helper scripts and tools
│   ├── skim_inverse_search.sh
│   ├── start_nvim_server.sh
│   └── performance_test.lua
├── docs/                       # Comprehensive documentation guides
└── spell/                      # Spell checking dictionaries
```

## 🔧 Plugin Architecture

### Core Components
- **Plugin Management**: Native vim.pack system (Neovim 0.12+)
- **Loading Strategy**: Modular require system with individual plugin files
- **Configuration**: Each plugin has its own dedicated configuration file
- **Error Handling**: Graceful fallbacks and safe setup patterns with proper error reporting

### Plugin Categories

#### **Core Functionality**
- `blink-cmp.lua` - Modern completion engine
- `mason-nvim.lua` - LSP server manager and package installer
- `nvim-lspconfig.lua` - Language server protocol support
- `nvim-treesitter.lua` - Syntax highlighting and parsing
- `which-key-nvim.lua` - Keymap discovery and management

#### **User Interface**
- `bufferline-nvim.lua` - Buffer tabs
- `lualine-nvim.lua` - Status line
- `nvim-tree.lua` - File explorer
- `nvim-web-devicons.lua` - File type icons
- `trouble-nvim.lua` - Diagnostics viewer

#### **Themes & Appearance**
- `auto-dark-mode-nvim.lua` - Automatic theme switching
- `catppuccin.lua` - Modern pastel theme
- `onedark-nvim.lua` - Classic dark theme
- `tokyonight-nvim.lua` - Clean elegant theme
- `nord-vim.lua` - Arctic-inspired theme
- `github-nvim-theme.lua` - GitHub-inspired theme
- `awesome-vim-colorschemes.lua` - Theme collection

#### **Development Tools**
- `gitsigns-nvim.lua` - Git integration
- `telescope.lua` - Fuzzy finder
- `plenary-nvim.lua` - Utility library
- `mini-nvim.lua` - Dashboard and text objects

#### **Terminal & Execution**
- `toggleterm-nvim.lua` - Terminal management

#### **Document Processing**
- `vimtex.lua` - LaTeX support
- `markdown-preview-nvim.lua` - Markdown preview with live updates
- `typst-preview-nvim.lua` - Typst preview
- `quarto-nvim.lua` - Quarto document authoring
- `otter-nvim.lua` - Multi-language LSP in documents
- `obsidian-nvim.lua` - Obsidian vault integration with image pasting

## ⌨️ Complete Key Mappings

**Leader key**: `<Space>` | **Local Leader**: `\`

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
- `<leader>Cf` - Find config files (Telescope in config directory)
- `<leader>Cg` - Grep in config files (Telescope live_grep in config directory)

### File Operations
- `<leader>f` - Find files (Telescope)
- `<leader>F` - Find files by frequency/recency (Telescope frecency)
- `<leader>fr` - Refresh frecency database
- `<leader>fd` - Show frecency database location
- `<leader>fb` - Rebuild frecency database

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
- `<leader>Jd` - Generate documentation

### LSP Operations (`<leader>L`)
- `gd` - Go to definition
- `K` - Hover documentation
- `<leader>Ll` - List available servers
- `<leader>Lr` - Restart LSP
- `<leader>Lf` - Format document
- `<leader>LR` - Show references
- `<leader>Lm` - Open Mason

### Markdown Preview (`<leader>K`)
- `<leader>Kp` - Start Markdown Preview
- `<leader>Ks` - Stop Markdown Preview
- `<leader>Kt` - Toggle Markdown Preview

### Mason Package Management (`<leader>M`)
- `<leader>Mm` - Open Mason interface
- `<leader>Mi` - Install package
- `<leader>Mu` - Uninstall package
- `<leader>Ml` - View Mason log
- `<leader>Mh` - Mason help

### Obsidian Operations (`<leader>O`)
- `<leader>On` - New Obsidian note
- `<leader>Ol` - Insert Obsidian link
- `<leader>Of` - Follow Obsidian link
- `<leader>Oc` - Toggle Obsidian checkbox
- `<leader>Ob` - Show Obsidian backlinks
- `<leader>Og` - Show Obsidian outgoing links
- `<leader>Oo` - Find files in Obsidian vault (Telescope)
- `<leader>Ot` - Insert Obsidian template
- `<leader>ON` - New note from template
- `<leader>Op` - Paste image into Obsidian note

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
- `<leader>Sg` - Live Grep
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

#### Server Management (`<leader>Ts`)
- `<leader>Tss` - Start Neovim server
- `<leader>Tst` - Stop Neovim server
- `<leader>Trs` - Restart Neovim server
- `<leader>TCk` - Check Neovim server

### Toggle Options (`<leader>Y`)
- `<leader>Ys` - Toggle spell check
- `<leader>Yse` - Set spell language to English (British)
- `<leader>Ysf` - Set spell language to French
- `<leader>Yc` - Cycle colourscheme
- `<leader>Yw` - Toggle wrap
- `<leader>Yn` - Toggle line numbers

### Split Operations (`<leader>|`)
- `<leader>|v` - Vertical split
- `<leader>|h` - Horizontal split

### Window Operations (`<leader>W`)
- `<leader>Wk` - Decrease window height
- `<leader>Wj` - Increase window height
- `<leader>Wh` - Decrease window width
- `<leader>Wl` - Increase window width

### Trouble Diagnostics (`<leader>X`)
- `<leader>Xw` - Workspace diagnostics
- `<leader>Xd` - Document diagnostics
- `<leader>Xl` - Location list
- `<leader>Xq` - Quickfix
- `<leader>Xx` - Toggle Trouble

### Plugin Management (`<leader>P`)
- `<leader>Pi` - Install plugins
- `<leader>Pu` - Update plugins
- `<leader>Pc` - Compile plugins
- `<leader>Ps` - Sync plugins (install + update + compile)

### VimTeX Operations (`<localleader>v`)
- `<localleader>vv` - View (forward sync)
- `<localleader>vi` - Inverse search
- `<localleader>vl` - Compile (latexmk)
- `<localleader>vc` - Clean aux files
- `<localleader>vs` - Stop compiler

### Typst Operations (`<localleader>t`)
- `<localleader>tp` - Toggle Typst preview
- `<localleader>ts` - Sync cursor in preview
- `<localleader>tc` - Compile PDF with `typst c`
- `<localleader>tw` - Watch file with `typst w`

### Individual Commands
- `<leader>q` - Close buffer (quick access)
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

# Typst typesetting system
brew install typst
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

### LaTeX SyncTeX with Skim (macOS)

Use VimTeX's native Skim integration for a simple, robust setup.

1. Configure Skim:
   - Preferences → Sync → PDF-TeX Sync
   - Preset: Custom
   - Command: `<Full/path/to>/nvim/scripts/skim_inverse_search.sh` (must be a full path, no tilde or symlinks)
   - Arguments: `%line "%file"`

2. Ensure synctex is enabled (already configured here via VimTeX):
   - Compiler uses `-synctex=1`

3. Usage:
   - Forward search: `<localleader>vv` or `:VimtexView`
   - Inverse search: Cmd+Shift+Click in Skim
   - Compile: `<localleader>vl`
   - Clean aux files: `<localleader>vc`
   - Stop compiler: `<localleader>vs`

### Typst Document Processing

Typst is a modern typesetting system with excellent performance and features.

1. Install Typst:
   ```bash
   brew install typst
   ```

2. Usage:
   - Toggle preview: `<localleader>tp`
   - Sync cursor: `<localleader>ts`
   - Compile PDF: `<localleader>tc` (uses `typst c <filename>`)
   - Watch mode: `<localleader>tw` (uses `typst w <filename>`)

### Language Server Setup

**Mason Integration**: This configuration now uses [Mason](https://github.com/mason-org/mason.nvim) for automatic LSP server management. Language servers are automatically installed when needed.

#### Using Mason
```vim
:Mason                    # Open Mason interface
:MasonInstall <server>    # Install specific server
:MasonUninstall <server>  # Uninstall server
:MasonLog                 # View installation logs
```

#### Manual Installation (Fallback)
If you prefer manual installation or need specific versions:

##### Julia LSP
```julia
# In Julia REPL
using Pkg
Pkg.add("LanguageServer")
```

##### Python LSP
```bash
# Install pyright (preferred)
npm install -g pyright

# Or install python-lsp-server
pip install python-lsp-server[all]
```

##### LaTeX LSP
```bash
# Via Homebrew
brew install texlab

# Via Rust cargo
cargo install texlab

# Via conda
conda install -c conda-forge texlab
```

## 🎨 Themes

Built-in theme cycling with system dark mode detection:
- **Catppuccin** (Mocha variant) - Modern pastel theme
- **OneDark** (Atom-inspired) - Classic dark theme
- **Tokyo Night** (vibrant dark theme) - Clean elegant design
- **Nord** (arctic colour palette) - Arctic-inspired theme
- **GitHub Dark/Light** (auto-switches with system) - GitHub-inspired theme

**Cycle themes**: `<leader>Yc`
**Auto dark mode**: Automatically switches light/dark variants based on macOS system appearance

## 🔧 Configuration Management

### Keymap Architecture (Best Practice)
The configuration follows a clean, maintainable keymap architecture:
- **Single Source of Truth**: All keymaps defined in `lua/keymaps.lua` using `vim.keymap.set()`
- **Which-Key Integration**: Automatic discovery and display of keymaps with `desc` fields
- **No Redundancy**: Eliminated duplicate keymap definitions between files
- **Immediate Registration**: Keymaps register immediately when Neovim loads
- **Modular Design**: Easy to disable specific keymap groups
- **Performance Optimised**: No unnecessary autocmds or duplicate setups

### Modular Plugin System
Each plugin has its own configuration file in `lua/plugins/` for easy maintenance:
- **Individual Configuration**: Modify specific plugins without affecting others
- **Clear Documentation**: Each file contains detailed comments and usage examples
- **Error Isolation**: Plugin failures don't affect the entire system
- **Easy Debugging**: Isolate issues to specific plugin files

### Performance-Optimised Loading Strategy
The configuration uses a sophisticated loading orchestration system in `lua/require.lua`:
- **Immediate Loading**: Core dependencies and essential functionality
- **Deferred Loading (200ms)**: UI components and document processing
- **Lazy Loading (1000ms)**: Non-essential themes and keymap management
- **Error Handling**: Graceful fallbacks with proper error reporting
- **Logical Grouping**: Related plugins are loaded together

### LSP Server Management with Mason
The configuration uses [Mason](https://github.com/mason-org/mason.nvim) for seamless LSP server management:
- **Automatic Installation**: Language servers are installed automatically when needed
- **Portable**: Works everywhere Neovim runs without external dependencies
- **Unified Interface**: Manage LSP servers, DAP servers, linters, and formatters
- **Registry Integration**: Access to comprehensive server registry
- **Easy Management**: Install, update, and uninstall servers from within Neovim

### Configuration Files
- `init.lua` - Entry point and leader key setup
- `lua/config.lua` - Core editor settings and autocommands
- `lua/keymaps.lua` - All key mappings and terminal integration
- `lua/plugins.lua` - Plugin installation and management
- `lua/require.lua` - Plugin loading orchestration
- `lua/plugins/*.lua` - Individual plugin configurations

### Hot Reloading
Use `<leader>Cs` to reload all configuration files during development.

## 📚 Documentation

- Press `<Space>` and wait to see available commands
- Use `<leader>Sk` to search all keymaps
- Each plugin file contains detailed configuration comments
- **Keymap Discovery**: Press any leader key (e.g., `<leader>O`) to see all available commands for that group

### Additional Guides
- [Installation Guide](docs/INSTALLATION_GUIDE.md)
- [Troubleshooting](docs/TROUBLESHOOTING_GUIDE.md)
- [Requirements](docs/REQUIREMENTS.md)
- [Changelog](docs/CHANGELOG.md)
- [Review Report](docs/REVIEW_REPORT.md)

## 🐛 Common Issues

**LaTeX inverse search not working?**
- Ensure Skim is configured correctly
- Check `/tmp/inverse_search.log` for debugging
- For complex project structures, set `INVERSE_SEARCH_PROJECT_ROOT` environment variable
- Test path resolution manually: `<Full/path/to>/nvim/scripts/skim_inverse_search.sh 1 \"your-file.tex\"`

**Files not found with relative paths in LaTeX projects?**
- The script now includes intelligent path resolution
- For custom project layouts, export `INVERSE_SEARCH_PROJECT_ROOT=/path/to/project`
- Check debug log: `tail -f /tmp/inverse_search.log` whilst testing inverse search
- Verify your project structure matches supported patterns

**Julia LSP not starting?**
- Install LanguageServer.jl: `using Pkg; Pkg.add("LanguageServer")`
- Verify Julia is in PATH

**Plugins not loading?**
- Restart Neovim (auto-installs on first run)
- Clear cache: `rm -rf ~/.local/share/nvim/pack/`
- Check individual plugin files for configuration errors
- Check error messages in `:messages` for specific plugin failures

**Configuration changes not taking effect?**
- Use `<leader>Cs` to reload all configuration
- Check for syntax errors in individual plugin files
- Verify plugin dependencies are installed

**Markdown preview not working?**
- Ensure the plugin is built: check `~/.local/share/nvim/pack/plugins/start/markdown-preview.nvim/app/bin/`
- Use `<leader>Kp` to start preview
- Check browser permissions for local file access

## Maintenance

### Adding New Plugins
1. Add plugin to `lua/plugins.lua` plugin list
2. Create new configuration file in `lua/plugins/`
3. Add require statement to `lua/require.lua` with appropriate priority
4. Restart Neovim or use `<leader>Pi` to install

### Updating Plugins
- Use `<leader>Pu` to update all plugins
- Use `<leader>Ps` to sync (install + update + compile)

### Customising Individual Plugins
- Edit the corresponding file in `lua/plugins/`
- Each file contains detailed configuration options
- Use `<leader>Cs` to reload changes

### Performance Optimisation
The configuration is optimised for fast startup and responsive operation:
- **Core functionality loads immediately**
- **UI components load after 200ms**
- **Non-essential features load after 1000ms**
- **Error handling prevents startup failures**
- **Modular structure allows easy customisation**

---

*Optimised for academic writing and research workflows. Built with modular architecture for maintainability and performance. Made by SimonAB.*
