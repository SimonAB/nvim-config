---
layout: home

hero:
  name: BabaVim
  text: Neovim Configuration for Academic Workflows
  tagline: LaTeX, Markdown, Quarto, Typst. Terminal integration. LSP support.
  actions:
    - theme: brand
      text: Quick Start
      link: /quickstart
    - theme: alt
      text: Installation Guide
      link: /INSTALLATION_GUIDE
    - theme: alt
      text: View on GitHub
      link: https://github.com/SimonAB/nvim-config

features:
  - icon: 📄
    title: Document Processing
    details: LaTeX (VimTeX, SyncTeX), Markdown (Zen Mode, live preview), Quarto, Typst.

  - icon: 🧪
    title: Scientific Computing
    details: Julia REPL (multi-threaded), Python (pyright LSP), R. Terminal code execution.

  - icon: ⚡
    title: Architecture
    details: Deferred plugin loading. Caching. Research workflow configuration.

  - icon: 🔧
    title: LSP Support
    details: 15+ languages via Mason. Completion (blink.cmp). Diagnostics.

  - icon: 🎨
    title: Interface
    details: Multiple themes. Auto dark mode. Telescope. WhichKey. NvimTree.

  - icon: 📚
    title: Research Tools
    details: Obsidian integration. Bibliography management. Code block detection. Academic keymaps.
---

## Keymap Examples

```vim
# Terminal Integration
<C-t>             # Toggle terminal (ToggleTerm)
<Leader>Tt        # Terminal toggle (vertical, smart)
<Leader>Th/Tv/Tf  # Horizontal/Vertical/Float terminal

# Document Processing (VimTeX / Typst use <localleader>, often \ )
<localleader>lv   # LaTeX forward search
<localleader>ll   # Compile LaTeX
<localleader>tp   # Typst preview toggle
<Leader>Kp        # Markdown preview
<Leader>Qp        # Quarto preview

# Julia Development
<Leader>Jrv       # Julia REPL (vertical)
<Leader>Jp        # Project status
<Leader>Ji        # Instantiate project
```

## Requirements

### Essential
- **Package Manager**:
  - **macOS**: Homebrew ([install here](https://brew.sh/))
  - **Arch Linux**: pacman (built-in) and yay/paru for AUR
- Neovim 0.12+ (required for vim.pack)
- Git
- Cargo (for blink.cmp compilation)
- ripgrep, fd (for Telescope)

### Document Processing
- **LaTeX**: 
  - **macOS**: MacTeX or BasicTeX, Skim PDF viewer
  - **Arch Linux**: texlive-most, Zathura PDF viewer
- **Typst**: 
  - **macOS**: `brew install typst`
  - **Arch Linux**: `yay -S typst` (AUR)
- **Markdown**: Node.js (for preview)

### Language Support
- **Julia**: 1.9+ with LanguageServer.jl
- **Python**: 3.8+ with pyright LSP
- **R**: 4.0+ with languageserver package

## Installation

```bash
# Clone configuration
git clone https://github.com/SimonAB/nvim-config.git ~/.config/nvim
cd ~/.config/nvim

# First launch - plugins install automatically
nvim

# Verify installation
nvim
```

See [Installation Guide](/INSTALLATION_GUIDE).

## Components

### Terminal Integration

Terminal integration:
- Toggle: `<C-t>` (ToggleTerm), `<Leader>Tt` (vertical smart toggle)
- Layouts: `<Leader>Th` / `<Leader>Tv` / `<Leader>Tf`
- Julia REPL: `--threads=auto` (`<Leader>Jrh` / `Jrv` / `Jrf`)

### Document Workflows

LaTeX: bidirectional SyncTeX
- Forward search: Neovim → PDF (`\lv`)
- Inverse search: PDF → Neovim 
  - **macOS**: Skim (Cmd+Shift+Click)
  - **Arch Linux**: Zathura (Ctrl+Click)
- Compilation: latexmk
- Bibliography management

Quarto: code execution, preview
- R, Python, Julia code blocks
- Output: PDF, HTML, Word

### Theme Management

Theme selection and preview:
- `<Leader>YTp`: Theme picker (Telescope)
- `<Leader>Yc`: Cycle themes
- Auto dark mode (system preference)
- Themes: Catppuccin, OneDark, Tokyo Night, Nord, GitHub

## Design Principles

1. Discoverability: WhichKey integration
2. Consistency: British spelling, logical keymap organisation
3. Research workflows: Academic document preparation
4. Maintainability: Modular architecture, documented code

## Documentation

1. [Quick Start](/quickstart)
2. [Installation Guide](/INSTALLATION_GUIDE)
3. [Keymaps Reference](/reference/keymaps)
4. [LSP Setup](/advanced/lsp-setup)
