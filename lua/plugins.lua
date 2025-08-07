-- Plugin Management with vim.pack (Neovim 0.12+)
-- Comprehensive plugin configuration migrated from nvim-cmp to blink.cmp
-- Includes core functionality, UI themes, navigation, and Julia LSP support

-- Comprehensive plugin list with blink.cmp for completion
local plugins = {
  -- Core functionality - Essential development tools
  { url = 'https://github.com/folke/trouble.nvim', name = 'trouble.nvim' },         -- Diagnostics viewer
  { url = 'https://github.com/Saghen/blink.cmp', name = 'blink.cmp', build = 'cargo build --release' }, -- Modern completion engine

  -- UI and themes - Visual enhancements and colourschemes
  { url = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },            -- Modern pastel theme
  { url = 'https://github.com/navarasu/onedark.nvim', name = 'onedark.nvim' },    -- OneDark theme
  { url = 'https://github.com/folke/tokyonight.nvim', name = 'tokyonight.nvim' }, -- Tokyo Night theme
  { url = 'https://github.com/arcticicestudio/nord-vim', name = 'nord-vim' },     -- Nord theme
  { url = 'https://github.com/rafi/awesome-vim-colorschemes', name = 'awesome-vim-colorschemes' }, -- Collection of themes
  { url = 'https://github.com/projekt0n/github-nvim-theme', name = 'github-nvim-theme' }, -- GitHub theme
  { url = 'https://github.com/f-person/auto-dark-mode.nvim', name = 'auto-dark-mode.nvim' }, -- Auto theme switching
  { url = 'https://github.com/lewis6991/gitsigns.nvim', name = 'gitsigns.nvim' }, -- Git integration
  { url = 'https://github.com/nvim-lualine/lualine.nvim', name = 'lualine.nvim' }, -- Status line
  { url = 'https://github.com/akinsho/bufferline.nvim', name = 'bufferline.nvim' }, -- Buffer tabs
  { url = 'https://github.com/echasnovski/mini.icons', name = 'mini.icons' },      -- Modern icon support

  -- Navigation - File and project navigation tools
  { url = 'https://github.com/nvim-telescope/telescope.nvim', name = 'telescope.nvim' }, -- Fuzzy finder
  { url = 'https://github.com/nvim-lua/plenary.nvim', name = 'plenary.nvim' },    -- Utility library (required by telescope)
  { url = 'https://github.com/justinmk/vim-sneak', name = 'vim-sneak' },          -- Enhanced motion
  { url = 'https://github.com/nvim-tree/nvim-tree.lua', name = 'nvim-tree.lua' }, -- File explorer
  { url = 'https://github.com/nvim-tree/nvim-web-devicons', name = 'nvim-web-devicons' }, -- File icons
  { url = 'https://github.com/folke/which-key.nvim', name = 'which-key.nvim' },   -- Keymap popup helper

  -- Terminal integration - Enhanced terminal workflow
  { url = 'https://github.com/akinsho/toggleterm.nvim', name = 'toggleterm.nvim' }, -- Terminal management

  -- Document processing - LaTeX, Typst and Markdown support
  { url = 'https://github.com/lervag/vimtex', name = 'vimtex' },                 -- LaTeX support
  { url = 'https://github.com/iamcco/markdown-preview.nvim', name = 'markdown-preview.nvim' }, -- Markdown preview
  { url = 'https://github.com/chomosuke/typst-preview.nvim', name = 'typst-preview.nvim' }, -- Typst preview
  { url = 'https://github.com/quarto-dev/quarto-nvim', name = 'quarto-nvim' },   -- Quarto support
  { url = 'https://github.com/jmbuhr/otter.nvim', name = 'otter.nvim' },         -- Code execution in Quarto
  { url = 'https://github.com/benlubas/molten-nvim', name = 'molten-nvim' },     -- Jupyter notebook integration

  -- Language support - Syntax highlighting and LSP
  { url = 'https://github.com/nvim-treesitter/nvim-treesitter', name = 'nvim-treesitter' }, -- Syntax highlighting
  { url = 'https://github.com/neovim/nvim-lspconfig', name = 'nvim-lspconfig' },  -- LSP configurations

  -- Text manipulation
  { url = 'https://github.com/kylechui/nvim-surround', name = 'nvim-surround' }, -- vim surround in Lua
}

-- Plugin installation
local pack_path = vim.fn.stdpath('data') .. '/pack/plugins'
local start_path = pack_path .. '/start'
vim.fn.mkdir(start_path, 'p')

for _, plugin in ipairs(plugins) do
  local plugin_path = start_path .. '/' .. plugin.name
  if vim.fn.isdirectory(plugin_path) == 0 then
    print('Installing ' .. plugin.name .. '...')
    vim.fn.system({'git', 'clone', '--depth=1', plugin.url, plugin_path})
    if vim.v.shell_error == 0 then
      print('✓ ' .. plugin.name .. ' installed')

      -- Execute build command if specified
      if plugin.build then
        print('Building ' .. plugin.name .. '...')
        local build_result = vim.fn.system('cd ' .. vim.fn.shellescape(plugin_path) .. ' && ' .. plugin.build)
        if vim.v.shell_error == 0 then
          print('✓ ' .. plugin.name .. ' built successfully')
        else
          print('✗ Failed to build ' .. plugin.name .. ': ' .. build_result)
        end
      end
    else
      print('✗ Failed to install ' .. plugin.name)
    end
  end
end

-- Load plugins
vim.cmd('packloadall!')
vim.cmd('silent! helptags ALL')

-- Add plugins to runtime path
local plugin_dirs = vim.fn.glob(start_path .. '/*', false, true)
for _, dir in ipairs(plugin_dirs) do
  if vim.fn.isdirectory(dir) == 1 then
    vim.opt.rtp:append(dir)
  end
end

vim.cmd('runtime! plugin/**/*.vim')
vim.cmd('runtime! plugin/**/*.lua')

-- Safe setup helper
local function safe_setup(plugin_name, setup_func)
  local ok, plugin = pcall(require, plugin_name)
  if ok and setup_func then
    local setup_ok, err = pcall(setup_func, plugin)
    if not setup_ok then
      vim.notify('Error configuring ' .. plugin_name .. ': ' .. tostring(err), vim.log.levels.WARN)
    end
    return true
  elseif not ok then
    vim.notify('Plugin not found: ' .. plugin_name, vim.log.levels.DEBUG)
    return false
  end
  return ok
end

-- Plugin configuration
vim.defer_fn(function()
  -- Essential completion settings for Neovim 0.12+
  -- Configure completion behaviour: show menu, select first item, don't auto-insert
  vim.opt.completeopt = { 'menu', 'menuone', 'noinsert' }

  -- Begin silent plugin configuration (reduces startup noise)

  -- LSP Configuration
  local lsp_ok, lspconfig = pcall(require, 'lspconfig')
  if not lsp_ok then
    print('❌ lspconfig not available')
    return
  end

  -- Enhanced LSP capabilities for completion
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local blink_ok, blink_lsp = pcall(require, 'blink.cmp.lsp')
  if blink_ok then
    capabilities = blink_lsp.default_capabilities(capabilities)
    -- Blink.cmp handles snippetSupport automatically
    capabilities.textDocument.completion.completionItem.resolveSupport = {
      properties = { 'documentation', 'detail', 'additionalTextEdits' }
    }
    -- LSP capabilities enhanced
  end

  -- Julia LSP setup with enhanced configuration (Stage 3)
  if vim.fn.executable('julia') == 1 then
    lspconfig.julials.setup({
      capabilities = capabilities,
      single_file_support = true,
      timeout_ms = 30000,          -- Stage 2: 30 second timeout for slow operations
      flags = {
        debounce_text_changes = 150,  -- Stage 3: Reduce LSP noise
        allow_incremental_sync = true, -- Stage 3: Better performance
      },
      settings = {
        julia = {
          symbolCacheDownload = false,  -- Keep disabled - this was the main issue
          lint = {
            run = true,
            missingrefs = "all",     -- Enhanced: Show missing reference warnings
            call = true,
            iter = true,             -- Enhanced: Iterator linting
            nothingcomp = true,      -- Enhanced: Check nothing comparisons
            constif = true,          -- Enhanced: Constant if condition warnings
            lazy = true,             -- Enhanced: Lazy evaluation warnings
            datadecl = true,         -- Enhanced: Data declaration warnings
            typeparam = true,        -- Enhanced: Type parameter warnings
            modname = true,          -- Enhanced: Module name warnings
          },
          completionmode = "qualify",  -- Enhanced: Better completion with qualification
          -- Formatting disabled temporarily due to parsing issues
          -- format = {
          --   indent = 4,              -- Stage 2: Consistent indentation
          --   calls = true,            -- Stage 2: Format function calls
          -- },
          -- Stage 3: Advanced workspace features
          useRevise = true,         -- Stage 3: Enable Revise.jl integration
          execution = {
            resultDisplay = "both",   -- Stage 3: Show results in both REPL and inline
            errorDisplay = "both",   -- Stage 3: Show errors in both places
          },
        },
      },
      init_options = {
        storagePath = vim.fn.stdpath('cache') .. '/julia_ls',  -- Stage 2: Cache path
        experimentalFeatures = {     -- Stage 3: Enable experimental features
          lspMacroExpansion = true,
          inlayHints = true,
        },
      },
      on_attach = function(client, bufnr)
        -- Julia LSP attached silently

        -- Set omnifunc for manual completion
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Useful keymaps
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<localleader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<localleader>ca', vim.lsp.buf.code_action, opts)

        -- Manual completion trigger
        vim.keymap.set('i', '<C-Space>', function()
          require('blink.cmp').show()
        end, { buffer = bufnr })
      end,
      on_init = function(client, initialize_result)
        -- Julia LSP initialized
      end,
      root_dir = function(fname)
        -- Stage 2: Intelligent root directory detection
        return require('lspconfig').util.root_pattern(
          'Project.toml',           -- Julia project file
          'JuliaProject.toml',      -- Alternative Julia project file
          'Manifest.toml',          -- Julia manifest file
          '.git',                   -- Git repository
          'pyproject.toml',         -- Python project (for mixed projects)
          'Cargo.toml'              -- Rust project (for mixed projects)
        )(fname) or vim.fn.getcwd()
      end,
    })
    -- Julia LSP configured
  else
    -- Julia not available
  end

  -- Python LSP setup for multi-language Quarto support
  if vim.fn.executable('pyright') == 1 then
    lspconfig.pyright.setup({
      capabilities = capabilities,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
      on_attach = function(client, bufnr)
        -- Python LSP attached for Quarto
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<localleader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<localleader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('i', '<C-Space>', function()
          require('blink.cmp').show()
        end, { buffer = bufnr })
      end,
    })
  elseif vim.fn.executable('pylsp') == 1 then
    -- Fallback to pylsp if pyright not available
    lspconfig.pylsp.setup({
      capabilities = capabilities,
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = { enabled = false },
            mccabe = { enabled = false },
            pyflakes = { enabled = false },
            flake8 = { enabled = false },
          },
        },
      },
      on_attach = function(client, bufnr)
        -- Python LSP (pylsp) attached for Quarto
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<localleader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<localleader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('i', '<C-Space>', function()
          require('blink.cmp').show()
        end, { buffer = bufnr })
      end,
    })
  end

  -- R LSP setup for multi-language Quarto support
  if vim.fn.executable('R') == 1 then
    lspconfig.r_language_server.setup({
      capabilities = capabilities,
      settings = {
        r = {
          lsp = {
            rich_documentation = false,
          },
        },
      },
      on_attach = function(client, bufnr)
        -- R LSP attached for Quarto
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<localleader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<localleader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('i', '<C-Space>', function()
          require('blink.cmp').show()
        end, { buffer = bufnr })
      end,
    })
  end

  -- Texlab LSP setup for LaTeX with blink.cmp integration
  if vim.fn.executable('texlab') == 1 then
    lspconfig.texlab.setup({
      capabilities = capabilities,
      settings = {
        texlab = {
          auxDirectory = ".",
          bibtexFormatter = "texlab",
          build = {
            executable = "latexmk",
            args = { "-pdf", "-pdflatex=lualatex", "-interaction=nonstopmode", "-synctex=1", "-file-line-error", "%f" },
            onSave = false,
            forwardSearchAfter = false,
          },
          chktex = {
            onOpenAndSave = false,
            onEdit = false,
          },
          diagnosticsDelay = 300,
          formatterLineLength = 80,
          forwardSearch = {
            executable = nil, -- VimTeX handles this
            args = {},
          },
          latexFormatter = "latexindent",
          latexindent = {
            ["local"] = nil,
            modifyLineBreaks = false,
          },
        },
      },
      on_attach = function(client, bufnr)
        -- Texlab LSP attached

        -- Set omnifunc for manual completion
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Useful keymaps for LaTeX
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<localleader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<localleader>ca', vim.lsp.buf.code_action, opts)

        -- Manual completion trigger
        vim.keymap.set('i', '<C-Space>', function()
          require('blink.cmp').show()
        end, { buffer = bufnr })
      end,
    })
    -- Texlab LSP configured
  else
    -- Texlab not available
  end

  -- Blink.cmp completion setup with simplified config
  local blink_ok2, blink = pcall(require, 'blink.cmp')
  if blink_ok2 then
    blink.setup({
      -- Keymap configuration
      keymap = {
        preset = 'default',
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
      },

      -- Appearance configuration
      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = 'mono'
      },

      -- Sources configuration
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },

      -- Completion configuration
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          enabled = true,
          auto_show = true,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = {
          enabled = true,
        },
      },

      -- Signature help
      signature = {
        enabled = true,
      },

      -- Fuzzy matching - minimal valid configuration
      fuzzy = {
        prebuilt_binaries = {
          download = true,
          force_version = nil,
        },
      },
    })

    -- Blink.cmp configured
  else
    -- blink.cmp not available
  end

  -- Treesitter for syntax highlighting
  local treesitter_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
  if treesitter_ok then
    treesitter.setup({
      ensure_installed = { 'lua', 'julia', 'python', 'markdown' },
      highlight = { enable = true },
      indent = { enable = true },
    })
    -- Treesitter configured
  end

  -- Git signs
  safe_setup('gitsigns', function(gitsigns)
    gitsigns.setup({
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    })
  end)

  -- Telescope
  safe_setup('telescope', function(telescope)
    telescope.setup({
      defaults = {
        file_ignore_patterns = { 'node_modules', '.git' },
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
          },
        },
      },
    })
  end)

  -- Lualine
  safe_setup('lualine', function(lualine)
    lualine.setup({
      options = {
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
    })
  end)

  -- BufferLine
  safe_setup('bufferline', function(bufferline)
    bufferline.setup({
      options = {
        diagnostics = 'nvim_lsp',
        separator_style = 'slant',
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = true,
        show_tab_indicators = true,
      },
    })
  end)

  -- ToggleTerm
  safe_setup('toggleterm', function(toggleterm)
    toggleterm.setup({
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      direction = 'vertical',
      float_opts = {
        border = 'curved',
      },
    })
  end)

  -- NvimTree file explorer
  safe_setup('nvim-tree', function(nvim_tree)
    nvim_tree.setup({
      view = {
        side = 'left',
        width = 30,
      },
      renderer = {
        icons = {
          show = {
            git = true,
            folder = true,
            file = true,
          },
        },
      },
      filters = {
        dotfiles = false,
      },
    })
  end)

  -- Trouble
  safe_setup('trouble', function(trouble)
    trouble.setup({
      -- Default configuration
    })
  end)

  -- Mini.icons setup for modern icon support
  safe_setup('mini.icons', function(mini_icons)
    mini_icons.setup()
  end)

  -- Nvim-surround setup for text manipulation
  safe_setup('nvim-surround', function(nvim_surround)
    nvim_surround.setup()
  end)

  -- Quarto setup for document authoring
  safe_setup('quarto', function(quarto)
    quarto.setup({
      debug = false,
      closePreviewOnExit = true,
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "r", "python", "julia", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten", -- "molten", "slime", "iron" or <function>
        ft_runners = {}, -- filetype to runner, ie. `{ python = "molten" }`
        never_run = { "yaml" }, -- filetypes which are never sent to a code runner
      },
    })
  end)

  -- Otter setup for multi-language LSP in Quarto documents
  safe_setup('otter', function(otter)
    -- Check if otter is already configured to avoid duplicate setup messages
    if not otter._setup_done then
      otter.setup({
        lsp = {
          hover = {
            border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
          },
          -- Enable diagnostic integration with blink.cmp
          diagnostic_update_events = { "BufWritePost" },
        },
        buffers = {
          set_filetype = true,
          write_to_disk = false,
        },
        strip_wrapping_quote_characters = { '"', "'", "`" },
        handle_leading_whitespace = true,
        -- Verbose for debugging multi-language setup
        verbose = {
          no_code_found = false,
        },
      })
      otter._setup_done = true
    end
  end)

  -- Which Key (keymap popup) - using modern v3 wk.add() API
  safe_setup('which-key', function(wk)
    wk.setup({
      delay = 500,
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true
        }
      },
      win = {
        border = "rounded",
        padding = { 1, 2 },
        wo = {
          winblend = 0,
        },
      },
      layout = {
        height = { min = 4, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 3,
        align = "center",
      },
    })

    -- Centralised function to open Julia REPL with specified direction
    local function open_julia_repl(direction)
      local Terminal = require('toggleterm.terminal').Terminal
      local project_path = vim.fn.shellescape(vim.fn.getcwd())
      local julia_repl = Terminal:new({
        cmd = "julia --project=" .. project_path,
        hidden = true,
        direction = direction,
        close_on_exit = false,
        on_open = function(_)
          vim.cmd("startinsert!")
        end,
      })
      julia_repl:toggle()
    end

    -- Add keymaps using modern v3 API
    wk.add({
        -- Buffer operations
        { "<leader>B", group = "Buffer" },
        -- Configuration
        { "<leader>C", group = "Configuration" },
        { "<leader>Cs", function()
          -- Comprehensive configuration reload
          local config_path = vim.fn.stdpath('config')

          -- Clear Lua module cache for config files to force reload
          local modules_to_clear = {
            'config',
            'keymaps',
            'plugins'
          }

          for _, module in ipairs(modules_to_clear) do
            package.loaded[module] = nil
          end

          -- Source all configuration files in proper order
          vim.cmd('source ' .. config_path .. '/init.lua')

          -- Show confirmation with file list
          print('✓ Configuration reloaded!')
          print('  • init.lua')
          print('  • lua/config.lua')
          print('  • lua/keymaps.lua')
          print('  • lua/plugins.lua')
        end, desc = "Source config" },
        -- File explorer
        -- Find files
        -- Git operations
        { "<leader>G", group = "Git" },
        -- Git operations
        { "<leader>Gs", function() vim.cmd("!git status") end, desc = "Git Status" },
        { "<leader>Gp", function() vim.cmd("!git pull") end, desc = "Git Pull" },

        -- Toggle options
        { "<leader>Y", group = "Toggle" },
        -- Editor utilities
        { "<leader>Ys", ":set spell!<CR>", desc = "Toggle Spell Check" },

        -- LSP operations
        { "<leader>L", group = "LSP" },
        { "<leader>Ll", function()
          local clients = vim.lsp.get_active_clients()
          if #clients == 0 then
            print("No LSP servers running")
            return
          end
          print("Active LSP servers:")
          for _, client in ipairs(clients) do
            local buffers = vim.lsp.get_buffers_by_client_id(client.id)
            print(string.format("  %s (ID: %d) - %d buffers", client.name, client.id, #buffers))
          end
        end, desc = "List available servers" },
        { "<leader>Lr", function()
          local clients = vim.lsp.get_active_clients({bufnr = 0})
          if #clients == 0 then
            print("No active LSP clients to restart")
          else
            print("Restarting LSP...")
            vim.cmd('LspRestart')
          end
        end, desc = "Restart LSP" },
        { "<leader>Lf", function()
          vim.lsp.buf.format({ async = true })
        end, desc = "Format Document" },
        { "<leader>LR", function()
          vim.lsp.buf.references()
        end, desc = "Show References" },
        -- Plugin management
        { "<leader>P", group = "Plugin" },
        -- Quit
        { "<leader>q", ":q<CR>", desc = "Close buffer" },
        -- Quarto operations
        { "<leader>Q", group = "Quarto" },
        -- Quarto preview operations
        { "<leader>Qp", function()
          pcall(function()
            require('quarto').quartoPreview()
          end)
        end, desc = "Quarto Preview" },
        { "<leader>Qc", function()
          pcall(function()
            require('quarto').quartoClosePreview()
          end)
        end, desc = "Close preview" },
        { "<leader>Qr", function()
          pcall(function()
            vim.cmd('QuartoRender')
          end)
        end, desc = "Quarto Render" },
        -- Molten keymaps under <leader>Qm prefix
        { "<leader>Qm", group = "Molten" },
        { "<leader>Qmi", function()
          vim.cmd('MoltenImagePopup')
        end, desc = "Show Image Popup" },
        { "<leader>Qml", function()
          vim.cmd('MoltenEvaluateLine')
        end, desc = "Evaluate Line" },
        { "<leader>Qme", function()
          vim.cmd('MoltenEvaluateOperator')
        end, desc = "Evaluate Operator" },
        { "<leader>Qmn", function()
          pcall(function()
            vim.cmd('MoltenInit')
          end)
        end, desc = "Initialise Kernel" },
        { "<leader>Qmk", function()
          pcall(function()
            vim.cmd('MoltenDeinit')
          end)
        end, desc = "Stop Kernel" },
        { "<leader>Qmr", function()
          pcall(function()
            vim.cmd('MoltenRestart')
          end)
        end, desc = "Restart Kernel" },
        -- Code evaluation
        { "<leader>Qmo", function()
          pcall(function()
            vim.cmd('MoltenEvaluateOperator')
          end)
        end, desc = "Evaluate Operator" },
        { "<leader>Qm<CR>", function()
          pcall(function()
            vim.cmd('MoltenEvaluateLine')
          end)
        end, desc = "Evaluate Line" },
        { "<leader>Qmv", function()
          pcall(function()
            vim.cmd('MoltenEvaluateVisual')
          end)
        end, desc = "Evaluate Visual" },
        { "<leader>Qmf", function()
          pcall(function()
            vim.cmd('MoltenReevaluateCell')
          end)
        end, desc = "Re-evaluate Cell" },
        -- Output management
        { "<leader>Qmh", function()
          pcall(function()
            vim.cmd('MoltenHideOutput')
          end)
        end, desc = "Hide Output" },
        { "<leader>Qms", function()
          pcall(function()
            vim.cmd('MoltenShowOutput')
          end)
        end, desc = "Show Output" },
        { "<leader>Qmd", function()
          pcall(function()
            vim.cmd('MoltenDelete')
          end)
        end, desc = "Delete Cell" },
        { "<leader>Qmb", function()
          pcall(function()
            vim.cmd('MoltenOpenInBrowser')
          end)
        end, desc = "Open in Browser" },
        -- Otter operations
        { "<leader>O", group = "Otter" },
        -- Quit
        -- Search operations
        { "<leader>S", group = "Search" },
        -- Split operations
        { "<leader>|", group = "Split" },
        { "<leader>|v", "<cmd>vsplit<CR>", desc = "Vertical split" },
        { "<leader>|h", "<cmd>split<CR>", desc = "Horizontal split" },
        -- Terminal operations
        { "<leader>T", group = "Terminal" },
        -- Vertical split
        -- Window operations
        { "<leader>W", group = "Window" },
        -- Trouble diagnostics
        { "<leader>X", group = "Trouble" },
        { "<leader>Xw", ":TroubleToggle workspace_diagnostics<CR>", desc = "Workspace Diagnostics" },
        { "<leader>Xd", ":TroubleToggle document_diagnostics<CR>", desc = "Document Diagnostics" },
        { "<leader>Xl", ":TroubleToggle loclist<CR>", desc = "Location List" },
        { "<leader>Xq", ":TroubleToggle quickfix<CR>", desc = "Quickfix" },

        -- Julia-specific operations (Stage 3)
        { "<leader>J", group = "Julia" },
        { "<leader>Jr", group = "Julia REPL" },
        { "<leader>Jrh", function() open_julia_repl('horizontal') end, desc = "Horizontal REPL" },
        { "<leader>Jrv", function() open_julia_repl('vertical') end, desc = "Vertical REPL" },
        { "<leader>Jrf", function() open_julia_repl('float') end, desc = "Floating REPL" },
        { "<leader>Jp", function()
          -- Show project status using ToggleTerm
          local Terminal = require('toggleterm.terminal').Terminal
          local project_path = vim.fn.shellescape(vim.fn.getcwd())
          local pkg_status = Terminal:new({
            cmd = "julia --project=" .. project_path .. " -e 'using Pkg; Pkg.status()'",
            hidden = true,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          })
          pkg_status:toggle()
        end, desc = "Project Status" },
        { "<leader>Ji", function()
          -- Instantiate project using ToggleTerm
          local Terminal = require('toggleterm.terminal').Terminal
          local project_path = vim.fn.shellescape(vim.fn.getcwd())
          local pkg_instantiate = Terminal:new({
            cmd = "julia --project=" .. project_path .. " -e 'using Pkg; Pkg.instantiate()'",
            hidden = true,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          })
          pkg_instantiate:toggle()
        end, desc = "Instantiate Project" },
        { "<leader>Ju", function()
          -- Update project using ToggleTerm
          local Terminal = require('toggleterm.terminal').Terminal
          local project_path = vim.fn.shellescape(vim.fn.getcwd())
          local pkg_update = Terminal:new({
            cmd = "julia --project=" .. project_path .. " -e 'using Pkg; Pkg.update()'",
            hidden = true,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          })
          pkg_update:toggle()
        end, desc = "Update Project" },
        { "<leader>Jt", function()
          -- Run tests using ToggleTerm
          local Terminal = require('toggleterm.terminal').Terminal
          local project_path = vim.fn.shellescape(vim.fn.getcwd())
          local pkg_test = Terminal:new({
            cmd = "julia --project=" .. project_path .. " -e 'using Pkg; Pkg.test()'",
            hidden = true,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          })
          pkg_test:toggle()
        end, desc = "Run Tests" },
        { "<leader>Jd", function()
          -- Generate documentation using ToggleTerm
          local Terminal = require('toggleterm.terminal').Terminal
          local project_path = vim.fn.shellescape(vim.fn.getcwd())
          local pkg_docs = Terminal:new({
            cmd = "julia --project=" .. project_path .. " -e 'using Pkg; using Documenter; makedocs()'",
            hidden = true,
            direction = "horizontal",
            close_on_exit = false,
            on_open = function(_)
              vim.cmd("startinsert!")
            end,
          })
          pkg_docs:toggle()
        end, desc = "Generate Docs" },

        -- Test keymap
        { "<leader>t", function()
          print('Test keymap executed - which-key working properly')
        end, desc = "test keymap" },

        -- Help and testing
        { "<leader>?", function()
          local ok, wk = pcall(require, 'which-key')
          if ok then
            print('Which-key is loaded and ready')
            print('Press <space> and wait to see keymap popup')
          else
            print('Which-key not loaded')
          end
        end, desc = "Which-key Status" },
      })
  end)

  -- Auto-trigger completion for Julia files
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'julia',
    callback = function()
      -- Auto-trigger completion on dot
      vim.keymap.set('i', '.', function()
        vim.api.nvim_feedkeys('.', 'n', false)
        vim.defer_fn(function()
          local blink_cmp = require('blink.cmp')
          if not blink_cmp.is_visible() then
            blink_cmp.show()
          end
        end, 100)
      end, { buffer = true })
    end,
  })

  -- Auto-activate Otter for Quarto files to enable multi-language LSP
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'quarto', 'markdown' },
    callback = function()
      local filename = vim.api.nvim_buf_get_name(0)
      -- Only activate for .qmd files
      if filename:match('%.qmd$') then
        vim.defer_fn(function()
          local otter_ok, otter = pcall(require, 'otter')
          if otter_ok then
            -- Activate otter with language detection for Julia, Python, R
            otter.activate({'julia', 'python', 'r'}, true, true)
            print('✓ Otter activated for multi-language Quarto support')
          end
        end, 500)  -- Small delay to ensure file is loaded
      end
    end,
  })

  -- Enhanced completion triggers for multi-language code chunks
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'python', 'r' },
    callback = function()
      -- Auto-trigger completion for Python and R (similar to Julia)
      local triggers = {
        python = { '.', ':' },
        r = { '$', ':', '@' }
      }
      local ft = vim.bo.filetype
      if triggers[ft] then
        for _, trigger in ipairs(triggers[ft]) do
          vim.keymap.set('i', trigger, function()
            vim.api.nvim_feedkeys(trigger, 'n', false)
            vim.defer_fn(function()
              local blink_cmp = require('blink.cmp')
              if not blink_cmp.is_visible() then
                blink_cmp.show()
              end
            end, 100)
          end, { buffer = true })
        end
      end
    end,
  })

  -- Molten configuration (remote plugin - configured via vim vars)
  -- Molten-nvim is a remote plugin that uses Python, configured via vim variables
  vim.g.molten_image_provider = "none"  -- Terminal compatible image display
  vim.g.molten_output_win_max_height = 20  -- Limit output window size
  vim.g.molten_auto_open_output = false    -- Don't auto-open output
  vim.g.molten_wrap_output = true          -- Wrap long lines
  vim.g.molten_virt_text_output = false    -- Use virtual text for output
  vim.g.molten_use_border_highlights = true -- Use border highlights

  -- Configuration complete

end, 1500) -- Increased delay to ensure all plugins load

-- ============================================================================
-- PLUGIN-SPECIFIC KEYMAPS
-- ============================================================================
-- Plugin-specific keymaps extracted from lua/keymaps.lua
-- These mappings invoke or reference specific plugins and are organized here
-- for better maintainability alongside plugin configurations

local map = vim.keymap.set

-- Buffer navigation with BufferLine fallback (from lua/keymaps.lua lines 78-90)
map("n", "<S-l>", function()
    local bufferline_ok = pcall(vim.cmd, "BufferLineCycleNext")
    if not bufferline_ok then
        vim.cmd("bnext")
    end
end, { desc = "Next buffer" })

map("n", "<S-h>", function()
    local bufferline_ok = pcall(vim.cmd, "BufferLineCyclePrev")
    if not bufferline_ok then
        vim.cmd("bprevious")
    end
end, { desc = "Previous buffer" })

-- File finder with Telescope (from lua/keymaps.lua lines 119-123)
map("n", "<leader>f", function()
  pcall(function()
    vim.cmd("Telescope find_files")
  end)
end, { desc = "Find File" })

-- File explorer with NvimTree (from lua/keymaps.lua line 126)
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- Config directory navigation with Telescope (from lua/keymaps.lua lines 169-175)
map('n','<leader>Cd',function()
  require('telescope.builtin').find_files{ cwd = vim.fn.stdpath('config') }
end,{desc='Browse config dir'})

map('n','<leader>Cg',function()
  require('telescope.builtin').live_grep{ cwd = vim.fn.stdpath('config') }
end,{desc='Search config dir'})

-- Config source all - reload all configuration files (comprehensive reload)
map('n', '<leader>Cs', function()
  -- Comprehensive configuration reload
  local config_path = vim.fn.stdpath('config')

  -- Clear Lua module cache for config files to force reload
  local modules_to_clear = {
    'config',
    'keymaps',
    'plugins'
  }

  for _, module in ipairs(modules_to_clear) do
    package.loaded[module] = nil
  end

  -- Source all configuration files in proper order
  vim.cmd('source ' .. config_path .. '/init.lua')

  -- Show confirmation with file list
  print('✓ Configuration reloaded!')
  print('  • init.lua')
  print('  • lua/config.lua')
  print('  • lua/keymaps.lua')
  print('  • lua/plugins.lua')
end, { desc = 'Source all config files' })

-- Terminal integration with ToggleTerm (from lua/keymaps.lua lines 332-413)
map("n", "<C-t>", "<esc><cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<C-i>", "<esc><cmd>ToggleTermSendCurrentLine<CR>j", { desc = "Send current line to terminal" })
map("v", "<C-s>", ":'<,'>ToggleTermSendVisualSelection<CR>", { desc = "Send selected lines to terminal" })
map("t", "<C-t>", "<C-\\><C-N><cmd>ToggleTerm<CR>", { desc = "Toggle terminal from terminal" })

-- Buffer Management with BufferLine (from lua/keymaps.lua lines 456-466)
map("n", "<leader>Bj", function()
  pcall(function()
    vim.cmd("BufferLinePick")
  end)
end, { desc = "Jump to buffer" })

map("n", "<leader>Bf", ":Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<leader>Bb", "<S-h>", { desc = "Previous buffer" })
map("n", "<leader>Bn", "<S-l>", { desc = "Next buffer" })
map("n", "<leader>Bq", ":bdelete<CR>", { desc = "Close buffer" })

-- Search Operations with Telescope (from lua/keymaps.lua lines 468-477)
map("n", "<leader>Sf", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>St", ":Telescope live_grep<CR>", { desc = "Text (Live Grep)" })
map("n", "<leader>Sb", ":Telescope git_branches<CR>", { desc = "Git branches" })
map("n", "<leader>Sc", ":Telescope colorscheme<CR>", { desc = "Colourscheme" })
map("n", "<leader>Sh", ":Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>Sr", ":Telescope oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>Sk", ":Telescope keymaps<CR>", { desc = "Keymaps" })
map("n", "<leader>SC", ":Telescope commands<CR>", { desc = "Commands" })
map("n", "<leader>Sl", ":Telescope resume<CR>", { desc = "Resume last search" })

-- Trouble diagnostics (from lua/keymaps.lua lines 481-485)
map("n", "<leader>Xx", function()
    pcall(function()
        vim.cmd("TroubleToggle")
    end)
end, { desc = "Toggle Trouble" })

-- Obsidian plugin (from lua/keymaps.lua lines 488-492)
map("n", "<leader>x", function()
    pcall(function()
        require("obsidian").util.toggle_checkbox()
    end)
end, { desc = "Toggle checkbox", buffer = true })

-- LSP Operations with Telescope integration (from lua/keymaps.lua lines 499-510)
map("n", "<leader>Ld", ":Telescope diagnostics bufnr=0<CR>", { desc = "Buffer Diagnostics" })
map("n", "<leader>Lw", ":Telescope diagnostics<CR>", { desc = "Workspace Diagnostics" })
map("n", "<leader>Ls", ":Telescope lsp_document_symbols<CR>", { desc = "Document Symbols" })
map("n", "<leader>LS", ":Telescope lsp_dynamic_workspace_symbols<CR>", { desc = "Workspace Symbols" })

-- LazyGit integration with ToggleTerm (from lua/keymaps.lua lines 694-713)
map("n", "<leader>Gg", function()
  local Terminal = require('toggleterm.terminal').Terminal
  local lazygit = Terminal:new({
    cmd = "lazygit",
    hidden = true,
    direction = "float",
    float_opts = {
      border = "none",
      width = 100000,
      height = 100000,
      zindex = 200,
    },
    on_open = function(_)
      vim.cmd("startinsert!")
    end,
    on_close = function(_) end,
    count = 99,
  })
  lazygit:toggle()
end, { desc = "Lazygit" })

-- Which-key status check (from lua/keymaps.lua lines 596-604)
map('n', '<leader>?', function()
  local ok, wk = pcall(require, 'which-key')
  if ok then
    print('Which-key is loaded and ready')
    print('Press <space> and wait 1 second to see keymap popup')
  else
    print('Which-key not loaded')
  end
end, { desc = 'Which-key status' })

-- Which-key test functionality (moved from <leader>t to avoid collision with Terminal group)
map('n', '<leader>T', function()
  print('Test keymap executed - which-key should show this description')
end, { desc = 'Test which-key functionality' })

-- Legacy Quarto keymaps removed - now using Q prefix

-- Otter keymaps for code execution
map('n', '<leader>Oa', function()
  pcall(function()
    require('otter').activate()
  end)
end, { desc = 'Otter Activate' })

map('n', '<leader>Od', function()
  pcall(function()
    require('otter').deactivate()
  end)
end, { desc = 'Otter Deactivate' })

-- ============================================================================
-- PLUGIN MANAGEMENT (vim.pack)
-- ============================================================================
-- Native Neovim 0.12+ plugin management using built-in vim.pack system
-- Provides install, update, compile, and sync operations for plugins
-- Extracted from lua/keymaps.lua lines 610-683
-- Plugin management commands for vim.pack
map('n', '<leader>Pi', function()
  vim.cmd('luafile ' .. vim.fn.stdpath('config') .. '/lua/plugins.lua')
  print('Plugins installed/updated')
end, { desc = 'Install plugins' })

map('n', '<leader>Pu', function()
  local pack_path = vim.fn.stdpath('data') .. '/pack/plugins/start'
  local plugin_dirs = vim.fn.glob(pack_path .. '/*', false, true)

  print('Updating plugins...')
  local updated_count = 0

  for _, dir in ipairs(plugin_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local plugin_name = vim.fn.fnamemodify(dir, ':t')
      if vim.fn.isdirectory(dir .. '/.git') == 1 then
        local result = vim.fn.system({'git', '-C', dir, 'pull', '--ff-only'})
        if vim.v.shell_error == 0 then
          print('Updated: ' .. plugin_name)
          updated_count = updated_count + 1

          -- Check if this plugin has a build command in our plugin list
          for _, plugin in ipairs(plugins) do
            if plugin.name == plugin_name and plugin.build then
              print('Building ' .. plugin_name .. '...')
              local build_result = vim.fn.system('cd ' .. vim.fn.shellescape(dir) .. ' && ' .. plugin.build)
              if vim.v.shell_error == 0 then
                print('✓ ' .. plugin_name .. ' built successfully')
              else
                print('✗ Failed to build ' .. plugin_name .. ': ' .. build_result)
              end
              break
            end
          end
        else
          print('Failed to update: ' .. plugin_name)
        end
      end
    end
  end

  if updated_count > 0 then
    vim.cmd('packloadall!')
    vim.cmd('silent! helptags ALL')
    print('Updated ' .. updated_count .. ' plugins. Restart Neovim to ensure all changes take effect.')
  else
    print('No plugins updated')
  end
end, { desc = 'Update plugins' })

map('n', '<leader>Pc', function()
  vim.cmd('packloadall!')
  vim.cmd('silent! helptags ALL')
  print('Plugins compiled and helptags generated')
end, { desc = 'Compile plugins' })

map('n', '<leader>Ps', function()
  -- Sync = install missing + update existing + compile
  vim.cmd('luafile ' .. vim.fn.stdpath('config') .. '/lua/plugins.lua')

  local pack_path = vim.fn.stdpath('data') .. '/pack/plugins/start'
  local plugin_dirs = vim.fn.glob(pack_path .. '/*', false, true)

  print('Syncing plugins...')
  local updated_count = 0

  for _, dir in ipairs(plugin_dirs) do
    if vim.fn.isdirectory(dir) == 1 then
      local plugin_name = vim.fn.fnamemodify(dir, ':t')
      if vim.fn.isdirectory(dir .. '/.git') == 1 then
        local result = vim.fn.system({'git', '-C', dir, 'pull', '--ff-only'})
        if vim.v.shell_error == 0 then
          updated_count = updated_count + 1
        end
      end
    end
  end

  print('Plugin sync complete. Updated ' .. updated_count .. ' plugins.')
end, { desc = 'Sync plugins' })

return {}
