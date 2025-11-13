# Quick Start Guide

BabaVim: Neovim setup for research workflows.

## Prerequisites

### Homebrew Package Manager

If you don't have Homebrew installed:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

See https://brew.sh/ for more information.

### Essential Tools

```bash
# Neovim 0.12+
brew install neovim

# Fuzzy finding utilities
brew install ripgrep fd

# Git interface
brew install lazygit

# Node.js (language servers, markdown preview)
brew install node
```

### Academic Workflow Tools

```bash
# LaTeX support
brew install --cask mactex-no-gui   # or mactex for full installation

# PDF viewer for LaTeX sync
brew install --cask skim

# Typst typesetting
brew install typst

# Julia programming (optional)
brew install julia

# R programming (optional)
brew install r
```

## Installation

### Clone Configuration

```bash
git clone https://github.com/SimonAB/nvim-config.git ~/.config/nvim
cd ~/.config/nvim
```

### First Launch

```bash
# Launch Neovim - plugins install automatically
nvim
```

**First launch sequence:**

1. vim.pack installs plugins (~2 minutes)
2. System theme detected and applied
3. Mason prompts for language server installation
4. Dashboard displays recent files

## Essential Keymaps

### Navigation (`<Space>` is leader)

```vim
<Space>              " Show all available commands (Which-Key)
<Space>f             " Find files (Telescope)
<Space>g             " Live grep in project
<Space>e             " Toggle file explorer
<Ctrl-h/j/k/l>       " Navigate between windows
<Shift-h/l>          " Navigate between buffers
```

### Terminal Integration

```vim
<Ctrl-t>             " Toggle terminal
<Space>Tt            " Terminal toggle (vertical)
<Space>Th            " Horizontal terminal
<Space>Tv            " Vertical terminal
<Space>Tf            " Floating terminal
<Ctrl-i>             " Send line to terminal
<Ctrl-c>             " Send code block to terminal
<Ctrl-s>             " Send visual selection to terminal (visual mode)
```

### LSP Operations

```vim
gd                   " Go to definition
K                    " Show documentation
<Space>Lf            " Format document
<Space>Lr            " Restart LSP
<Space>LR            " Show references
<Space>Ll            " List active LSP servers
```

### Document Processing

```vim
" LaTeX (localleader is \)
\lv                  " Forward search (LaTeX → PDF)
\ll                  " Compile document
\lc                  " Clean auxiliary files

" Markdown
<Space>Kp            " Start preview
<Space>Kt            " Toggle preview

" Quarto
<Space>Qp            " Preview document
<Space>Qr            " Render document

" Typst
\tp                  " Toggle preview
\tc                  " Compile PDF
```

### Julia Development

```vim
<Space>Jrh           " Horizontal Julia REPL
<Space>Jrv           " Vertical Julia REPL
<Space>Jrf           " Floating Julia REPL
<Space>Jp            " Project status
<Space>Ji            " Instantiate project
<Space>Jt            " Run tests
```

Julia REPLs: `--threads=auto`

## Configuration

### Theme Management

```vim
<Space>YTp           " Open theme picker (Telescope)
<Space>Yc            " Cycle through themes
<Space>YTs           " Show current theme
```

Themes: Catppuccin, OneDark, Tokyo Night, Nord, GitHub Dark/Light.

### Language Server Installation

```vim
<Space>MA            " Install academic LSP servers (LaTeX, Python, R, Julia)
<Space>MR            " Install all recommended servers
<Space>MU            " Update all packages
<Space>MS            " Show Mason status
:Mason               " Open Mason interface
```

Academic workflow servers:
- **LaTeX**: texlab
- **Python**: pyright, ruff-lsp
- **R**: r-languageserver
- **Julia**: julials
- **Lua**: lua-language-server
- **Markdown**: marksman

### Spell Checking

```vim
<Space>Ys            " Toggle spell check
<Space>Yse           " Set spell language to English (British)
<Space>Ysf           " Set spell language to French
```

## LaTeX Workflow Setup

### Configure Skim for SyncTeX

1. Open Skim → Preferences → Sync
2. Set **Preset** to: Custom
3. Set **Command** to: `/Users/<username>/.config/nvim/scripts/skim_inverse_search.sh`
   - Use absolute path, no tilde (~)
4. Set **Arguments** to: `%line "%file"`

### Test LaTeX Integration

```bash
cd ~/Documents/your-latex-project
nvim main.tex
```

In Neovim:
```vim
\ll                  " Compile document
\lv                  " Open PDF and jump to cursor position
```

In Skim:
- Cmd+Shift+Click on PDF to jump to corresponding line in Neovim

## Obsidian Integration

Configure Obsidian vault path in `lua/keymaps.lua` (line ~709):

```lua
local obsidian_path = "/Users/<username>/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook"
```

### Obsidian Keymaps

```vim
<Space>Oo            " Find files in Obsidian vault
<Space>On            " New note
<Space>Oc            " Toggle checkbox
<Space>Op            " Paste image
<Space>Ol            " Insert link
<Space>Ob            " Show backlinks
```

## Julia Setup

### Install Julia Language Server

```julia
using Pkg
Pkg.add("LanguageServer")
```

### Julia REPL Workflow

1. Open Julia file: `nvim script.jl`
2. Launch REPL: `<Space>Jrv` (vertical split)
3. Send code:
   - Current line: `<Ctrl-i>`
   - Code block: `<Ctrl-c>`
   - Selection: `<Ctrl-s>` (visual mode)

### Project Management

```vim
<Space>Jp            " Check project status
<Space>Ji            " Instantiate dependencies
<Space>Ju            " Update packages
<Space>Jt            " Run tests
```

## Troubleshooting

### Plugins Not Loading

```vim
:checkhealth         " Diagnose issues
:Mason               " Verify language servers
:messages            " Check error messages
```

### LSP Not Working

```vim
<Space>Ll            " List active LSP servers
<Space>Lr            " Restart LSP
:LspInfo             " Check LSP client status
```

### Terminal Issues

```bash
# Verify toggleterm installation
nvim -c "lua print(pcall(require, 'toggleterm'))"

# Test terminal mapping
<Space>Th            " Try horizontal terminal
```

### LaTeX SyncTeX Not Working

```bash
# Check script exists
ls ~/.config/nvim/scripts/skim_inverse_search.sh

# Test script manually
~/.config/nvim/scripts/skim_inverse_search.sh 10 "/absolute/path/to/test.tex"

# Check debug log
tail -f /tmp/inverse_search.log
```

## Feature Discovery

### Which-Key Integration

Press `<Space>` (500ms delay) to view commands grouped by functionality:

- **B**: Buffer operations
- **C**: Configuration management
- **G**: Git operations
- **J**: Julia development
- **L**: LSP operations
- **M**: Mason package management
- **Q**: Quarto operations
- **T**: Terminal operations
- **Y**: Toggle options

### Search Keymaps

```vim
:WhichKey            " Show all keymaps
:WhichKey <Space>    " Show leader keymaps
```

## Next Steps

1. Install language servers: `<Space>MA`
2. Configure theme: `<Space>YTp`
3. Setup LaTeX: Configure Skim for bidirectional sync
4. Customise: Add keymaps to `lua/keymaps.lua`
5. Explore: Press `<Space>` to view command groups

## Advanced Usage

### Custom Keymaps

Add to `lua/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>custom", function()
    -- Your custom functionality
end, { desc = "Custom command" })
```

### Adding Plugins

Edit `lua/plugins.lua`:

```lua
local essential_plugins = {
    { url = "https://github.com/user/plugin", name = "plugin" },
}
```

## Resources

- [Complete Keymaps Reference](reference/keymaps.md)
- [Installation Guide](INSTALLATION_GUIDE.md)
- [Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md)

---

Press `<Space>` to view available commands.
