# Neovim Configuration

A modern, feature-rich Neovim configuration optimised for performance and productivity. This configuration includes comprehensive support for development workflows, document processing, and scientific computing.

## 🚀 Performance Optimised

This configuration has been optimised for fast startup times:

- **Startup Time**: 88ms (16% improvement from 105ms)
- **Plugin Loading**: 63ms (20% improvement from 79ms)
- **Core Config**: 2ms (92% improvement from 26ms)

See [Performance Optimisations](docs/PERFORMANCE_OPTIMISATIONS.md) for detailed information.

## ✨ Features

### Core Functionality
- **Modern Completion**: blink.cmp for fast, intelligent code completion
- **LSP Support**: Comprehensive language server protocol support with Mason
- **Syntax Highlighting**: Tree-sitter for accurate syntax highlighting
- **Git Integration**: GitSigns for enhanced Git workflow
- **File Navigation**: Telescope for fuzzy finding and file navigation

### UI & Themes
- **Multiple Themes**: Catppuccin, OneDark, Tokyo Night, Nord, and more
- **Auto Dark Mode**: Automatic theme switching based on system preference
- **Status Line**: Lualine for informative status line
- **Buffer Management**: Bufferline for tab-like buffer management
- **File Explorer**: NvimTree for file system navigation

### Development Tools
- **Terminal Integration**: ToggleTerm for integrated terminal
- **Diagnostics**: Trouble for enhanced diagnostic display
- **Keymaps**: Which-key for discoverable keymaps
- **Project Management**: Enhanced project navigation and management

### Document Processing
- **LaTeX Support**: VimTeX for LaTeX document editing with Skim integration
- **Markdown**: Markdown preview and Obsidian integration
- **Typst**: Typst preview and compilation support
- **Quarto**: Quarto document processing with code execution

### Language Support
- **Julia**: Comprehensive Julia language support
- **Python**: Python development with LSP
- **R**: R language support for data science
- **Multiple Languages**: Support for many programming languages

## 🛠️ Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url> ~/.config/nvim
   cd ~/.config/nvim
   ```

2. **Install dependencies**:
   - Neovim 0.12+ (required for vim.pack)
   - Git (for plugin management)
   - Cargo (for blink.cmp compilation)

3. **First run**:
   ```bash
   nvim
   ```
   Plugins will be automatically installed on first run.

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point (optimised)
├── lua/
│   ├── config.lua          # Core editor settings
│   ├── keymaps.lua         # Key mappings (optimised)
│   ├── plugins.lua         # Plugin management (optimised)
│   ├── core/               # Core functionality
│   │   ├── theme-manager.lua
│   │   ├── plugin-manager.lua
│   │   └── theme-picker.lua
│   └── plugins/            # Plugin configurations
│       ├── blink-cmp.lua
│       ├── telescope.lua
│       ├── nvim-lspconfig.lua
│       └── ...
├── docs/                   # Documentation
│   ├── PERFORMANCE_OPTIMISATIONS.md
│   └── ...
└── scripts/                # Utility scripts
    └── performance_test.lua
```

## ⚡ Performance Features

### Deferred Loading
Non-critical operations are deferred to avoid blocking startup:
- Theme manager initialisation
- Plugin manager setup
- Dashboard configuration

### Intelligent Caching
- Dashboard content cached for 5 minutes
- Recent files and projects cached efficiently
- Limited file system operations

### Optimised Plugin Loading
- Critical plugins loaded immediately
- Heavy plugins loaded asynchronously
- Graceful error handling with pcall

## 🎯 Key Mappings

### Leader Key: `<Space>`

| Key | Description |
|-----|-------------|
| `<leader>f` | Find files (Telescope) |
| `<leader>g` | Live grep in project |
| `<leader>e` | Toggle file tree |
| `<leader>w` | Save file |
| `<leader>q` | Close buffer |

### Terminal Integration

| Key | Description |
|-----|-------------|
| `<C-t>` | Toggle terminal |
| `<C-i>` | Send current line to terminal |
| `<C-c>` | Send code block to terminal |

### Theme Management

| Key | Description |
|-----|-------------|
| `<leader>Yc` | Cycle themes |
| `<leader>Ytp` | Theme picker |
| `<leader>Yts` | Show current theme |

## 🔧 Customisation

### Adding Plugins
Edit `lua/plugins.lua` to add new plugins:

```lua
local essential_plugins = {
    -- Add your plugin here
    { url = "https://github.com/user/plugin", name = "plugin" },
}
```

### Custom Keymaps
Add custom keymaps in `lua/keymaps.lua`:

```lua
-- Your custom keymaps
vim.keymap.set("n", "<leader>custom", ":CustomCommand<CR>", { desc = "Custom command" })
```

### Theme Configuration
Configure themes in `lua/core/theme-manager.lua`:

```lua
local themes = {
    "catppuccin",
    "onedark",
    "tokyonight",
    -- Add your themes
}
```

## 📊 Performance Monitoring

### Startup Time Analysis
```bash
nvim --headless --startuptime /tmp/startup.log -c "quit"
cat /tmp/startup.log
```

### Performance Report
```lua
-- In Neovim
:lua require('scripts.performance_test').generate_report()
```

## 🐛 Troubleshooting

### Common Issues

1. **Slow startup**: Check the performance report for slow modules
2. **Plugin errors**: Use `:checkhealth` to diagnose issues
3. **Missing features**: Ensure all dependencies are installed

### Performance Issues

1. **Identify slow plugins**: Use the performance test script
2. **Check cache**: Clear dashboard cache if needed
3. **Update plugins**: Use `<leader>Cua` to update all plugins

## 📚 Documentation

- [Performance Optimisations](docs/PERFORMANCE_OPTIMISATIONS.md)
- [Installation Guide](docs/INSTALLATION_GUIDE.md)
- [Keymaps Reference](docs/reference/keymaps.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING_GUIDE.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test performance impact
5. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use.

---

**Note**: This configuration is optimised for Neovim 0.12+ and uses vim.pack for plugin management. For older Neovim versions, consider using a plugin manager like lazy.nvim or packer.nvim.
