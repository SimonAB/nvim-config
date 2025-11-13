# BabaVim

[![Documentation](https://img.shields.io/badge/docs-vitepress-blue?style=flat&logo=readthedocs)](https://simonab.github.io/nvim-config/)

Neovim configuration optimised for academic research and scientific computing. Document processing: LaTeX (VimTeX, SyncTeX), Markdown (preview, Obsidian), Quarto (R/Python/Julia execution), Typst (preview). Scientific computing: Julia REPL (multi-threaded), Python LSP (pyright), R execution. Development: LSP (15+ languages via Mason), completion (blink.cmp), terminal integration, Git integration. Modular architecture. vim.pack plugin management. Neovim 0.12+ required.

## Features

### Document Processing
- LaTeX: VimTeX, bidirectional SyncTeX (Skim)
- Markdown: Live preview, Obsidian integration
- Quarto: Code execution (R, Python, Julia)
- Typst: Live preview

### Scientific Computing
- Julia: REPL integration, multi-threaded execution
- Python: LSP (pyright)
- R: Code execution, project management

### Development Environment
- LSP: 15+ languages (Mason)
- Completion: blink.cmp
- Terminal: Code block detection
- Git: GitSigns, LazyGit

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

See [Installation Guide](docs/INSTALLATION_GUIDE.md).

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

Plugins install automatically on first launch (vim.pack). Mason prompts for language server installation.

## Quick Reference

### Leader: `<Space>`

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
| `<leader>Tt` | Terminal toggle (vertical) |
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

See [Keymaps Reference](docs/reference/keymaps.md).

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

- [Installation Guide](docs/INSTALLATION_GUIDE.md)
- [Quick Start](docs/quickstart.md)
- [Keymaps Reference](docs/reference/keymaps.md)
- [Troubleshooting](docs/TROUBLESHOOTING_GUIDE.md)

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

- Terminal mappings: `<leader>T[1,2,3]` → `<leader>T[h,v,f]` (consistency with Julia REPL)
- Julia REPL: `--threads=auto` enabled
- File formatting: Single newline at end of file on save
- Obsidian: `<leader>Op` pastes image, adds two newlines

See [CHANGELOG](docs/CHANGELOG.md) for complete version history.

## Design Principles

1. Discoverability: Which-key integration
2. Consistency: British spelling, logical keymap organisation
3. Research workflows: Academic document preparation, scientific computing
4. Maintainability: Modular architecture, documented code

## License

Provided as-is for educational and personal use.

**Note**: Requires Neovim 0.12+ (vim.pack). Older versions: use lazy.nvim or packer.nvim.
