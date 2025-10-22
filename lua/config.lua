-- Core Neovim Configuration

local opt = vim.opt

-- ============================================================================
-- CORE EDITOR SETTINGS
-- ============================================================================

-- Line numbers
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.signcolumn = "yes" -- Show sign column

-- Indentation
opt.tabstop = 4    -- Configure tabs
opt.shiftwidth = 4 -- Set indentation width
opt.expandtab = true -- Expand tabs to spaces
opt.smartindent = true -- Smart indentation

-- Search
opt.ignorecase = true -- Ignore case in search
opt.smartcase = true -- Smart case in search
opt.hlsearch = true -- Highlight search matches
opt.incsearch = true -- Incremental search

-- Visual
opt.cursorline = true -- Highlight current line
opt.wrap = true      -- Enable line wrapping
opt.linebreak = true -- Wrap at word boundaries
opt.scrolloff = 8 -- Scroll offset
opt.sidescrolloff = 8 -- Side scroll offset
opt.conceallevel = 2 -- Enable concealment for Obsidian.nvim and VimTex

-- Behavior
opt.mouse = "a" -- Enable mouse
opt.clipboard = "unnamedplus" -- Use system clipboard
opt.splitbelow = true -- Split below
opt.splitright = true -- Split right
opt.hidden = true -- Hide buffers instead of closing them

-- Performance
opt.updatetime = 250 -- Update time
opt.timeoutlen = 300 -- Timeout length

-- Files
opt.swapfile = false -- Disable swap file
opt.backup = false -- Disable backup file
opt.undofile = true -- Enable undo file

-- Security
opt.modeline = false -- Disable modeline
opt.exrc = false -- Disable exrc file

-- Language and spell checking
opt.spelllang = "en_gb" -- Set British English spelling
opt.spell = true -- Enable spell checking by default

-- Terminal colours (enables true colour support)
opt.termguicolors = true

-- Font configuration
opt.guifont = "LigaSFMonoNerdFont-Regular:h10" -- Set font

-- ============================================================================
-- GLOBAL VARIABLES
-- ============================================================================

-- Configuration file paths for hot-reloading
local config_dir = vim.fn.stdpath('config')
local config_files = {
  init = config_dir .. '/init.lua',
  plugins = config_dir .. '/lua/plugins/require.lua',
  keymaps = config_dir .. '/lua/keymaps.lua',
  custom = config_dir .. '/lua/config.lua',
}

-- Expose config files globally for keymaps module
_G.nvim_config_files = config_files

-- Enable filetype detection
vim.cmd("filetype plugin indent on")

-- Theme customisation
vim.g.sonokai_enable_italic_comment = 1

-- VimTeX configuration (Skim integration)

-- VimTeX configuration with Skim reverse sync support (per official VimTeX docs)
vim.g.vimtex_enabled = 1               -- Explicitly enable VimTeX
vim.g.vimtex_view_method = 'skim'
vim.g.vimtex_view_skim_activate = 0    -- Do not steal focus on view
vim.g.vimtex_view_skim_reading_bar = 1 -- Highlight current location
vim.g.vimtex_view_skim_sync = 1        -- Forward sync after compilation

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
vim.g.vimtex_mappings_enabled = 1 -- Enable VimTeX mappings
vim.g.vimtex_imaps_enabled = 1    -- Enable insert mode mappings

-- Compiler configuration with synctex enabled for reverse sync
vim.g.vimtex_compiler_latexmk = {
  options = {
    '-pdf',
    '-pdflatex=lualatex',
    '-synctex=1', -- Essential for reverse sync
    '-interaction=nonstopmode',
    '-file-line-error',
  }
}

-- Markdown preview configuration (handled in plugins/markdown-preview-nvim.lua)

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

-- Optimised autocmd patterns for better performance
local function create_optimised_autocmds()
  -- Highlight yanked text
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
      vim.hl.on_yank({ timeout = 200 })
    end,
  })

  -- Remove trailing whitespace and enforce single newline at EOF on save
  local whitespace_filetypes = { "*.lua", "*.py", "*.js", "*.ts", "*.go", "*.rs", "*.tex", "*.md", "*.qmd", "*.typ", "*.bib" }
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    pattern = whitespace_filetypes,
    callback = function()
      local pos = vim.api.nvim_win_get_cursor(0)
      local bufnr = vim.api.nvim_get_current_buf()
      
      -- Remove trailing whitespace (existing functionality)
      local has_trailing = vim.fn.search('\\s\\+$', 'n') > 0
      if has_trailing then
        vim.cmd([[%s/\s\+$//e]])
      end
      
      -- Collapse multiple consecutive empty lines into single empty lines
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local collapsed_lines = {}
      local prev_line_empty = false
      
      for _, line in ipairs(lines) do
        local is_empty = line:match("^%s*$") ~= nil
        if not (is_empty and prev_line_empty) then
          collapsed_lines[#collapsed_lines + 1] = line
        end
        prev_line_empty = is_empty
      end
      
      -- Only update buffer if changes were made
      if #collapsed_lines ~= #lines then
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, collapsed_lines)
        
        -- Adjust cursor position if needed
        local new_row = math.min(pos[1], #collapsed_lines)
        local line_length = #(collapsed_lines[new_row] or "")
        local new_col = math.min(pos[2], line_length)
        pos = { new_row, new_col }
      end
      
      -- Enforce exactly one newline at end of file
      lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      if #lines > 0 then
        local last_line = lines[#lines]
        local non_empty_lines = {}
        
        -- Find the last non-empty line
        for i = #lines, 1, -1 do
          if lines[i]:match("%S") then -- line contains non-whitespace
            non_empty_lines = { unpack(lines, 1, i) }
            break
          end
        end
        
        -- Ensure exactly one empty line at the end
        if #non_empty_lines > 0 then
          non_empty_lines[#non_empty_lines + 1] = "" -- Add exactly one empty line
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, non_empty_lines)
          
          -- Update cursor position to be within bounds after buffer modification
          local new_line_count = #non_empty_lines
          local new_col = math.min(pos[2], #lines[pos[1]] or 0)
          local new_row = math.min(pos[1], new_line_count)
          
          -- Ensure cursor is within valid bounds
          if new_row > 0 and new_row <= new_line_count then
            vim.api.nvim_win_set_cursor(0, { new_row, new_col })
          else
            -- Fallback: set cursor to end of file
            vim.api.nvim_win_set_cursor(0, { new_line_count, 0 })
          end
        else
          -- No non-empty lines found, restore original position
          vim.api.nvim_win_set_cursor(0, pos)
        end
      else
        -- Empty file, restore original position
        vim.api.nvim_win_set_cursor(0, pos)
      end
    end,
  })

  -- Auto-save on focus loss/exit
  vim.api.nvim_create_autocmd({ "FocusLost", "VimLeavePre" }, {
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

  -- File-specific settings with lookup table for better performance
  local file_settings = {
    ["*.json"] = function() vim.cmd("setlocal wrap") end,
    ["*.jsonc"] = function() vim.cmd("setlocal wrap") end,
    ["*.md"] = function() vim.cmd("setlocal wrap") end,
  }

  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = vim.tbl_keys(file_settings),
    desc = "File-specific settings",
    callback = function(args)
      local setting = file_settings[args.match]
      if setting then
        setting()
      end
    end,
  })

  -- File type specific settings with improved performance
  local filetype_settings = {
    -- 2-space indentation
    ["html,css,javascript,typescript,json,yaml"] = function()
      opt.tabstop = 2
      opt.shiftwidth = 2
    end,
    -- Zsh syntax highlighting
    ["zsh"] = function()
      pcall(function()
        require("nvim-treesitter.highlight").attach(0, "bash")
      end)
    end,
  }

  for pattern, config in pairs(filetype_settings) do
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = pattern,
      callback = config,
    })
  end
end

-- Create optimised autocmds
create_optimised_autocmds()
