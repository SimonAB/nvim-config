# Neovim Research Configuration

[![Documentation](https://img.shields.io/badge/docs-vitepress-blue?style=flat&logo=readthedocs)](https://simonab.github.io/nvim-config/)

A Neovim configuration for academic research, scientific computing, and document preparation. Designed for researchers requiring LaTeX, Markdown, Quarto, and Typst workflows with integrated terminal execution and LSP support.

## Features

### Document Processing
- **LaTeX**: VimTeX with bidirectional SyncTeX (Skim integration)
- **Markdown**: Live preview with Obsidian vault integration
- **Quarto**: Document processing with code execution (R, Python, Julia)
- **Typst**: Modern typesetting with live preview

### Scientific Computing
- **Julia**: Comprehensive REPL integration with multi-threaded execution
- **Python**: Full LSP support with pyright
- **R**: Code execution and project management

### Development Environment
- **LSP**: Language server protocol for 15+ languages via Mason
- **Completion**: Intelligent completion via blink.cmp
- **Terminal**: Integrated terminal with smart code block detection
- **Git**: GitSigns, LazyGit integration

## Requirements

### Essential
- **Homebrew**: Package manager for macOS ([install here](https://brew.sh/))
- Neovim 0.12+ (required for vim.pack plugin management)
- Git
- Cargo (for blink.cmp compilation)
- ripgrep, fd (for Telescope fuzzy finding)

### Document Processing
- **LaTeX**: MacTeX or BasicTeX, Skim PDF viewer (macOS)
- **Typst**: `brew install typst`
- **Markdown**: Node.js (for preview plugin)

### Language Support
- **Julia**: Julia 1.9+ with LanguageServer.jl
- **Python**: Python 3.8+ with pyright LSP
- **R**: R 4.0+ with languageserver package

See [Installation Guide](docs/INSTALLATION_GUIDE.md) for complete setup instructions.

## Installation

```bash
# Clone configuration
git clone https://github.com/SimonAB/nvim-config.git ~/.config/nvim
cd ~/.config/nvim

# First launch (plugins auto-install)
nvim

# Verify installation
nvim
```

On first launch, plugins install automatically via vim.pack. Mason will prompt to install recommended language servers.

## Quick Reference

### Leader Key: `<Space>`

| Key | Action |
|-----|--------|
| `<leader>f` | Find files (Telescope) |
| `<leader>g` | Live grep in project |
| `<leader>e` | Toggle file explorer |
| `<leader>w` | Save file |

### Terminal Integration

| Key | Action |
|-----|--------|
| `<C-t>` | Toggle terminal |
| `<leader>Tt` | Smart terminal toggle (vertical) |
| `<leader>Th/Tv/Tf` | Horizontal/Vertical/Float terminal |
| `<C-i>` | Send line to terminal |
| `<C-c>` | Send code block to terminal |

### Document Workflows

| Key | Action |
|-----|--------|
| `<localleader>lv` | LaTeX forward search |
| `<localleader>ll` | Compile LaTeX |
| `<leader>Kp` | Markdown preview |
| `<leader>Qp` | Quarto preview |

### Julia Development

| Key | Action |
|-----|--------|
| `<leader>Jrh/v/f` | Julia REPL (horizontal/vertical/float) |
| `<leader>Jp` | Project status |
| `<leader>Ji` | Instantiate project |

Julia REPLs launch with `--threads=auto` for parallel computing.

### Theme Management

| Key | Action |
|-----|--------|
| `<leader>Yc` | Cycle themes |
| `<leader>YTp` | Theme picker (Telescope) |
| `<leader>YTs` | Show current theme |

See [Keymaps Reference](docs/reference/keymaps.md) for complete keymap documentation.

## Configuration Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   ├── config.lua        # Editor settings
│   ├── keymaps.lua       # Keymaps
│   ├── plugins.lua       # Plugin definitions
│   ├── core/             # Core functionality
│   │   ├── theme-manager.lua
│   │   ├── plugin-manager.lua
│   │   └── theme-picker.lua
│   └── plugins/          # Plugin configurations
│       ├── blink-cmp.lua
│       ├── nvim-lspconfig.lua
│       ├── telescope.lua
│       ├── toggleterm-nvim.lua
│       └── vimtex.lua
├── docs/                 # Documentation
└── scripts/              # Utility scripts
```

## Customisation

### Adding Plugins

Edit `lua/plugins.lua`:

```lua
local essential_plugins = {
    { url = "https://github.com/user/plugin", name = "plugin" },
}
```

### Custom Keymaps

Add to `lua/keymaps.lua`:

```lua
vim.keymap.set("n", "<leader>custom", ":CustomCommand<CR>", 
    { desc = "Custom command" })
```

### LSP Configuration

Install language servers via Mason:

```vim
:Mason                    " Open Mason interface
<leader>MA               " Install academic LSP servers
<leader>MR               " Install all recommended servers
```

## Documentation

- [Installation Guide](docs/INSTALLATION_GUIDE.md) - Complete setup instructions
- [Quick Start](docs/quickstart.md) - Get started in 5 minutes
- [Keymaps Reference](docs/reference/keymaps.md) - Complete keymap documentation
- [Troubleshooting](docs/TROUBLESHOOTING_GUIDE.md) - Common issues and solutions

## Troubleshooting

### LSP Issues

```vim
:checkhealth          " Diagnose Neovim health
:Mason                " Check installed language servers
<leader>Ll            " List active LSP servers
<leader>Lr            " Restart LSP
```


### LaTeX SyncTeX

- Verify Skim preferences: Sync → Custom command
- Check script path: Use absolute path, no tilde (~)
- Debug log: `tail -f /tmp/inverse_search.log`

## Recent Changes

- **Terminal Mappings**: Changed from `<leader>T[1,2,3]` to `<leader>T[h,v,f]` for consistency with Julia REPL patterns
- **Julia REPL**: Added `--threads=auto` for automatic multi-threading
- **File Formatting**: Enforces single newline at end of file on save
- **Obsidian**: `<leader>Op` pastes image and adds two newlines

See [CHANGELOG](docs/CHANGELOG.md) for complete version history.

## Philosophy

This configuration prioritises:

1. **Discoverability**: Which-key integration for keymap discovery
2. **Consistency**: British spelling, logical keymap organisation
3. **Research Workflows**: Configured for academic document preparation and scientific computing
4. **Maintainability**: Clean, documented code with modular architecture

## License

This configuration is provided as-is for educational and personal use.

---

**Note**: Configured for Neovim 0.12+ with vim.pack. For older versions, consider lazy.nvim or packer.nvim instead.
