# Skim SyncTeX — Installation & Configuration

Minimal configuration using VimTeX's native Skim backend for seamless LaTeX bidirectional synchronisation.

## Prerequisites
- macOS
- Neovim 0.12+
- VimTeX plugin (auto-installed by this configuration)
- Skim PDF viewer
- LaTeX distribution (MacTeX or BasicTeX)

## Installation Steps

### 1. Install Required Tools
```bash
# Install Neovim 0.12+ via Homebrew
brew install neovim

# Install Skim PDF viewer for LaTeX sync
brew install --cask skim

# Install LaTeX distribution (choose one)
brew install --cask mactex-no-gui  # Smaller install without GUI apps
# OR: brew install --cask mactex    # Full install with GUI applications
```

### 2. Configure Skim for SyncTeX
1. Open Skim
2. Go to **Preferences** → **Sync** → **PDF-TeX Sync**
3. Set **Preset** to: `Custom`
4. Set **Command** to: `<Full/path/to>/nvim/scripts/skim_inverse_search.sh`
   - **Important**: Use the full canonical absolute path
   - **Do not use** tilde (~) or symlinks
   - Example: `/Users/username/.config/nvim/scripts/skim_inverse_search.sh`
5. Set **Arguments** to: `%line "%file"`

### 3. Verify Configuration
Test the setup with a simple LaTeX document:
```bash
# Navigate to your LaTeX project
cd /path/to/your/latex/project

# Open main.tex in Neovim
nvim main.tex

# Compile document (in Neovim)
\ll

# Forward search to PDF
\lv
```

## Usage

### Forward Search (LaTeX → PDF)
- **In Neovim**: `<localleader>vv` or `:VimtexView`
- **Result**: PDF opens and jumps to corresponding location

### Inverse Search (PDF → LaTeX)
- **In Skim**: Cmd+Shift+Click on any location in the PDF
- **Result**: Neovim jumps to corresponding line in source file

### Compilation
- **Compile**: `<localleader>vl` or `:VimtexCompile`
- **Clean**: `<localleader>vc` or `:VimtexClean`
- **Stop**: `<localleader>vS` or `:VimtexStop`

## Troubleshooting

### Common Issues

**Inverse search not working:**
- Verify Skim command path is absolute (no tilde or symlinks)
- Check `/tmp/inverse_search.log` for debugging information
- Test script manually: `<Full/path/to>/nvim/scripts/skim_inverse_search.sh 10 "/absolute/path/to/test.tex"`

**Files not found with relative paths:**
- For complex project structures, set `INVERSE_SEARCH_PROJECT_ROOT` environment variable
- Check debug log: `tail -f /tmp/inverse_search.log` whilst testing
- Verify project structure matches supported patterns

**Skim doesn't focus or steals focus:**
- VimTeX options are already configured to prevent focus stealing
- Check `g:vimtex_view_skim_activate = 0` in configuration

### Debugging
- Use `:VimtexInfo` in Neovim to check VimTeX status
- Check `:messages` for error information
- Test Skim's command directly in terminal for path issues

## Advanced Configuration

### Custom Project Roots
For complex project structures, set the project root:
```bash
export INVERSE_SEARCH_PROJECT_ROOT=/path/to/your/project
```

### Multiple LaTeX Projects
The script automatically detects project structure and handles multiple LaTeX files within the same project.

## Benefits

- **Seamless Navigation**: Bidirectional sync between LaTeX source and PDF
- **Real-time Compilation**: Automatic compilation with LuaLaTeX and synctex
- **Perfect for Large Documents**: Ideal for theses, papers, and complex mathematical content
- **Minimal Setup**: Uses VimTeX's native Skim integration
- **Robust Error Handling**: Intelligent path resolution and debugging support

---

*This configuration provides a simple, robust LaTeX workflow optimised for academic writing and research.*
