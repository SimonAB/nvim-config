-- Essential Key Mappings
-- This file contains only keyboard mappings including:
-- • Leader and non-leader key mappings
-- • Window navigation and resizing
-- • Buffer navigation
-- • Editor convenience mappings (yank highlight, indent, move text)
-- • Terminal integration mappings (toggle, send line/block)
--
-- RECENT KEYMAP CHANGES:
-- • Group Letter Remapping: Toggle group moved from <leader>T* to <leader>Y*
--   to resolve collision with Terminal group
-- • Addition of Split Group: New <leader>|* prefix for split window commands
--   using pipe symbol (|) which visually represents splitting
-- • Key Collision Resolution: Terminal (<leader>T*), Toggle (<leader>Y*),
--


local map = vim.keymap.set

-- ============================================================================
-- GENERAL KEYMAPS
-- ============================================================================
-- Basic editor navigation and text manipulation mappings
-- These provide core functionality that works without any plugins

-- Better window navigation (works from normal and terminal mode)
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Terminal mode window navigation (allows moving out of terminal)
map("t", "<C-h>", "<C-\\><C-N><C-w>h", { desc = "Move to left window from terminal" })
map("t", "<C-j>", "<C-\\><C-N><C-w>j", { desc = "Move to bottom window from terminal" })
map("t", "<C-k>", "<C-\\><C-N><C-w>k", { desc = "Move to top window from terminal" })
map("t", "<C-l>", "<C-\\><C-N><C-w>l", { desc = "Move to right window from terminal" })

-- Window resizing with multiple key combinations for better macOS compatibility
-- Using Shift+Arrow as primary (more reliable on macOS)
map("n", "<S-Up>", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<S-Down>", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<S-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<S-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Leader-based resize commands (always reliable)
map("n", "<leader>Wk", ":resize -2<CR>", { desc = "Decrease window height" })
map("n", "<leader>Wj", ":resize +2<CR>", { desc = "Increase window height" })
map("n", "<leader>Wh", ":vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<leader>Wl", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Alt+Arrow for those terminals that support it
map("n", "<A-Up>", ":resize -2<CR>", { desc = "Decrease window height (Alt)" })
map("n", "<A-Down>", ":resize +2<CR>", { desc = "Increase window height (Alt)" })
map("n", "<A-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width (Alt)" })
map("n", "<A-Right>", ":vertical resize +2<CR>", { desc = "Increase window width (Alt)" })

-- Meta notation (sometimes works on macOS)
map("n", "<M-Up>", ":resize -2<CR>", { desc = "Decrease window height (Meta)" })
map("n", "<M-Down>", ":resize +2<CR>", { desc = "Increase window height (Meta)" })
map("n", "<M-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width (Meta)" })
map("n", "<M-Right>", ":vertical resize +2<CR>", { desc = "Increase window width (Meta)" })

-- Raw escape sequences for terminals that send them
map("n", "<Esc>[1;3A", ":resize -2<CR>", { desc = "Decrease window height (ESC seq)" })
map("n", "<Esc>[1;3B", ":resize +2<CR>", { desc = "Increase window height (ESC seq)" })
map("n", "<Esc>[1;3C", ":vertical resize +2<CR>", { desc = "Increase window width (ESC seq)" })
map("n", "<Esc>[1;3D", ":vertical resize -2<CR>", { desc = "Decrease window width (ESC seq)" })

-- Buffer navigation  - fallback if BufferLine not available
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

-- Buffer Operations (<leader>B)
map("n", "<leader>Bf", ":Telescope buffers<CR>", { desc = "Find buffers (Telescope)" })
map("n", "<leader>Bj", ":BufferLinePick<CR>", { desc = "Jump to buffer (BufferLine pick)" })
map("n", "<leader>Bb", function()
  local bufferline_ok = pcall(vim.cmd, "BufferLineCyclePrev")
  if not bufferline_ok then
    vim.cmd("bprevious")
  end
end, { desc = "Previous buffer" })
map("n", "<leader>Bn", function()
  local bufferline_ok = pcall(vim.cmd, "BufferLineCycleNext")
  if not bufferline_ok then
    vim.cmd("bnext")
  end
end, { desc = "Next buffer" })
map("n", "<leader>Bq", function()
  local bufferline_ok = pcall(vim.cmd, "BufferLineClose")
  if not bufferline_ok then
    vim.cmd("bdelete")
  end
end, { desc = "Close buffer" })

-- Clear search highlights
map("n", "<Esc>", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Better paste
map("v", "p", '"_dP', { desc = "Paste without yanking" })

-- ============================================================================
-- LEADER KEYMAPS
-- ============================================================================


-- Core single-key operations
map("n", "<leader>w", ":w<CR>", { desc = "Write" })
map("n", "<C-s>", ":w<CR>", { desc = "Quick save" })
map("n", "<leader>q", ":q<CR>", { desc = "Close Buffer" })
map("n", "<leader>h", ":nohlsearch<CR>", { desc = "Hide Highlight" })


-- Split commands in Split group (using | since S is for Search)
map("n", "<leader>|v", "<cmd>vsplit<CR>", { desc = "Split Vertical" })
map("n", "<leader>|h", "<cmd>split<CR>", { desc = "Split Horizontal" })

-- Toggle options (using Y prefix since T is for Terminal)
map("n", "<leader>Yw", ":set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>Yn", ":set number!<CR>", { desc = "Toggle line numbers" })

-- Enhanced theme management functions
local function show_theme_picker()
  local ok, ThemeManager = pcall(require, "core.theme-manager")
  if ok and ThemeManager.show_theme_picker then
    ThemeManager.show_theme_picker()
  else
    vim.notify("Theme Picker not available", vim.log.levels.WARN)
  end
end

local function cycle_colorscheme()
  local ok, ThemeManager = pcall(require, "core.theme-manager")
  if ok and ThemeManager.cycle_theme then
    ThemeManager.cycle_theme()
  else
    -- Fallback to simple cycling
    local colorschemes = { "catppuccin", "onedark", "tokyonight", "nord", "github_dark" }
    local current = vim.g.colors_name or "default"
    local current_index = 1

    for i, scheme in ipairs(colorschemes) do
      if scheme == current then
        current_index = i
        break
      end
    end

    local next_index = current_index % #colorschemes + 1
    local next_scheme = colorschemes[next_index]

    local success = pcall(vim.cmd.colorscheme, next_scheme)
    if success then
      vim.notify("Switched to " .. next_scheme .. " theme", vim.log.levels.INFO)
    else
      vim.notify("Failed to switch to " .. next_scheme .. " theme", vim.log.levels.WARN)
    end
  end
end

-- Theme management keybindings
map("n", "<leader>Yc", cycle_colorscheme, { desc = "Cycle themes" })
map("n", "<leader>Ytp", show_theme_picker, { desc = "Theme picker" })
map("n", "<leader>Yts", function()
  local current = vim.g.colors_name or "default"
  vim.notify("Current theme: " .. current, vim.log.levels.INFO)
end, { desc = "Show current theme" })



-- ============================================================================
-- TERMINAL INTEGRATION
-- ============================================================================
-- Advanced terminal integration for code execution and data science workflows
-- Provides smart code block detection and execution for R Markdown/Quarto
-- Key mappings: Ctrl+t (toggle), Ctrl+i (send line), Ctrl+c (send block)

-- Function to select and send current code block in R Markdown/Quarto
local function send_current_code_block()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local start_line = nil
  local end_line = nil
  local block_type = nil -- "fenced" or "header"

  -- First, check if we're in a fenced code block (```{...} ... ```)
  local fenced_start = nil
  local fenced_end = nil

  -- Find the start of the fenced code block (backwards from cursor)
  for i = current_line, 1, -1 do
    if lines[i] and lines[i]:match("^```{.*}") then
      fenced_start = i
      break
    end
  end

  -- If we found a fenced start, look for its end
  if fenced_start then
    for i = current_line, #lines do
      if lines[i] and lines[i]:match("^```%s*$") then
        fenced_end = i
        break
      end
    end
  end

  -- Check if cursor is within a valid fenced block
  if fenced_start and fenced_end and current_line > fenced_start and current_line < fenced_end then
    start_line = fenced_start
    end_line = fenced_end
    block_type = "fenced"
  else
    -- Look for header-delimited blocks (## ... ##)
    local header_start = nil
    local header_end = nil

    -- Find the start of the header block (backwards from cursor, including current line)
    for i = current_line, 1, -1 do
      if lines[i] and lines[i]:match("^##") then
        header_start = i
        break
      end
    end

    -- If we found a header start, look for the next header or end of file
    if header_start then
      -- Look for the next header line starting from the line after header_start
      for i = header_start + 1, #lines do
        if lines[i] and lines[i]:match("^##") then
          header_end = i - 1 -- End is the line before the next header
          break
        end
      end

      -- If no next header found, block goes to end of file
      if not header_end then
        header_end = #lines
      end
    end

    -- Check if cursor is within a header block
    if header_start and header_end and current_line >= header_start and current_line <= header_end then
      start_line = header_start
      end_line = header_end
      block_type = "header"
    end
  end

  -- If we found a block, select and send it
  if start_line and end_line and start_line <= end_line then
    local selection_start, selection_end

    if block_type == "fenced" then
      -- For fenced blocks, exclude the fence lines
      selection_start = start_line + 1
      selection_end = end_line - 1
    else -- header block
      -- For header blocks, include all lines including the header
      selection_start = start_line
      selection_end = end_line
    end

    -- Only proceed if there's content to select
    if selection_start <= selection_end then
      -- Select the code block content
      vim.api.nvim_win_set_cursor(0, { selection_start, 0 })
      vim.cmd("normal! V")
      vim.api.nvim_win_set_cursor(0, { selection_end, 0 })

      -- Send the selection to terminal
      pcall(function()
        vim.cmd("ToggleTermSendVisualSelection")
      end)

      -- Clear the selection
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

      -- Find the next code block and move cursor there
      local next_block_start = nil
      local search_start = block_type == "fenced" and end_line + 1 or end_line + 1

      -- Look for next fenced block first
      for i = search_start, #lines do
        if lines[i] and lines[i]:match("^```{.*}") then
          next_block_start = i + 1 -- Move to first line of code
          break
        end
      end

      -- If no fenced block found, look for next header block
      if not next_block_start then
        for i = search_start, #lines do
          if lines[i] and lines[i]:match("^##") then
            next_block_start = i -- Move to header line
            break
          end
        end
      end

      if next_block_start then
        vim.api.nvim_win_set_cursor(0, { next_block_start, 0 })
        print("Moved to next code block")
      else
        -- No next block found, stay at end of current block
        vim.api.nvim_win_set_cursor(0, { end_line, 0 })
        print("No more code blocks found")
      end
    else
      print("Empty code block")
    end
  else
    print("No code block found around cursor")
  end
end

-- Terminal keybindings
map("n", "<C-t>", "<esc><cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<C-i>", "<esc><cmd>ToggleTermSendCurrentLine<CR>j", { desc = "Send current line to terminal" })
map("n", "<C-c>", send_current_code_block, { desc = "Send current code block to terminal" })
map("v", "<C-s>", ":'<,'>ToggleTermSendVisualSelection<CR>", { desc = "Send selected lines to terminal" })
-- Terminal clear - works from any window, finds and clears terminal
map("n", "<leader>Tk", function()
  local current_win = vim.api.nvim_get_current_win()
  local terminal_win = nil
  local terminal_buf = nil

  -- If we're already in a terminal, use it
  if vim.bo.buftype == 'terminal' then
    terminal_win = current_win
    terminal_buf = vim.api.nvim_get_current_buf()
  else
    -- Search for an existing terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        terminal_win = win
        terminal_buf = buf
        break
      end
    end
  end

  if terminal_win and terminal_buf then
    -- Switch to terminal window, clear it, then return
    local original_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(terminal_win)
    vim.cmd('startinsert')
    -- Send the clear command followed by Enter
    vim.api.nvim_feedkeys('clear', 't', false)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 't', false)

    -- Return to original window if we switched
    if original_win ~= terminal_win then
      vim.schedule(function()
        pcall(vim.api.nvim_set_current_win, original_win)
      end)
    end
    print('Terminal cleared')
  else
    print('No terminal window found - open a terminal first')
  end
end, { desc = "Terminal Clear" })

-- Terminal kill/delete - works from any window, finds and kills terminal
map("n", "<leader>Td", function()
  local current_win = vim.api.nvim_get_current_win()
  local terminal_win = nil
  local terminal_buf = nil

  -- If we're already in a terminal, use it
  if vim.bo.buftype == 'terminal' then
    terminal_win = current_win
    terminal_buf = vim.api.nvim_get_current_buf()
  else
    -- Search for an existing terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        terminal_win = win
        terminal_buf = buf
        break
      end
    end
  end

  if terminal_win and terminal_buf then
    -- Force delete the terminal buffer (this will close the window too)
    vim.api.nvim_buf_delete(terminal_buf, { force = true })
    print('Terminal killed')
  else
    print('No terminal window found')
  end
end, { desc = "Terminal Delete" })

-- Terminal mode keymaps - allow toggling terminals from within terminal
map("t", "<C-t>", "<C-\\><C-N><cmd>ToggleTerm<CR>", { desc = "Toggle terminal from terminal" })
map("t", "<Esc>", "<C-\\><C-N>", { desc = "Exit terminal mode" })

-- Helper function to create terminal commands that work from both normal and terminal mode
local function make_terminal_cmd(direction, size)
  return function()
    -- Check if we're in terminal mode
    if vim.fn.mode() == 't' then
      -- Exit terminal mode first, then execute command
      vim.cmd('stopinsert')
      vim.schedule(function()
        vim.cmd('ToggleTerm direction=' .. direction .. (size and ' size=' .. size or ''))
      end)
    else
      -- Normal mode - execute directly
      vim.cmd('ToggleTerm direction=' .. direction .. (size and ' size=' .. size or ''))
    end
  end
end

-- ToggleTerm shortcuts that work from both normal and terminal mode
-- For horizontal: using line count (15-20 lines)
-- For vertical: using percentage (30% of screen width)
map({ 'n', 't' }, "<A-1>", make_terminal_cmd('horizontal', 15), { desc = "Horizontal Terminal (15 lines)" })
map({ 'n', 't' }, "<A-2>", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)),
  { desc = "Vertical Terminal (30%)" })
map({ 'n', 't' }, "<A-3>", make_terminal_cmd('float'), { desc = "Float Terminal" })

-- Alternative Meta notation for macOS (sometimes works better)
map({ 'n', 't' }, "<M-1>", make_terminal_cmd('horizontal', 15), { desc = "Horizontal Terminal (15 lines, Meta)" })
map({ 'n', 't' }, "<M-2>", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)),
  { desc = "Vertical Terminal (30%, Meta)" })
map({ 'n', 't' }, "<M-3>", make_terminal_cmd('float'), { desc = "Float Terminal (Meta)" })

-- Leader-based alternatives as backup (using T for Terminal group)
map({ 'n', 't' }, "<leader>T1", make_terminal_cmd('horizontal', 15), { desc = "Terminal Horizontal" })
map({ 'n', 't' }, "<leader>T2", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)),
  { desc = "Terminal Vertical" })
map({ 'n', 't' }, "<leader>T3", make_terminal_cmd('float'), { desc = "Terminal Float" })

-- ============================================================================
-- VIMTEX KEYMAPS
-- ============================================================================
-- VimTeX integration keymaps for LaTeX document processing
-- These provide forward/inverse search and compilation control
-- Using LocalLeader prefix to avoid conflicts with main leader bindings

-- VimTeX keymaps (simple commands)
map("n", "<localleader>lv", ":VimtexView<CR>", { noremap = true, silent = true, desc = "View (forward sync)" })
map("n", "<localleader>li", ":VimtexInverseSearch<CR>", { noremap = true, silent = true, desc = "Inverse search" })
map("n", "<localleader>ll", ":VimtexCompile<CR>", { noremap = true, silent = true, desc = "Compile (latexmk)" })
map("n", "<localleader>lc", ":VimtexClean<CR>", { noremap = true, silent = true, desc = "Clean aux files" })
map("n", "<localleader>ls", ":VimtexStop<CR>", { noremap = true, silent = true, desc = "Stop compiler" })

-- ============================================================================
-- TYPST KEYMAPS
-- ============================================================================
-- Typst integration keymaps for Typst document processing
-- These provide preview control and PDF compilation
-- Using LocalLeader prefix to avoid conflicts with main leader bindings

-- Typst preview keymaps (simple commands)
map("n", "<LocalLeader>tp", ":TypstPreviewToggle<CR>", { noremap = true, silent = true, desc = "Toggle Typst preview" })
map("n", "<LocalLeader>ts", ":TypstPreviewSyncCursor<CR>",
  { noremap = true, silent = true, desc = "Sync cursor in preview" })

-- Typst compile PDF using command line
map("n", "<LocalLeader>tc", function()
  local current_file = vim.fn.expand('%:p')
  if current_file == '' then
    vim.notify("No file is currently open", vim.log.levels.ERROR)
    return
  end

  -- Check if file has .typ extension
  if vim.fn.fnamemodify(current_file, ':e') ~= 'typ' then
    vim.notify("Current file is not a Typst file (.typ)", vim.log.levels.ERROR)
    return
  end

  -- Build the typst compile command (shorthand: typst c <filename>)
  local cmd = string.format('typst c "%s"', current_file)

  -- Execute the command
  vim.fn.jobstart(cmd, {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("PDF compiled successfully", vim.log.levels.INFO)
      else
        vim.notify("Failed to compile PDF", vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.notify("Typst compilation error: " .. table.concat(data, " "), vim.log.levels.ERROR)
      end
    end
  })
end, { desc = "Compile PDF with typst c" })

-- Typst watch using command line
map("n", "<LocalLeader>tw", function()
  local current_file = vim.fn.expand('%:p')
  if current_file == '' then
    vim.notify("No file is currently open", vim.log.levels.ERROR)
    return
  end

  -- Check if file has .typ extension
  if vim.fn.fnamemodify(current_file, ':e') ~= 'typ' then
    vim.notify("Current file is not a Typst file (.typ)", vim.log.levels.ERROR)
    return
  end

  -- Build the typst watch command (shorthand: typst w <filename>)
  local cmd = string.format('typst w "%s"', current_file)

  -- Execute the command in a terminal
  local Terminal = require("toggleterm.terminal").Terminal
  local typst_watch = Terminal:new({
    cmd = cmd,
    hidden = true,
    direction = "horizontal",
    close_on_exit = false,
    on_open = function(_)
      vim.cmd("startinsert!")
    end,
  })
  typst_watch:toggle()
end, { desc = "Watch file with typst w" })

-- ============================================================================
-- LEADER KEYMAPS
-- ============================================================================
-- These provide various functionality across different plugins

-- File tree
map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- File operations
map("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>F", ":Telescope frecency<CR>", { desc = "Find files (by frequency/recency)" })
map("n", "<leader>fr", ":lua require('telescope').extensions.frecency.frecency()<CR>",
  { desc = "Refresh frecency database" })
map("n", "<leader>fd", ":lua print('Frecency DB: ' .. vim.fn.stdpath('data') .. '/telescope-frecency.sqlite3')<CR>",
  { desc = "Show frecency database location" })
map("n", "<leader>fb",
  ":lua vim.fn.delete(vim.fn.stdpath('data') .. '/telescope-frecency.sqlite3') or print('Frecency database deleted. Restart Neovim to rebuild.')<CR>",
  { desc = "Rebuild frecency database" })

-- Git operations
map("n", "<leader>Gs", function()
  vim.cmd("!git status")
end, { desc = "Git Status" })

-- Grep operations
map("n", "<leader>g", function()
  local builtin = require('telescope.builtin')
  -- Prefer Git root if available, otherwise fall back to current working directory
  local cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if not cwd or cwd == '' or cwd:match('fatal:') then
    cwd = vim.loop.cwd() or vim.fn.getcwd()
  end
  builtin.live_grep({ cwd = cwd })
end, { desc = "Grep in project" })

map("n", "<leader>gw", function()
  local builtin = require('telescope.builtin')
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  builtin.live_grep({ cwd = cwd })
end, { desc = "Grep in current working directory" })

map("n", "<leader>gh", function()
  local builtin = require('telescope.builtin')
  local home = vim.loop.os_homedir() or vim.fn.expand("~")
  builtin.live_grep({ search_dirs = { home } })
end, { desc = "Grep in home directory" })

map("n", "<leader>gc", function()
  local builtin = require('telescope.builtin')
  local config_path = vim.fn.stdpath("config")
  builtin.live_grep({ cwd = config_path })
end, { desc = "Grep in config" })

map("n", "<leader>gf", function()
  local builtin = require('telescope.builtin')
  local current_file = vim.fn.expand('%:p')
  if current_file ~= '' then
    local current_dir = vim.fn.fnamemodify(current_file, ':h')
    builtin.live_grep({ cwd = current_dir })
  else
    builtin.live_grep()
  end
end, { desc = "Grep in current file directory" })

map("n", "<leader>Gp", function()
  vim.cmd("!git pull")
end, { desc = "Git Pull" })

map("n", "<leader>Gg", function()
  local Terminal = require("toggleterm.terminal").Terminal
  local lazygit = Terminal:new({
    cmd = "lazygit",
    dir = "git_dir", -- open in the Git root for correct repo context
    hidden = true,
    direction = "float",
    float_opts = {
      border = "curved",
      width = function()
        return math.floor(vim.o.columns * 0.9)
      end,
      height = function()
        return math.floor(vim.o.lines * 0.9)
      end,
    },
    close_on_exit = true,
    -- Configure environment to use nvim as editor for commit messages
    env = {
      TERM = "xterm-256color",
      COLORTERM = "truecolor",
      EDITOR = "nvim --clean",
      GIT_EDITOR = "nvim --clean",
      -- Prevent socket conflicts by unsetting NVIM variables
      NVIM = "",
      NVIM_LISTEN_ADDRESS = "",
    },
    on_open = function(term)
      vim.cmd("startinsert!")
      -- Disable conflicting keymaps while lazygit is open
      vim.keymap.set("t", "<esc>", "<esc>", { buffer = term.bufnr })
    end,
    on_close = function()
      -- Re-enable keymaps when lazygit closes
      vim.cmd("stopinsert")
    end,
  })
  lazygit:toggle()
end, { desc = "LazyGit" })

-- Obsidian operations
map("n", "<leader>On", function()
  pcall(function()
    require("obsidian").util.new_note()
  end)
end, { desc = "New Obsidian note" })

map("n", "<leader>Ol", function()
  pcall(function()
    require("obsidian").util.insert_link()
  end)
end, { desc = "Insert Obsidian link" })

map("n", "<leader>Of", function()
  pcall(function()
    require("obsidian").util.follow_link()
  end)
end, { desc = "Follow Obsidian link" })

map("n", "<leader>Oc", function()
  pcall(function()
    require("obsidian").util.toggle_checkbox()
  end)
end, { desc = "Toggle Obsidian checkbox" })

map("n", "<leader>Ob", function()
  pcall(function()
    require("obsidian").util.show_backlinks()
  end)
end, { desc = "Show Obsidian backlinks" })

map("n", "<leader>Og", function()
  pcall(function()
    require("obsidian").util.show_outgoing_links()
  end)
end, { desc = "Show Obsidian outgoing links" })

map("n", "<leader>Oo", function()
  local obsidian_path = "/Users/s_a_b/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notebook"
  require("telescope.builtin").find_files({
    cwd = obsidian_path,
    prompt_title = "Obsidian Vault"
  })
end, { desc = "Find files in Obsidian vault" })

map("n", "<leader>Ot", function()
  pcall(function()
    vim.cmd("ObsidianTemplate")
  end)
end, { desc = "Insert Obsidian template" })

map("n", "<leader>ON", function()
  pcall(function()
    vim.cmd("ObsidianNewFromTemplate")
  end)
end, { desc = "New note from template" })

map("n", "<leader>Op", function()
  pcall(function()
    vim.cmd("ObsidianPasteImg")
  end)
end, { desc = "Paste image into Obsidian note" })

map("n", "<leader>Ov", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Obsidian Preview" })

-- LSP operations
map("n", "<leader>Ll", function()
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
end, { desc = "List available servers" })

map("n", "<leader>Lr", function()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No active LSP clients to restart")
  else
    print("Restarting LSP...")
    vim.cmd("LspRestart")
  end
end, { desc = "Restart LSP" })

map("n", "<leader>Lf", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format Document" })

map("n", "<leader>LR", function()
  vim.lsp.buf.references()
end, { desc = "Show References" })

map("n", "<leader>Lm", "<cmd>Mason<CR>", { desc = "Open Mason" })

-- Quarto operations
map("n", "<leader>Qp", function()
  pcall(function()
    require("quarto").quartoPreview()
  end)
end, { desc = "Quarto Preview" })

map("n", "<leader>Qc", function()
  pcall(function()
    require("quarto").quartoClosePreview()
  end)
end, { desc = "Close preview" })

map("n", "<leader>Qr", function()
  pcall(function()
    vim.cmd("QuartoRender")
  end)
end, { desc = "Quarto Render" })

-- Molten keymaps
map("n", "<leader>Qmi", function()
  vim.cmd("MoltenImagePopup")
end, { desc = "Show Image Popup" })

map("n", "<leader>Qml", function()
  vim.cmd("MoltenEvaluateLine")
end, { desc = "Evaluate Line" })

map("n", "<leader>Qme", function()
  vim.cmd("MoltenEvaluateOperator")
end, { desc = "Evaluate Operator" })

map("n", "<leader>Qmn", function()
  pcall(function()
    vim.cmd("MoltenInit")
  end)
end, { desc = "Initialise Kernel" })

map("n", "<leader>Qmk", function()
  pcall(function()
    vim.cmd("MoltenDeinit")
  end)
end, { desc = "Stop Kernel" })

map("n", "<leader>Qmr", function()
  pcall(function()
    vim.cmd("MoltenRestart")
  end)
end, { desc = "Restart Kernel" })

map("n", "<leader>Qmo", function()
  pcall(function()
    vim.cmd("MoltenEvaluateOperator")
  end)
end, { desc = "Evaluate Operator" })

map("n", "<leader>Qm<CR>", function()
  pcall(function()
    vim.cmd("MoltenEvaluateLine")
  end)
end, { desc = "Evaluate Line" })

map("n", "<leader>Qmv", function()
  pcall(function()
    vim.cmd("MoltenEvaluateVisual")
  end)
end, { desc = "Evaluate Visual" })

map("n", "<leader>Qmf", function()
  pcall(function()
    vim.cmd("MoltenReevaluateCell")
  end)
end, { desc = "Re-evaluate Cell" })

map("n", "<leader>Qmh", function()
  pcall(function()
    vim.cmd("MoltenHideOutput")
  end)
end, { desc = "Hide Output" })

map("n", "<leader>Qms", function()
  pcall(function()
    vim.cmd("MoltenShowOutput")
  end)
end, { desc = "Show Output" })

map("n", "<leader>Qmd", function()
  pcall(function()
    vim.cmd("MoltenDelete")
  end)
end, { desc = "Delete Cell" })

map("n", "<leader>Qmb", function()
  pcall(function()
    vim.cmd("MoltenOpenInBrowser")
  end)
end, { desc = "Open in Browser" })

-- Toggle options (these were missing from the moved keymaps)
map("n", "<leader>Ys", ":set spell!<CR>", { desc = "Toggle Spell Check" })
map("n", "<leader>Yse", ":set spelllang=en_gb<CR>:set spell<CR>", { desc = "Set spell language to English (British)" })
map("n", "<leader>Ysf", ":set spelllang=fr<CR>:set spell<CR>", { desc = "Set spell language to French" })

-- Split operations (removing duplicate)

-- Trouble diagnostics
map("n", "<leader>Xw", ":TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
map("n", "<leader>Xd", ":TroubleToggle document_diagnostics<CR>", { desc = "Document Diagnostics" })
map("n", "<leader>Xl", ":TroubleToggle loclist<CR>", { desc = "Location List" })
map("n", "<leader>Xq", ":TroubleToggle quickfix<CR>", { desc = "Quickfix" })

-- Mason operations
map("n", "<leader>Mm", "<cmd>Mason<CR>", { desc = "Open Mason" })
map("n", "<leader>Mi", "<cmd>MasonInstall<CR>", { desc = "Install Package" })
map("n", "<leader>Mu", "<cmd>MasonUninstall<CR>", { desc = "Uninstall Package" })
map("n", "<leader>Ml", "<cmd>MasonLog<CR>", { desc = "View Mason Log" })
map("n", "<leader>Mh", "<cmd>MasonHelp<CR>", { desc = "Mason Help" })

-- Markdown preview keymaps
map("n", "<leader>Kp", "<cmd>MarkdownPreview<CR>", { desc = "Start Markdown Preview" })
map("n", "<leader>Ks", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview" })
map("n", "<leader>Kt", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })

-- Configuration reload
map("n", "<leader>Cs", function()
  -- Comprehensive configuration reload
  local config_path = vim.fn.stdpath("config")

  -- Clear Lua module cache for config files to force reload
  local modules_to_clear = {
    "config",
    "keymaps",
    "plugins",
  }

  for _, module in ipairs(modules_to_clear) do
    package.loaded[module] = nil
  end

  -- Source all configuration files in proper order
  vim.cmd("source " .. config_path .. "/init.lua")

  -- Show confirmation with file list
  print("✓ Configuration reloaded!")
end, { desc = "Source config" })

-- Configuration file find
map("n", "<leader>Cf", function()
  local config_path = vim.fn.stdpath("config")
  vim.cmd("Telescope find_files cwd=" .. config_path)
end, { desc = "Find config files" })

-- Configuration grep
map("n", "<leader>Cg", function()
  local builtin = require('telescope.builtin')
  local config_path = vim.fn.stdpath("config")
  builtin.live_grep({ cwd = config_path })
end, { desc = "Grep config files" })

-- Configuration grep (moved to <leader>gc)

-- Julia-specific operations
-- Centralised function to open Julia REPL with specified direction
local function open_julia_repl(direction)
  local Terminal = require("toggleterm.terminal").Terminal
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

map("n", "<leader>Jrh", function()
  open_julia_repl("horizontal")
end, { desc = "Horizontal REPL" })

map("n", "<leader>Jrv", function()
  open_julia_repl("vertical")
end, { desc = "Vertical REPL" })

map("n", "<leader>Jrf", function()
  open_julia_repl("float")
end, { desc = "Floating REPL" })

map("n", "<leader>Jp", function()
  -- Show project status using ToggleTerm
  local Terminal = require("toggleterm.terminal").Terminal
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
end, { desc = "Project Status" })

map("n", "<leader>Ji", function()
  -- Instantiate project using ToggleTerm
  local Terminal = require("toggleterm.terminal").Terminal
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
end, { desc = "Instantiate Project" })

map("n", "<leader>Ju", function()
  -- Update project using ToggleTerm
  local Terminal = require("toggleterm.terminal").Terminal
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
end, { desc = "Update Project" })

map("n", "<leader>Jt", function()
  -- Run tests using ToggleTerm
  local Terminal = require("toggleterm.terminal").Terminal
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
end, { desc = "Run Tests" })

map("n", "<leader>Jd", function()
  -- Generate documentation using ToggleTerm
  local Terminal = require("toggleterm.terminal").Terminal
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
end, { desc = "Generate Docs" })

-- =============================================================================
-- ENHANCED PLUGIN MANAGER KEYBINDINGS
-- =============================================================================

-- Helper function to safely call PluginManager functions
local function call_plugin_manager(func_name)
  local ok, PluginManager = pcall(require, "core.plugin-manager")
  if ok then
    PluginManager[func_name](PluginManager)
  else
    vim.notify("Plugin Manager not available", vim.log.levels.WARN)
  end
end

-- Plugin management keybindings with progress feedback
map("n", "<leader>Cua", function() call_plugin_manager("update_all_plugins") end, { desc = "Update All Plugins" })
map("n", "<leader>Cus", function() call_plugin_manager("show_status") end, { desc = "Plugin Status" })
map("n", "<leader>Cuc", function() call_plugin_manager("cleanup_orphaned") end, { desc = "Cleanup Orphaned Plugins" })
