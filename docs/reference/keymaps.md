# Keymaps Reference

Complete reference of all keybindings in StellarVIM, organized by functionality.

## Leader Keys

- **Primary Leader**: `<Space>`
- **Local Leader**: `\` (for document-specific commands)

## Navigation

### Window Navigation
```vim
<C-h>           " Move to left window
<C-j>           " Move to bottom window
<C-k>           " Move to top window
<C-l>           " Move to right window
```

### Window Resizing
```vim
<S-Up>          " Decrease window height
<S-Down>        " Increase window height
<S-Left>        " Decrease window width
<S-Right>       " Increase window width

<Leader>Wk      " Decrease window height (universal)
<Leader>Wj      " Increase window height (universal)
<Leader>Wh      " Decrease window width (universal)
<Leader>Wl      " Increase window width (universal)
```

### Buffer Navigation
```vim
<S-h>           " Previous buffer
<S-l>           " Next buffer

<Leader>Bb      " Previous buffer (BufferLine)
<Leader>Bn      " Next buffer (BufferLine)
<Leader>Bj      " Jump to buffer (BufferLine pick)
<Leader>Bq      " Close buffer
```

### File Navigation
```vim
<Leader>f       " Find files (Telescope)
<Leader>F       " Find files by frequency (Telescope)
<Leader>g       " Live grep (Telescope)
<Leader>gw      " Live grep in working directory
<Leader>gc      " Live grep in config
<Leader>gf      " Live grep in current file directory
<Leader>e       " Toggle file explorer (NvimTree)
```

## LSP Operations

### Core LSP
```vim
gd              " Go to definition
gD              " Go to declaration
K               " Show hover documentation
<Leader>Lf      " Format document
<Leader>LR      " Show references
<Leader>Lr      " Restart LSP
<Leader>Ll      " List active LSP servers
<Leader>Lm      " Open Mason
```

## Mason Package Management

### Enhanced Mason Operations
```vim
<Leader>MA      " Install academic LSP servers
<Leader>MR      " Install all recommended servers
<Leader>MU      " Update all packages
<Leader>MS      " Show Mason status
<Leader>Mm      " Open Mason interface
<Leader>Mi      " Install package
<Leader>Mu      " Uninstall package
<Leader>Ml      " View Mason log
<Leader>Mh      " Mason help
```

## Document Processing

### LaTeX/VimTeX
```vim
\LocalLeader\lv  " View PDF (forward search)
\LocalLeader\li  " Inverse search
\LocalLeader\ll  " Compile LaTeX
\LocalLeader\lc  " Clean auxiliary files
\LocalLeader\ls  " Stop compilation
```

### Typst
```vim
\LocalLeader\tp " Toggle Typst preview
\LocalLeader\ts " Sync cursor in preview
\LocalLeader\tc " Compile PDF
\LocalLeader\tw " Watch file
```

### Markdown/Quarto
```vim
<Leader>Kp      " Start markdown preview
<Leader>Ks      " Stop markdown preview
<Leader>Kt      " Toggle markdown preview

<Leader>Qp      " Quarto preview
<Leader>Qc      " Close Quarto preview
<Leader>Qr      " Quarto render
```

### Molten (Jupyter)
```vim
<Leader>Qmi     " Show image popup
<Leader>Qml     " Evaluate line
<Leader>Qme     " Evaluate operator
<Leader>Qmn     " Initialize kernel
<Leader>Qmk     " Stop kernel
<Leader>Qmr     " Restart kernel
<Leader>Qmv     " Evaluate visual selection
<Leader>Qmf     " Re-evaluate cell
<Leader>Qmh     " Hide output
<Leader>Qms     " Show output
<Leader>Qmd     " Delete cell
<Leader>Qmb     " Open in browser
```

## Academic Workflow

### Julia Development
```vim
<Leader>Jrh     " Horizontal Julia REPL
<Leader>Jrv     " Vertical Julia REPL
<Leader>Jrf     " Floating Julia REPL
<Leader>Jp      " Project status
<Leader>Ji      " Instantiate project
<Leader>Ju      " Update project
<Leader>Jt      " Run tests
<Leader>Jd      " Generate documentation
```

### Obsidian Integration
```vim
<Leader>On      " New Obsidian note
<Leader>Ol      " Insert Obsidian link
<Leader>Of      " Follow Obsidian link
<Leader>Oc      " Toggle Obsidian checkbox
<Leader>Ob      " Show Obsidian backlinks
<Leader>Og      " Show Obsidian outgoing links
<Leader>Oo      " Find files in Obsidian vault
<Leader>Ot      " Insert Obsidian template
<Leader>ON      " New note from template
<Leader>Op      " Paste image into note
<Leader>Ox      " Toggle checkbox (quick access)
```

## Terminal Integration

### Terminal Management
```vim
<C-t>           " Toggle terminal
<Leader>Tt      " Toggle terminal (vertical default)
<Leader>Th      " Horizontal terminal (15 lines)
<Leader>Tv      " Vertical terminal (30%)
<Leader>Tf      " Floating terminal
<Leader>Tk      " Clear terminal
<Leader>Td      " Kill terminal

<A-1>           " Horizontal terminal (15 lines)
<A-2>           " Vertical terminal (30%)
<A-3>           " Floating terminal
```

### Terminal Code Execution
```vim
<C-i>           " Send current line to terminal
<C-c>           " Send current code block to terminal
<C-s>           " Send visual selection to terminal
```

## Git Operations

```vim
<Leader>Gs      " Git status
<Leader>Gp      " Git pull
<Leader>Gg      " LazyGit interface
```

## Search Operations

```vim
<Leader>Sf      " Find files
<Leader>Sg      " Live grep
<Leader>Sb      " Git branches
<Leader>Sc      " Color schemes
<Leader>Sh      " Help tags
<Leader>Sr      " Recent files
<Leader>Sk      " Keymaps
<Leader>SC      " Commands
<Leader>Sl      " Resume last search
```

## Configuration Management

```vim
<Leader>Cs      " Reload configuration
<Leader>Cf      " Find config files
<Leader>Cg      " Grep in config files
```

## Theme & Appearance

### Theme Management
```vim
<Leader>Yc      " Cycle through themes
<Leader>Yw      " Toggle word wrap
<Leader>Yn      " Toggle line numbers
<Leader>Ys      " Toggle spell check
<Leader>Yse     " Set spell language to English (British)
<Leader>Ysf     " Set spell language to French
```

## Window Management

### Split Operations
```vim
<Leader>|v      " Vertical split
<Leader>|h      " Horizontal split
```

## Diagnostics

```vim
<Leader>Xw      " Workspace diagnostics
<Leader>Xd      " Document diagnostics
<Leader>Xl      " Location list
<Leader>Xq      " Quickfix
<Leader>Xx      " Toggle Trouble
```

## Plugin Management

```vim
<Leader>Pi      " Install plugins
<Leader>Pu      " Update plugins
<Leader>Pc      " Compile plugins
<Leader>Ps      " Sync plugins (install + update + compile)
```

## Editor Basics

```vim
<Leader>w       " Write file
<C-s>           " Quick save
<Leader>q       " Close buffer
<Esc>           " Clear search highlights
<Leader>h       " Clear search highlights (alternative)

" Better indenting (visual mode)
<               " Indent left
>               " Indent right

" Move text (visual mode)
J               " Move selection down
K               " Move selection up

" Better paste (visual mode)
p               " Paste without yanking
```

## Search & Replace

```vim
" Clear search highlights
<Esc>           " Clear highlights
<Leader>h       " Clear highlights (alternative)

" Incremental search
/               " Forward search
?               " Backward search
*               " Search word under cursor
#               " Search word under cursor (backward)
n               " Next match
N               " Previous match
```

## Quick Access

```vim
<Leader>x       " Toggle checkbox (Obsidian quick access)
<Leader>q       " Close buffer (quick access)
```

## Special Characters

### Which-Key Triggers
- `<Space>` - Show all leader key groups
- `<LocalLeader>` - Show local leader commands
- `<C-` - Control key combinations
- `<A-` - Alt key combinations
- `<S-` - Shift key combinations

## Customization

### Adding Keymaps
Create `~/.config/nvim/lua/user.lua`:

```lua
-- Add your custom keymaps
vim.keymap.set("n", "<leader>mykey", ":MyCommand<CR>", {
    desc = "My custom command"
})
```

### Remapping Existing Keys
```lua
-- Remap existing keymap
vim.keymap.set("n", "<leader>f", ":MyCustomFinder<CR>", {
    desc = "Custom file finder"
})
```

## Keymap Discovery

### Which-Key Integration
- Press `<Space>` and wait to see all available commands
- Type part of a command to filter results
- Use `<BS>` to go back in the navigation tree

### Help Commands
```vim
:WhichKey        " Show all keymaps
:WhichKey <key>  " Show keymaps for specific key
:help which-key  " Which-Key documentation
```

## Troubleshooting

### Keymap Conflicts
1. Check for conflicting mappings: `:verbose map <key>`
2. Use `:WhichKey` to visualize conflicts
3. Override in `user.lua` if needed

### Slow Keymaps
1. Check for expensive operations in keymap functions
2. Use `vim.defer_fn()` for heavy operations
3. Consider lazy loading heavy plugins

### Missing Keymaps
1. Ensure plugin is loaded: `:lua require("plugins.plugin-name")`
2. Check plugin configuration
3. Verify keymap registration in plugin files

---

💡 **Tip**: Use Which-Key's discoverability features! Press `<Space>` and explore the command tree to learn available keymaps.
