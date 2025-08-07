# Requirements

- Neovim 0.12+
- VimTeX plugin (auto-installed by this config)
- Skim (macOS) for PDF viewing
- TeX distribution (MacTeX or BasicTeX)

Optional:
- texlab (for LSP), latexindent

Notes:
- No `nvr` is required for SyncTeX; VimTeX’s `VimtexInverseSearch` is used.
# Requirements & Dependencies

This document lists all prerequisites and installation instructions for the LaTeX/Neovim setup with automatic PDF preview functionality.

## Prerequisites

### 1. macOS Tools

#### Skim PDF Viewer
**Required for:** PDF preview and automatic refresh functionality
- **Installation:** Download from [Skim App website](https://skim-app.sourceforge.io/)
- **Alternative via Homebrew:**
  ```bash
  brew install --cask skim
  ```
- **Configuration:** Enable automatic reloading in Skim preferences

#### osascript (AppleScript)
**Required for:** Controlling Skim PDF viewer programmatically
- **Installation:** Pre-installed on all macOS systems
- **Verification:**
  ```bash
  osascript -e 'tell application "System Events" to get name of processes'
  ```

### 2. Neovim

#### Neovim Editor
**Required for:** Main text editor for LaTeX files
- **Installation via Homebrew:**
  ```bash
  brew install neovim
  ```
- **Alternative installation methods:**
  - [GitHub Releases](https://github.com/neovim/neovim/releases)
  - MacPorts: `sudo port install neovim`
- **Minimum version:** 0.8.0+ recommended
- **Verification:**
  ```bash
  nvim --version
  ```

#### vim.pack v0.12 Package Manager
**Required for:** Managing Neovim plugins
- **Installation:**
  ```bash
  git clone https://github.com/k-takata/vim.pack.git ~/.local/share/nvim/site/pack/vim.pack/start/vim.pack
  ```
- **Documentation:** [vim.pack GitHub](https://github.com/k-takata/vim.pack)
- **Note:** User prefers the new 0.12 version specifically

### 3. Neovim Remote (nvr)

#### nvr Command Line Tool
**Required for:** Remote control of Neovim instances
- **Installation via pip:**
  ```bash
  pip3 install neovim-remote
  ```
- **Alternative via pipx:**
  ```bash
  pipx install neovim-remote
  ```
- **GitHub:** [neovim-remote](https://github.com/mhinz/neovim-remote)
- **Verification:**
  ```bash
  nvr --version
  ```

### 4. Warp Terminal (Optional)

#### Warp.app
**Required for:** Enhanced terminal experience (optional but recommended)
- **Installation:** Download from [Warp website](https://www.warp.dev/)
- **Alternative via Homebrew:**
  ```bash
  brew install --cask warp
  ```
- **Note:** Provides better integration with development workflows

### 5. VimTeX Plugin

#### VimTeX LaTeX Plugin
**Required for:** LaTeX support in Neovim
- **Installation via vim.pack:**
  ```bash
  git clone https://github.com/lervag/vimtex.git ~/.local/share/nvim/site/pack/vimtex/start/vimtex
  ```
- **Alternative via other package managers:**
  - vim-plug: `Plug 'lervag/vimtex'`
  - packer.nvim: `use 'lervag/vimtex'`
- **GitHub:** [VimTeX](https://github.com/lervag/vimtex)
- **Documentation:** `:help vimtex` (within Neovim)

## Additional LaTeX Requirements

### LaTeX Distribution
**Required for:** Compiling LaTeX documents
- **Recommended:** MacTeX (full distribution)
  ```bash
  brew install --cask mactex
  ```
- **Lightweight alternative:** BasicTeX
  ```bash
  brew install --cask basictex
  ```
- **Verification:**
  ```bash
  pdflatex --version
  ```

## Installation Order

1. Install Homebrew (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install core dependencies:
   ```bash
   brew install neovim
   brew install --cask skim
   brew install --cask mactex
   pip3 install neovim-remote
   ```

3. Install vim.pack v0.12:
   ```bash
   git clone https://github.com/k-takata/vim.pack.git ~/.local/share/nvim/site/pack/vim.pack/start/vim.pack
   ```

4. Install VimTeX plugin:
   ```bash
   git clone https://github.com/lervag/vimtex.git ~/.local/share/nvim/site/pack/vimtex/start/vimtex
   ```

5. (Optional) Install Warp terminal:
   ```bash
   brew install --cask warp
   ```

## Verification Commands

After installation, verify all components:

```bash
# Check Neovim
nvim --version

# Check vim.pack
ls ~/.local/share/nvim/site/pack/vim.pack/start/

# Check nvr
nvr --version

# Check LaTeX
pdflatex --version

# Check Skim (should open application)
open -a Skim

# Check VimTeX plugin
ls ~/.local/share/nvim/site/pack/vimtex/start/
```

## Troubleshooting

### Common Issues

1. **nvr command not found**
   - Ensure Python pip is in PATH
   - Try reinstalling with `pip3 install --user neovim-remote`

2. **VimTeX not loading**
   - Check plugin installation path
   - Verify Neovim can find the plugin: `:echo &runtimepath`

3. **Skim not responding to AppleScript**
   - Grant Terminal/Warp accessibility permissions in System Preferences
   - Check Skim preferences for "Check for file changes"

4. **LaTeX compilation errors**
   - Ensure MacTeX/BasicTeX is in PATH: `echo $PATH | grep tex`
   - May need to restart terminal after LaTeX installation

## Links & Resources

- [Neovim](https://neovim.io/)
- [vim.pack Package Manager](https://github.com/k-takata/vim.pack)
- [VimTeX Plugin](https://github.com/lervag/vimtex)
- [Neovim Remote](https://github.com/mhinz/neovim-remote)
- [Skim PDF Viewer](https://skim-app.sourceforge.io/)
- [Warp Terminal](https://www.warp.dev/)
- [MacTeX](https://www.tug.org/mactex/)
