# Modern Neovim Configuration

A modern, comprehensive Neovim configuration harmonised from LunarVim for Neovim 0.12+, using British conventions. Features vim.pack plugin management, Julia LSP integration, and extensive LaTeX support.

## 🔄 VimTeX + Skim Inverse Search Integration

One of the standout features of this configuration is the seamless integration between VimTeX, Skim PDF viewer, and Neovim for LaTeX document editing. This setup enables **inverse search**, a powerful workflow enhancement that bridges the gap between your LaTeX source code and the compiled PDF output.

### What is Inverse Search?

Inverse search (also known as backward search or SyncTeX) is a bidirectional navigation system that allows you to:

- **Forward Search**: Jump from a specific line in your LaTeX source code directly to the corresponding location in the PDF
- **Backward Search**: Click on any part of the PDF and immediately navigate to the exact line in your source code that generated that content

This creates a seamless editing experience where you can visualise your changes in real-time and quickly locate the source of any content you see in the rendered document.

### Why This Integration Matters

**Traditional LaTeX Workflow Problems:**
- Switching between editor and PDF viewer breaks concentration
- Finding the source of specific content in large documents is time-consuming
- Difficult to correlate compilation errors with source locations
- No visual feedback when editing complex mathematical expressions or figures

**Benefits of VimTeX + Skim + Neovim Integration:**

1. **Seamless Navigation**: Instantly jump between source and output with a single keypress or click
2. **Enhanced Productivity**: Spend more time writing and less time searching for content
3. **Real-time Feedback**: See how changes affect the final document without losing your place
4. **Error Debugging**: Quickly locate and fix LaTeX compilation errors
5. **Complex Document Management**: Effortlessly navigate large documents with multiple chapters and sections
6. **Visual Context**: Understand how your code translates to the final output, especially useful for tables, figures, and mathematical expressions

### How It Works in This Configuration

**VimTeX** provides the LaTeX editing capabilities within Neovim, including syntax highlighting, compilation, and SyncTeX support. **Skim** (macOS PDF viewer) offers excellent SyncTeX integration and fast rendering. **Neovim** serves as the central hub, coordinating between the editor and viewer.

Key features enabled in this setup:
- Automatic SyncTeX generation during compilation
- Forward search with `<leader>lv` (LaTeX view)
- Backward search by Cmd+clicking in Skim
- Real-time PDF updates on file save
- Warp terminal compatibility for enhanced workflow

### Terminal Integration

This configuration is specifically optimised for terminal-based workflows, including compatibility with Warp terminal. The inverse search functionality works seamlessly whether you're using Neovim in a terminal emulator or as a standalone application, making it perfect for developers who prefer command-line environments.

### Inverse Search Script Internals

The `skim_inverse_search.sh` script implements a robust three-tier approach to handle inverse search from Skim PDF viewer to Neovim:

#### Method 1: Headless VimtexInverseSearch Call

The preferred method using VimTeX's built-in inverse search functionality:

1. **Direct Command**: Executes `nvim --headless -c "VimtexInverseSearch $LINE '$FILE'"`
2. **VimTeX Integration**: Relies on VimTeX's internal inverse search mechanism
3. **Background Execution**: Runs in headless mode without creating a visible Neovim instance

This method provides native VimTeX functionality and works without requiring server setup, making it the most reliable primary option.

#### Method 2: Using nvr with Existing Server Socket

Fallback method when a Neovim server is already running:

1. **Prerequisite Check**: Verifies that `nvr` (Neovim Remote) is available at `/opt/homebrew/bin/nvr` and that a server socket exists at `/tmp/nvim_server`
2. **File Opening**: Uses `nvr --remote-silent` to open the target file in the existing Neovim instance
3. **Line Navigation**: Sends a `:LINE<CR>` command via `nvr --remote-send` to jump to the specified line
4. **Focus Management**: Uses AppleScript to bring Warp terminal to the foreground
5. **Success Exit**: Exits with status 0 if successful

This method provides fast performance and preserves existing editor state when an nvr server is available.

#### Method 3: Fallback to Opening New Neovim Instance via osascript

The final fallback method for when no Neovim instances are running:

1. **Process Check**: Uses `pgrep nvim` to detect any running Neovim processes
2. **Existing Instance**: If found, focuses Warp terminal assuming Neovim is running there
3. **New Instance**: If no instance found, uses AppleScript to:
   - Activate Warp terminal
   - Wait 0.5 seconds for terminal to become active
   - Send keystrokes to execute `nvim +$LINE "$FILE"`
   - Press Enter to execute the command

This method ensures inverse search works even from a cold start, though it's the slowest option.

#### Debug Logging Flow

Comprehensive logging is implemented throughout the script for troubleshooting:

- **Log Location**: All debug information is written to `/tmp/inverse_search.log`
- **Timestamp Format**: Each log entry includes `$(date)` for precise timing information
- **Method Tracking**: Logs which method is being attempted ("Trying VimtexInverseSearch", "Trying nvr", etc.)
- **Success/Failure States**: Records the outcome of each method attempt
- **Command Output**: Redirects both stdout and stderr from nvr and osascript commands to the log
- **Process State**: Logs whether existing Neovim instances were found

**Example log flow:**
```
Tue Jan 14 10:30:15 GMT 2025: Inverse search called with LINE=42, FILE=/path/to/document.tex
Tue Jan 14 10:30:15 GMT 2025: Trying VimtexInverseSearch
Tue Jan 14 10:30:15 GMT 2025: Trying nvr with existing server
Tue Jan 14 10:30:15 GMT 2025: Positioned cursor at line 42
Tue Jan 14 10:30:15 GMT 2025: nvr command completed
```

This logging system makes it easy to diagnose inverse search failures and understand which method successfully handled the request.

## 📁 File Structure

```
~/.config/nvim/
├── init.lua              # Main configuration entry point
├── lua/
│   ├── config.lua        # Core editor settings and options
│   ├── keymaps.lua       # Key mappings and shortcuts
│   └── plugins.lua       # Plugin management and configuration
└── README.md             # This documentation
```

## 🚀 Features

### Core Functionality
- **Modern Plugin Management**: Uses vim.pack (Neovim 0.12+) instead of external plugin managers
- **Intelligent Completion**: Powered by blink.cmp with LSP integration
- **Syntax Highlighting**: TreeSitter for enhanced syntax highlighting
- **File Navigation**: Telescope fuzzy finder and nvim-tree file explorer
- **Git Integration**: Gitsigns and LazyGit integration
- **Terminal Integration**: ToggleTerm with advanced code execution features

### Language Support
- **Julia**: Full LSP support with auto-completion and diagnostics
- **LaTeX**: VimTeX integration with Skim PDF viewer for inverse search
- **Markdown**: Preview and R Markdown/Quarto support
- **Multiple Languages**: Configured for Lua, Python, and more

### UI & Themes
- **Multiple Themes**: Catppuccin, OneDark, Tokyo Night, Nord, and GitHub themes
- **Auto Dark Mode**: Automatic theme switching based on system appearance
- **Status Line**: Lualine with git and LSP information
- **Buffer Management**: BufferLine with tabs and diagnostics

## 📋 File Descriptions

### `init.lua`
The main configuration entry point that:
- Sets up leader keys (`<Space>` and `\`)
- Bootstraps the plugin system
- Loads core configurations and keymaps
- Configures theme switching and auto-dark-mode
- Sets up Julia LSP auto-start fix

### `lua/config.lua`
Core editor settings including:
- Line numbering and indentation preferences
- Search and visual behaviour
- Spell checking (British English)
- VimTeX configuration with Skim integration
- Warp terminal compatibility for inverse search
- Performance optimisations

### `lua/keymaps.lua`
Comprehensive key mappings organised by function:
- **Leader Key Groups**: Config, buffers, search, LSP, terminal, git
- **Config Management**: Hot-reloading of configuration files
- **Code Execution**: Send code blocks to terminal (R Markdown/Quarto support)
- **Navigation**: Window management and file operations
- **Utility Functions**: Colourscheme cycling, toggle options

### `lua/plugins.lua`
Plugin management and configuration:
- **Plugin Installation**: Automatic git-based plugin installation
- **LSP Configuration**: Julia LSP with blink.cmp integration
- **UI Plugins**: Themes, status line, file explorer
- **Development Tools**: Telescope, TreeSitter, Git integration
- **Terminal Integration**: Enhanced terminal workflow

## ⌨️ Key Mappings

### Leader Key: `<Space>`

The configuration uses **uppercase group keys** for consistent organisation and intuitive navigation with which-key.

#### Configuration Management (`<leader>C`)
- `<leader>Cs` - Source/reload all configuration files
- `<leader>Cd` - Browse config directory (Telescope)
- `<leader>Cg` - Search config directory (live grep)

#### Buffer Management (`<leader>B`)
- `<leader>Bf` - Find buffers (Telescope)
- `<leader>Bq` - Close buffer
- `<leader>Bb` - Previous buffer
- `<leader>Bn` - Next buffer
- `<leader>Bj` - Jump to buffer (BufferLinePick)

#### File Operations
- `<leader>f` - Find files (Telescope) *[individual command]*
- `<leader>e` - Toggle file explorer (NvimTree) *[individual command]*

#### Search Operations (`<leader>S`)
- `<leader>Sf` - Find files (Telescope)
- `<leader>St` - Text search (live grep)
- `<leader>Sr` - Recent files
- `<leader>Sb` - Git branches
- `<leader>Sc` - Colourscheme picker
- `<leader>Sh` - Help tags
- `<leader>Sk` - Keymaps
- `<leader>SC` - Commands
- `<leader>Sl` - Resume last search

#### LSP Operations (`<leader>L`)
- `<leader>Ll` - List available LSP servers
- `<leader>Lr` - Restart LSP
- `<leader>Lf` - Format document
- `<leader>LR` - Show references
- `<leader>Ld` - Buffer diagnostics (Telescope)
- `<leader>Lw` - Workspace diagnostics (Telescope)
- `<leader>Ls` - Document symbols (Telescope)
- `<leader>LS` - Workspace symbols (Telescope)

#### Git Operations (`<leader>G`)
- `<leader>Gs` - Git status
- `<leader>Gp` - Git pull
- `<leader>Gg` - LazyGit (floating terminal)

#### Julia Development (`<leader>J`)
- `<leader>Jp` - Project status (Pkg.status())
- `<leader>Ji` - Instantiate project (Pkg.instantiate())
- `<leader>Ju` - Update project (Pkg.update())
- `<leader>Jt` - Run tests (Pkg.test())
- `<leader>Jd` - Generate docs (Documenter)

##### Julia REPL (`<leader>Jr`)
- `<leader>Jrh` - Horizontal REPL
- `<leader>Jrv` - Vertical REPL
- `<leader>Jrf` - Floating REPL

#### Quarto/Jupyter (`<leader>Q`)
- `<leader>Qp` - Quarto preview
- `<leader>Qc` - Close preview
- `<leader>Qr` - Quarto render

##### Molten (Jupyter) (`<leader>Qm`)
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

#### Otter Multi-language Support (`<leader>O`)
- `<leader>Oa` - Activate Otter
- `<leader>Od` - Deactivate Otter

#### Plugin Management (`<leader>P`)
- `<leader>Pi` - Install plugins
- `<leader>Pu` - Update plugins
- `<leader>Pc` - Compile plugins
- `<leader>Ps` - Sync plugins (install + update + compile)

#### Terminal Operations (`<leader>T`)
- `<Ctrl-t>` - Toggle terminal *[direct key]*
- `<Ctrl-i>` - Send current line to terminal *[direct key]*
- `<Ctrl-s>` - Send visual selection to terminal *[direct key]*

#### Trouble Diagnostics (`<leader>X`)
- `<leader>Xw` - Workspace diagnostics
- `<leader>Xd` - Document diagnostics
- `<leader>Xl` - Location list
- `<leader>Xq` - Quickfix
- `<leader>Xx` - Toggle Trouble

#### Window/Split Operations (`<leader>|` and `<leader>W`)
- `<leader>|v` - Vertical split
- `<leader>|h` - Horizontal split

#### Toggle Options (`<leader>Y`)
- `<leader>Ys` - Toggle spell check

#### Individual Commands
- `<leader>q` - Close buffer (quick access)
- `<leader>t` - Test keymap (for debugging)
- `<leader>?` - Which-key status
- `<leader>x` - Toggle checkbox (Obsidian)

### Direct Key Mappings (No Leader)
- `<Shift-l>` - Next buffer (BufferLine)
- `<Shift-h>` - Previous buffer (BufferLine)
- `gd` - Go to definition (LSP)
- `K` - Hover information (LSP)

## 🛠️ Requirements

### System Requirements
- **Neovim**: Version 0.12+ (uses vim.pack)
- **Git**: For plugin installation
- **Node.js**: For some language servers and plugins

### Optional Dependencies
- **Julia**: For Julia LSP support
- **LaTeX**: For VimTeX functionality
- **Skim PDF Viewer**: For LaTeX inverse search (macOS)
- **ripgrep**: Enhanced grep functionality for Telescope
- **fd**: Better file finding for Telescope

### Language Servers
The configuration automatically sets up:
- **Julia Language Server**: Via LanguageServer.jl
- **Additional LSPs**: Can be added in `plugins.lua`

## 🎨 Themes

Available themes (cycle with `<leader>yc`):
1. **Catppuccin** - Modern pastel theme
2. **OneDark** - Atom-inspired dark theme
3. **Tokyo Night** - Dark theme with vibrant colours
4. **Nord** - Arctic-inspired colour palette
5. **GitHub** - GitHub-inspired themes (light/dark)

Auto dark mode switches between light and dark variants based on system appearance.

## 🔧 Customisation

### Adding New Plugins
Add plugins to the `plugins` table in `lua/plugins.lua`:
```lua
{ url = 'https://github.com/author/plugin', name = 'plugin-name' },
```

### Modifying Key Mappings
Edit `lua/keymaps.lua` to add or modify key mappings. Use the existing patterns for consistency.

### Changing Editor Behaviour
Modify settings in `lua/config.lua` for editor behaviour, or `init.lua` for theme and startup configuration.

## 📚 Learning Resources

- **Which-Key**: Press `<Space>` (leader key) and wait to see available key mappings organised by uppercase groups
- **Telescope**: Use `<leader>Sk` to search through all keymaps
- **Help**: Use `:help` for Neovim documentation
- **LSP**: Use `K` for hover information, `gd` for go to definition
- **Configuration**: Use `<leader>Cs` to reload all configuration files
- **Keymap Discovery**: Use `<leader>?` to check which-key status

## 📚 Documentation

- **[Installation Guide](INSTALLATION_GUIDE.md)** - Step-by-step setup for Skim inverse search
- **[Requirements](REQUIREMENTS.md)** - Dependencies and system requirements
- **[Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md)** - Common issues and solutions

## 🐛 Quick Troubleshooting

### Plugin Issues
- Check if plugins installed correctly: look for messages during startup
- Manually install missing plugins: they're auto-installed on first run
- Clear plugin cache: remove `~/.local/share/nvim/pack/` and restart

### LSP Issues
- **Julia LSP**: Ensure Julia is in PATH and LanguageServer.jl is installed
- **Other LSPs**: Check `:LspInfo` for server status
- **Completion**: Ensure blink.cmp is properly loaded

### Theme Issues
- **Auto Dark Mode**: May need system permissions on macOS
- **Missing Colours**: Ensure terminal supports true colour
- **Theme Not Loading**: Check theme installation in plugin directory

**For detailed troubleshooting, see [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md)**

## 📝 Notes

- **British Spelling**: Configuration uses British English conventions (colour, harmonised, etc.)
- **Modern Neovim**: Takes advantage of Neovim 0.12+ features
- **Terminal Integration**: Optimised for terminal-based development workflow
- **Academic Focus**: Enhanced support for LaTeX and research workflows

## 🤝 Contributing

This configuration is personal but feel free to adapt it for your needs. The modular structure makes it easy to:
- Add new plugins in `plugins.lua`
- Extend key mappings in `keymaps.lua`
- Adjust editor behaviour in `config.lua`

---

*Configuration harmonised from LunarVim for modern Neovim development*
