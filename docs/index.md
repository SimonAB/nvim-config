---
layout: home

hero:
  name: Neovim Research Configuration
  text: Configured for Academic Workflows
  tagline: LaTeX, Markdown, Quarto, Typst with integrated terminal and LSP support
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
    details: LaTeX with VimTeX and SyncTeX, Markdown with live preview, Quarto for reproducible research, and Typst for modern typesetting.

  - icon: 🧪
    title: Scientific Computing
    details: Julia REPL with multi-threading, Python with pyright LSP, R support, and integrated terminal with smart code execution.

  - icon: ⚡
    title: Efficient Workflow
    details: Deferred plugin loading, intelligent caching, and configured for research workflows.

  - icon: 🔧
    title: LSP Support
    details: Language servers for 15+ languages via Mason, intelligent completion with blink.cmp, and comprehensive diagnostics.

  - icon: 🎨
    title: Modern Interface
    details: Multiple themes with auto dark mode, Telescope fuzzy finding, WhichKey for discoverability, and NvimTree file explorer.

  - icon: 📚
    title: Research Focused
    details: Obsidian vault integration, bibliography management, code block detection, and academic workflow keymaps.
---

## Quick Example

```vim
# Terminal Integration
<C-t>             # Toggle terminal
<Leader>Tt        # Smart terminal toggle (vertical)
<Leader>Th/Tv/Tf  # Horizontal/Vertical/Float terminal
<C-i>             # Send line to terminal
<C-c>             # Send code block to terminal

# Document Processing
\lv               # LaTeX forward search
\ll               # Compile LaTeX
<Leader>Kp        # Markdown preview
<Leader>Qp        # Quarto preview

# Julia Development
<Leader>Jrv       # Julia REPL (vertical)
<Leader>Jp        # Project status
<Leader>Ji        # Instantiate project
```

## Requirements

### Essential
- **Homebrew**: Package manager for macOS ([install here](https://brew.sh/))
- Neovim 0.12+ (required for vim.pack)
- Git
- Cargo (for blink.cmp compilation)
- ripgrep, fd (for Telescope)

### Document Processing
- **LaTeX**: MacTeX or BasicTeX, Skim PDF viewer (macOS)
- **Typst**: `brew install typst`
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

See the [Installation Guide](/INSTALLATION_GUIDE) for complete setup instructions.

## Key Features

### Terminal Integration

Smart terminal with code block detection and execution:
- Toggle terminal with `<C-t>` or `<Leader>Tt`
- Send lines, blocks, or selections to terminal
- Multiple terminal layouts (horizontal, vertical, float)
- Julia REPL with `--threads=auto` for parallel computing

### Document Workflows

Complete LaTeX workflow with bidirectional SyncTeX:
- Forward search: Neovim → PDF (`\lv`)
- Inverse search: PDF → Neovim (Cmd+Shift+Click in Skim)
- Automatic compilation with latexmk
- Bibliography management

Quarto integration for reproducible research:
- Live preview with code execution
- Support for R, Python, Julia code blocks
- Render to PDF, HTML, or Word

### Theme Management

Beautiful theme system with live preview:
- `<Leader>YTp` - Theme picker with Telescope
- `<Leader>Yc` - Cycle through themes
- Auto dark mode based on system preference
- Themes: Catppuccin, OneDark, Tokyo Night, Nord, GitHub

## Philosophy

This configuration prioritises:

1. **Discoverability**: WhichKey integration for keymap discovery
2. **Consistency**: British spelling, logical keymap organisation
3. **Research Workflows**: Configured for academic document preparation
4. **Maintainability**: Clean, documented code with modular architecture

## Next Steps

<div class="vp-doc">

1. **[Quick Start](/quickstart)** - Get started in 10 minutes
2. **[Installation Guide](/INSTALLATION_GUIDE)** - Complete setup instructions
3. **[Keymaps Reference](/reference/keymaps)** - All available keymaps
4. **[LSP Setup](/advanced/lsp-setup)** - Language server configuration

</div>
