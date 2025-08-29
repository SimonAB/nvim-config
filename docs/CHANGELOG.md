# Changelog

## [Latest] - Enhanced Theme Management System

### 🎨 New Features
- **Theme Picker**: Rich floating window interface for theme selection
  - Visual theme categories (dark 🌙, light ☀️, special 🎨)
  - **Automatic Live Preview**: Themes preview instantly as cursor moves
  - Quick apply without closing with `<C-y>`
  - Fuzzy search through all available themes
  - Current theme indicator with ● symbol
  - **No Number Indexing**: Clean scrolling list without numbered entries
  - **Smooth Navigation**: Arrow keys, j/k, and mouse scrolling support

### 🔧 Enhanced Theme Management
- **Modular Architecture**: New `core/theme-picker.lua` module
- **Integration**: Seamless integration with existing theme manager
- **Performance**: Optimized theme loading and switching
- **Feedback**: Enhanced notifications and status updates
- **Robust Loading**: Handles Telescope loading issues gracefully
- **Fallback Support**: Works with vim.ui.select when Telescope unavailable

### ⌨️ New Keybindings
- **`<Space>Ytp`**: Open theme picker (floating window)
- **`<Space>Yts`**: Show current theme
- **`<Space>Yc`**: Cycle through themes (enhanced with better fallback)

### 🏗️ Architecture Improvements
- **Theme Picker Module**: Dedicated theme selection system
- **Lazy Loading**: Efficient loading of theme picker functionality
- **Fallback Support**: Graceful degradation when components unavailable
- **Integration**: Clean integration with existing theme management

### 📚 Documentation Updates
- **Quickstart Guide**: Added theme management section
- **Keymap Documentation**: Updated with new theme commands
- **User Experience**: Clear instructions for theme picker usage

---

## [Previous] - Documentation Updates and Consistency Review

### Documentation Improvements
- **README.md**: Updated to reflect current keymap structure with uppercase group keys
- **Plugin Architecture**: Updated plugin list to include mini-nvim subdirectory structure
- **Keymap Documentation**: All key mappings now accurately reflect current configuration
- **British Spelling**: Verified and maintained throughout all documentation
- **Installation Guide**: Current and accurate installation instructions

### Configuration Review
- **Review Report**: Updated to reflect current state with uppercase group keys
- **Consistency Check**: All documentation now matches actual configuration
- **Plugin List**: Accurate representation of current plugin structure
- **Keymap Structure**: Documentation reflects professional uppercase group organisation

### Benefits
- **Accurate Documentation**: All guides now match the actual configuration
- **Professional Appearance**: Consistent uppercase group keys throughout
- **Easy Maintenance**: Clear documentation structure for future updates
- **User Experience**: Reliable installation and usage instructions

## [Previous] - Uppercase Group Key Standardisation

### Major Keymap Reorganisation
- **Uppercase Group Keys**: Standardised all which-key group prefixes to use **uppercase letters** for consistency and improved visual clarity
- **Enhanced Descriptions**: Updated all command descriptions to use proper capitalisation and clear, explicit language
- **Professional Appearance**: Which-key popups now display clean, consistent uppercase group keys that match their descriptive names

### Group Key Changes
- `<leader>B` → **Buffer** operations (was `<leader>b`)
- `<leader>C` → **Configuration** management (was `<leader>c`)
- `<leader>G` → **Git** operations (was `<leader>g`)
- `<leader>J` → **Julia** development (was `<leader>j`)
- `<leader>L` → **LSP** operations (was `<leader>l`)
- `<leader>O` → **Otter** multi-language support (was `<leader>o`)
- `<leader>P` → **Plugin** management (was `<leader>p`)
- `<leader>Q` → **Quarto** operations (already uppercase)
- `<leader>S` → **Search** operations (was `<leader>s`)
- `<leader>T` → **Terminal** operations (already uppercase)
- `<leader>W` → **Window** operations (was `<leader>w`)
- `<leader>X` → **Trouble** diagnostics (was `<leader>x`)
- `<leader>Y` → **Toggle** options (already uppercase)

### Individual Command Updates
**All individual commands updated to match their uppercase group keys:**
- Configuration: `<leader>Cs`, `<leader>Cd`, `<leader>Cg`
- Buffer management: `<leader>Bf`, `<leader>Bc`, `<leader>Bb`, `<leader>Bn`, `<leader>Bj`
- Search operations: `<leader>Sf`, `<leader>St`, `<leader>Sr`, `<leader>Sb`, etc.
- LSP operations: `<leader>Ll`, `<leader>Lr`, `<leader>Lf`, `<leader>LR`, `<leader>Ld`, etc.
- Git operations: `<leader>Gs`, `<leader>Gp`, `<leader>Gg`
- Julia operations: `<leader>Jp`, `<leader>Ji`, `<leader>Ju`, `<leader>Jt`, `<leader>Jd`
- Julia REPL: `<leader>Jrh`, `<leader>Jrv`, `<leader>Jrf`
- Trouble diagnostics: `<leader>Xw`, `<leader>Xd`, `<leader>Xl`, `<leader>Xq`, `<leader>Xx`
- Plugin management: `<leader>Pi`, `<leader>Pu`, `<leader>Pc`, `<leader>Ps`
- Otter operations: `<leader>Oa`, `<leader>Od`

### Preserved Individual Commands
- `<leader>q` - Close buffer (quick access)
- `<leader>e` - Toggle file explorer
- `<leader>f` - Find files
- `<leader>x` - Toggle checkbox (Obsidian)

### Benefits
- **Visual Consistency**: Group keys now match their descriptive names (e.g., `B` for "Buffer")
- **Professional Appearance**: Clean, consistent uppercase letters in which-key popups
- **Better Organisation**: Clear distinction between group prefixes and individual commands
- **Enhanced Workflow**: More intuitive key combinations that align with group names
- **Improved Discoverability**: Easier to remember and navigate keymap structure

## [Earlier] - Keymap Reorganisation

### Group Letter Remapping
- **Toggle Group**: Remapped from `<leader>T*` to `<leader>Y*` to resolve collision with Terminal group
  - `<leader>Yw` - Toggle line wrapping
  - `<leader>Yn` - Toggle line numbers
  - `<leader>Yc` - Cycle through colourschemes

### Addition of Split Group
- **New Split Group**: Added `<leader>|*` prefix for split window commands
  - `<leader>|v` - Split window vertically
  - `<leader>|h` - Split window horizontally

### Key Collision Resolution
- **Terminal Group**: Retained `<leader>T*` for all terminal-related functions
  - `<leader>T1` - Horizontal terminal
  - `<leader>T2` - Vertical terminal
  - `<leader>T3` - Float terminal
  - `<leader>Tk` - Clear terminal
  - `<leader>Td` - Delete terminal
- **Search Group**: Retained `<leader>S*` for search operations (managed by plugins)
- **Toggle Group**: Moved to `<leader>Y*` to avoid "T" collision
- **Split Group**: Uses `<leader>|*` to avoid "S" collision

### Rationale
These changes ensure logical grouping of related commands whilst preventing key conflicts:
- Terminal operations remain under the intuitive "T" prefix
- Toggle operations use "Y" (phonetically similar to "toggle")
- Split operations use "|" symbol (visually represents splitting)
- Search operations maintain "S" prefix for consistency with plugin conventions

All changes maintain backwards compatibility where possible whilst improving the logical organisation of keybindings.
