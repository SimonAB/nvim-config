-- Core Neovim Configuration
-- Essential editor settings harmonised from LunarVim

local opt = vim.opt

-- ============================================================================
-- CORE EDITOR SETTINGS
-- ============================================================================

-- ============================================================================
-- CORE SETTINGS
-- ============================================================================

-- Line numbers
opt.number = true
opt.relativenumber = true      -- Show relative line numbers (from LunarVim)
opt.signcolumn = "yes"

-- Indentation (from LunarVim)
opt.tabstop = 4               -- Configure tabs
opt.shiftwidth = 4            -- Set indentation width
opt.expandtab = true
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Visual (from LunarVim)
opt.cursorline = true
opt.wrap = true               -- Enable line wrapping
opt.linebreak = true          -- Wrap at word boundaries
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.conceallevel = 2          -- Enable concealment for Obsidian.nvim and VimTex

-- Behavior
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.splitbelow = true
opt.splitright = true
opt.hidden = true

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true

-- Security
opt.modeline = false
opt.exrc = false

-- Language and spell checking (from LunarVim)
opt.spelllang = "en_gb"       -- Set British English spelling
opt.spell = false             -- Disable spell checking by default

-- Terminal colours (enables true colour support)
opt.termguicolors = true

-- Font configuration
opt.guifont = "LigaSFMonoNerdFont-Regular:h10"

-- ============================================================================
-- GLOBAL VARIABLES
-- ============================================================================

-- Configuration file paths for hot-reloading
local config_dir = vim.fn.stdpath('config')
local config_files = {
  init = config_dir..'/init.lua',
  plugins = config_dir..'/lua/plugins.lua',
  keymaps = config_dir..'/lua/keymaps.lua',
  custom = config_dir..'/lua/config.lua',
}

-- Expose config files globally for keymaps module
_G.nvim_config_files = config_files

-- Enable filetype detection
vim.cmd("filetype plugin indent on")

-- Theme customisation
vim.g.sonokai_enable_italic_comment = 1

-- VimTeX configuration (Skim integration)

-- VimTeX configuration with Skim reverse sync support (per official VimTeX docs)
vim.g.vimtex_enabled = 1                -- Explicitly enable VimTeX
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_activate = 0     -- Do not steal focus on view
vim.g.vimtex_view_skim_reading_bar = 1  -- Highlight current location
vim.g.vimtex_view_skim_sync = 1         -- Forward sync after compilation

-- Start a Neovim RPC server for robust inverse search (used by Skim)
do
  local server_address = "/tmp/nvim_server"
  vim.env.NVIM_LISTEN_ADDRESS = server_address
  -- Try to start; if socket exists and is stale, delete and retry
  local ok = pcall(vim.fn.serverstart, server_address)
  if not ok and vim.fn.filereadable(server_address) == 1 then
    pcall(vim.fn.delete, server_address)
    pcall(vim.fn.serverstart, server_address)
  end
end

-- Ensure VimTeX uses the correct local leader (must match init.lua setting)
vim.g.vimtex_mappings_enabled = 1       -- Enable VimTeX mappings
vim.g.vimtex_imaps_enabled = 1          -- Enable insert mode mappings

-- Compiler configuration with synctex enabled for reverse sync
vim.g.vimtex_compiler_latexmk = {
    options = {
        '-pdf',
        '-pdflatex=lualatex',
        '-synctex=1',                    -- Essential for reverse sync
        '-interaction=nonstopmode',
        '-file-line-error',
    }
}

-- Markdown preview configuration
vim.g.mkdp_auto_start = 0

-- Create user command for manual VimTeX initialisation
vim.api.nvim_create_user_command('InitVimTeX', function()
    vim.cmd("runtime! autoload/vimtex.vim")
    if vim.fn.exists('*vimtex#init') == 1 then
        vim.fn['vimtex#init']()
        print("VimTeX initialised manually")
    else
        print("VimTeX initialisation failed - autoload not found")
    end
end, { desc = "Manually initialise VimTeX" })

-- Automatically initialise VimTeX for TeX buffers
-- This runs only when opening TeX files and skips if VimTeX already initialised
local vimtex_auto_group = vim.api.nvim_create_augroup('VimTeXAutoInit', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = vimtex_auto_group,
  pattern = 'tex',
  desc = 'Automatically initialise VimTeX on TeX buffers',
  callback = function()
    -- If VimTeX has not attached a buffer-local state yet, trigger initialisation
    if vim.b.vimtex == nil then
      vim.defer_fn(function()
        pcall(vim.cmd, 'InitVimTeX')
      end, 50)
    end
  end,
})

-- ============================================================================
-- AUTOCOMMANDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("Config", { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  pattern = { "*.lua", "*.py", "*.js", "*.ts", "*.go", "*.rs", "*.tex", "*.md", "*.qmd" },
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Auto-save on focus loss/exit (from LunarVim)
vim.api.nvim_create_autocmd({"FocusLost", "VimLeavePre"}, {
  group = augroup,
  desc = "Auto-save on focus loss or exit",
  callback = function()
    pcall(function() vim.cmd("silent! wa") end)
  end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local pos = vim.fn.line("'\"")
    if pos > 1 and pos <= vim.fn.line("$") then
      vim.api.nvim_win_set_cursor(0, { pos, 0 })
    end
  end,
})

-- File-specific settings (from LunarVim)
vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = { "*.json", "*.jsonc", "*.md" },
    desc = "Enable wrap mode for specific files",
    command = "setlocal wrap",
})

-- File type specific settings
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "html", "css", "javascript", "typescript", "json", "yaml" },
  callback = function()
    opt.tabstop = 2
    opt.shiftwidth = 2
  end,
})

-- Syntax highlighting for zsh files (from LunarVim)
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = "zsh",
    desc = "Use bash highlighting for zsh",
    callback = function()
        pcall(function()
            require("nvim-treesitter.highlight").attach(0, "bash")
        end)
    end,
})
