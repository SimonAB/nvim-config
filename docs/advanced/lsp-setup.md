# LSP Setup Guide

Complete guide to configuring Language Server Protocol support in StellarVIM.

## Overview

StellarVIM uses Mason for automatic LSP server management. The configuration includes optimized settings for academic workflows.

## Automatic Setup

### Quick Install Commands

```vim
:lua require("plugins.mason-enhanced").install_academic_servers()
" or use the keybinding
<Space>MA
```

This installs the core academic servers:
- **Python**: pyright (recommended)
- **LaTeX**: texlab
- **Typst**: tinymist
- **Lua**: lua_ls
- **Bash**: bashls
- **Markdown**: marksman
- **JSON/YAML**: jsonls, yamlls

### Full Install

```vim
:lua require("plugins.mason-enhanced").install_all_recommended()
" or use the keybinding
<Space>MR
```

## Server-Specific Configuration

### Python (pyright)

**Configuration:**
```lua
settings = {
  python = {
    analysis = {
      typeCheckingMode = "basic",
      autoSearchPaths = true,
      useLibraryCodeForTypes = true,
      diagnosticMode = "workspace",
    },
  },
}
```

**Features:**
- Basic type checking
- Auto path discovery
- Library code type hints
- Workspace diagnostics

### LaTeX (texlab)

**Configuration:**
```lua
settings = {
  texlab = {
    auxDirectory = ".",
    bibtexFormatter = "texlab",
    build = {
      executable = "latexmk",
      args = {
        "-pdf", "-pdflatex=lualatex", "-interaction=nonstopmode",
        "-synctex=1", "-file-line-error", "%f"
      },
      onSave = false,
      forwardSearchAfter = false,
    },
    chktex = { onOpenAndSave = false, onEdit = false },
    diagnosticsDelay = 300,
    formatterLineLength = 80,
    latexFormatter = "latexindent",
  },
}
```

**Features:**
- LuaLaTeX compilation
- Bibliography formatting
- Syntax checking (disabled by default)
- Forward search support

### Lua (lua_ls)

**Configuration:**
```lua
settings = {
  Lua = {
    runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
    diagnostics = { globals = { "vim" } },
    workspace = {
      library = {
        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
      },
    },
  },
}
```

**Features:**
- Neovim API completion
- LuaJIT runtime support
- Vim global detection

## Manual Server Installation

### Using Mason Interface

```vim
:Mason                    " Open Mason interface
:MasonInstall <server>    " Install specific server
```

### Available Academic Servers

| Language | Server | Description |
|----------|--------|-------------|
| Python | pyright | Microsoft's Python LSP |
| Python | pylsp | Python LSP Server |
| LaTeX | texlab | LaTeX LSP |
| Typst | tinymist | Typst LSP |
| Julia | julials | Julia LSP |
| R | r_language_server | R LSP |
| Lua | lua_ls | Lua LSP |
| Bash | bashls | Bash LSP |
| Markdown | marksman | Markdown LSP |
| JSON | jsonls | JSON LSP |
| YAML | yamlls | YAML LSP |
| HTML | html | HTML LSP |
| CSS | cssls | CSS LSP |

## LSP Keybindings

### Navigation
```vim
gd          " Go to definition
gD          " Go to declaration
gi          " Go to implementation
gr          " Show references
```

### Actions
```vim
<Space>Lf   " Format document
<Space>Lr   " Show references
<Space>Lca  " Code actions
<Space>Lrn  " Rename symbol
```

### Information
```vim
K           " Show hover information
<Space>Ls   " Show signature help
<Space>Ld   " Show diagnostics
```

## Troubleshooting

### Server Not Starting

1. **Check Mason Status:**
   ```vim
   :Mason
   :lua require("plugins.mason-enhanced").check_status()
   ```

2. **Restart LSP:**
   ```vim
   :LspRestart
   ```

3. **Check Logs:**
   ```vim
   :LspLog
   ```

### Performance Issues

1. **Disable Heavy Features:**
   ```lua
   -- In server config
   settings = {
     -- Disable expensive features
     diagnosticsDelay = 1000,  -- Increase delay
   }
   ```

2. **Limit File Types:**
   ```lua
   -- Only enable for specific filetypes
   filetypes = { "python", "lua" }
   ```

### Manual Configuration

Create `~/.config/nvim/lua/user-lsp.lua`:

```lua
-- Custom LSP server setup
local lspconfig = require("lspconfig")

lspconfig.myserver.setup({
  cmd = { "my-server", "--stdio" },
  filetypes = { "myfiletype" },
  settings = {
    -- Server-specific settings
  },
})
```

## Advanced Features

### Multi-Server Support

Configure multiple servers for the same language:

```lua
-- In mason-lspconfig handlers
["python"] = function()
  lspconfig.pyright.setup({
    -- Primary server config
  })
end

lspconfig.pylsp.setup({
  -- Secondary server config
})
```

### Custom Root Detection

```lua
root_dir = function(fname)
  return lspconfig.util.root_pattern(".git", "pyproject.toml")(fname) or
         lspconfig.util.path.dirname(fname)
end
```

### Conditional Loading

```lua
-- Only load in specific directories
lspconfig.pyright.setup({
  root_dir = function(fname)
    return vim.fn.getcwd():match("myproject") and
           lspconfig.util.find_git_ancestor(fname)
  end,
})
```

## Performance Tips

1. **Use Appropriate Servers**: Choose lightweight servers for large projects
2. **Configure Debouncing**: Increase diagnostic delays for slow systems
3. **Limit File Types**: Only enable LSP for relevant file types
4. **Use Workspace Mode**: Prefer workspace diagnostics over file diagnostics

## Integration with Other Tools

### With Treesitter
LSP works seamlessly with Treesitter for enhanced syntax highlighting and navigation.

### With Completion
Blink.cmp provides intelligent completion using LSP capabilities.

### With Diagnostics
Trouble.nvim provides enhanced diagnostic display and navigation.
