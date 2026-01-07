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
-- HELPER FUNCTIONS
-- ============================================================================
-- Centralised helper functions for consistent keymap patterns

-- Safe command execution with error handling
local function safe_cmd(cmd, desc)
  return function()
    local success, err = pcall(vim.cmd, cmd)
    if not success then
      vim.notify("Command failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
    end
  end
end

-- Safe require with fallback
local function safe_require(module, fallback_func)
  return function()
    local ok, mod = pcall(require, module)
    if ok and mod then
      return mod
    elseif fallback_func then
      return fallback_func()
    else
      vim.notify("Module " .. module .. " not available", vim.log.levels.WARN)
      return nil
    end
  end
end

-- Terminal creation helper
local function create_terminal(cmd, opts)
  local Terminal = require("toggleterm.terminal").Terminal
  local default_opts = {
    hidden = true,
    direction = "horizontal",
    close_on_exit = false,
    on_open = function(_)
      vim.cmd("startinsert!")
    end,
  }
  local terminal = Terminal:new(vim.tbl_extend("force", default_opts, opts or {}))
  terminal.cmd = cmd
  return terminal
end

-- Buffer operations with fallback
local function buffer_operation(bufferline_cmd, fallback_cmd)
  return function()
    local success = pcall(vim.cmd, bufferline_cmd)
    if not success then
      vim.cmd(fallback_cmd)
    end
  end
end

--- Toggle Zen Mode using folke/zen-mode.nvim with graceful fallback.
local function toggle_zen_mode()
	local ok, zen_mode = pcall(require, "zen-mode")
	if not ok then
		vim.notify("zen-mode.nvim not available", vim.log.levels.WARN)
		return
	end
	zen_mode.toggle()
end

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
map("n", "<S-Up>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<S-Down>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<S-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<S-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Leader-based resize commands (always reliable)
map("n", "<leader>Wk", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<leader>Wj", "<cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<leader>Wh", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<leader>Wl", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Alt+Arrow for those terminals that support it
map("n", "<A-Up>", "<cmd>resize -2<CR>", { desc = "Decrease window height (Alt)" })
map("n", "<A-Down>", "<cmd>resize +2<CR>", { desc = "Increase window height (Alt)" })
map("n", "<A-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width (Alt)" })
map("n", "<A-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width (Alt)" })

-- Meta notation (sometimes works on macOS)
map("n", "<M-Up>", "<cmd>resize -2<CR>", { desc = "Decrease window height (Meta)" })
map("n", "<M-Down>", "<cmd>resize +2<CR>", { desc = "Increase window height (Meta)" })
map("n", "<M-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width (Meta)" })
map("n", "<M-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width (Meta)" })

-- Raw escape sequences for terminals that send them
map("n", "<Esc>[1;3A", "<cmd>resize -2<CR>", { desc = "Decrease window height (ESC seq)" })
map("n", "<Esc>[1;3B", "<cmd>resize +2<CR>", { desc = "Increase window height (ESC seq)" })
map("n", "<Esc>[1;3C", "<cmd>vertical resize +2<CR>", { desc = "Increase window width (ESC seq)" })
map("n", "<Esc>[1;3D", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width (ESC seq)" })

-- Buffer navigation  - fallback if BufferLine not available
map("n", "<S-l>", buffer_operation("BufferLineCycleNext", "bnext"), { desc = "Next buffer" })
map("n", "<S-h>", buffer_operation("BufferLineCyclePrev", "bprevious"), { desc = "Previous buffer" })

-- Buffer Operations (<leader>B)
map("n", "<leader>Bf", "<cmd>Telescope buffers<CR>", { desc = "Find buffers (Telescope)" })
map("n", "<leader>Bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
map("n", "<leader>Bb", buffer_operation("BufferLineCyclePrev", "bprevious"), { desc = "Previous buffer" })
map("n", "<leader>Bn", buffer_operation("BufferLineCycleNext", "bnext"), { desc = "Next buffer" })
map("n", "<leader>Bq", buffer_operation("BufferLineClose", "bdelete"), { desc = "Close buffer" })
map("n", "<leader>Bl", "<cmd>ls!<CR>", { desc = "List all buffers (including unlisted)" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

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
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Quick save" })
map("n", "<leader>q", "<cmd>bdelete<CR>", { desc = "Close Buffer" })
map("n", "<leader>h", "<cmd>nohlsearch<CR>", { desc = "Hide Highlight" })
map("n", "<leader>z", toggle_zen_mode, { desc = "Toggle Zen Mode" })

-- Split commands in Split group (using | since S is for Search)
map("n", "<leader>|v", "<cmd>vsplit<CR>", { desc = "Split Vertical" })
map("n", "<leader>|h", "<cmd>split<CR>", { desc = "Split Horizontal" })

-- Toggle options (using Y prefix since T is for Terminal)
map("n", "<leader>Yw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>Yn", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })
map("n", "<leader>Yz", toggle_zen_mode, { desc = "Toggle Zen Mode" })

-- Enhanced theme management functions with deferred loading
local function show_theme_picker()
  vim.defer_fn(function()
    local ok, ThemeManager = pcall(require, "core.theme-manager")
    if ok and ThemeManager.show_theme_picker then
      ThemeManager.show_theme_picker()
    else
      vim.notify("Theme Picker not available", vim.log.levels.WARN)
    end
  end, 50)
end

local function cycle_colorscheme()
  vim.defer_fn(function()
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
  end, 50)
end

-- Theme management keybindings
map("n", "<leader>Yc", cycle_colorscheme, { desc = "Cycle themes" })
map("n", "<leader>YTp", show_theme_picker, { desc = "Theme picker" })
map("n", "<leader>YTs", function()
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

-- Function to yank code chunk content (excluding delimiters)
-- Works when cursor is inside the chunk or on the delimiter lines
-- Supports both Quarto format (```{language}) and Markdown format (```language or ```)
local function yank_code_chunk()
  local buf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = cursor[1]
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  local fenced_start = nil
  local fenced_end = nil

  -- Helper function to check if a line is an opening delimiter
  local function is_opening_delimiter(line)
    if not line then return false end
    -- Match Quarto format: ```{language} or ```{language, options}
    if line:match("^```{.*}") then return true end
    -- Match Markdown format: ```language or ``` (plain)
    if line:match("^```") then return true end
    return false
  end

  -- Helper function to check if a line is a closing delimiter
  local function is_closing_delimiter(line)
    if not line then return false end
    -- Closing delimiter is just ``` (with optional whitespace)
    return line:match("^```%s*$") ~= nil
  end

  -- Check if current line is a delimiter line
  local is_on_opening = is_opening_delimiter(lines[current_line])
  local is_on_closing = is_closing_delimiter(lines[current_line])

  -- Find the start of the fenced code block
  -- If we're on the opening delimiter, use it; otherwise search backwards
  if is_on_opening then
    fenced_start = current_line
  elseif is_on_closing then
    -- If on closing delimiter, search backwards to find the matching opening
    for i = current_line - 1, 1, -1 do
      if is_opening_delimiter(lines[i]) then
        fenced_start = i
        break
      end
    end
    -- If we found a start, the end is the current line
    if fenced_start then
      fenced_end = current_line
    end
  else
    -- Cursor is inside the code block, search backwards for opening
    for i = current_line, 1, -1 do
      if is_opening_delimiter(lines[i]) then
        fenced_start = i
        break
      end
    end
  end

  -- If we found a start but not an end yet, search forwards for the closing delimiter
  if fenced_start and not fenced_end then
    -- Search forwards from the start (skip the opening delimiter)
    for i = fenced_start + 1, #lines do
      if is_closing_delimiter(lines[i]) then
        fenced_end = i
        break
      end
    end
  end

  -- Check if we have a valid code chunk
  if fenced_start and fenced_end and fenced_start < fenced_end then
    -- Extract only the code content (exclude delimiters)
    local code_start = fenced_start + 1
    local code_end = fenced_end - 1

    -- Only proceed if there's actual code content
    if code_start <= code_end then
      -- Get the code lines
      local code_lines = {}
      for i = code_start, code_end do
        table.insert(code_lines, lines[i])
      end

      -- Join lines with newlines
      local code_content = table.concat(code_lines, "\n")
      -- Add trailing newline if content exists
      if #code_lines > 0 then
        code_content = code_content .. "\n"
      end

      -- Yank to the default register
      vim.fn.setreg('"', code_content)
      vim.fn.setreg('+', code_content) -- Also yank to system clipboard if available
      vim.fn.setreg('*', code_content) -- Also yank to primary selection if available

      -- Show visual feedback
      vim.notify("Yanked code chunk (" .. (code_end - code_start + 1) .. " lines)", vim.log.levels.INFO)
    else
      vim.notify("Empty code chunk", vim.log.levels.WARN)
    end
  else
    vim.notify("No code chunk found around cursor", vim.log.levels.WARN)
  end
end

-- Terminal keybindings
map("n", "<C-t>", "<esc><cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
map("n", "<C-i>", "<esc><cmd>ToggleTermSendCurrentLine<CR>j", { desc = "Send current line to terminal" })
map("n", "<C-c>", send_current_code_block, { desc = "Send current code block to terminal" })
map("v", "<C-s>", ":'<,'>ToggleTermSendVisualSelection<CR>", { desc = "Send selected lines to terminal" })

-- Code chunk yank keybinding
map("n", "yic", yank_code_chunk, { desc = "Yank code chunk" })
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
map({ 'n', 't' }, "<leader>Th", make_terminal_cmd('horizontal', 15), { desc = "Terminal Horizontal" })
map({ 'n', 't' }, "<leader>Tv", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)),
  { desc = "Terminal Vertical" })
map({ 'n', 't' }, "<leader>Tf", make_terminal_cmd('float'), { desc = "Terminal Float" })

-- Smart toggle: hide visible terminal, otherwise show/create vertical terminal
local function toggle_terminal_vertical_smart()
  -- Ensure commands behave predictably from terminal mode
  if vim.fn.mode() == 't' then
    vim.cmd('stopinsert')
  end

  -- If any terminal window is visible, close just one (hide, do not delete)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
      pcall(vim.api.nvim_win_close, win, true)
      return
    end
  end

  -- No terminal window visible: if a terminal buffer exists, display it vertically
  local existing_terminal_buf = nil
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
      if vim.api.nvim_buf_get_option(buf, 'buftype') == 'terminal' then
        existing_terminal_buf = buf
        break
      end
    end
  end

  if existing_terminal_buf then
    vim.cmd('vsplit')
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(win, existing_terminal_buf)
    vim.cmd('startinsert')
    return
  end

  -- No terminal buffers at all: create a new vertical terminal (default vertical behaviour)
  local size = math.floor(vim.o.columns * 0.3)
  vim.cmd('ToggleTerm direction=vertical size=' .. size)
end

-- Leader mapping: <leader>Tt → Toggle terminal (vertical default)
map({ 'n', 't' }, "<leader>Tt", toggle_terminal_vertical_smart, { desc = "Terminal Toggle (vertical default)" })

-- ============================================================================
-- VIMTEX KEYMAPS
-- ============================================================================
-- VimTeX provides comprehensive default keymaps, but we override them here
-- with cleaner which-key descriptions (VimTeX's plug names include brackets)
-- These map to VimTeX's plug mappings to preserve full functionality

-- Custom LuaLaTeX compilation function with biber
-- Executes: latexmk → biber → latexmk × 2
-- Reuses the same terminal instance for all compilations
local latex_compile_terminal = nil

local function compile_lualatex_with_biber()
	local current_file = vim.fn.expand('%:p')
	if current_file == '' then
		vim.notify("No file is currently open", vim.log.levels.ERROR)
		return
	end

	-- Check if file has .tex extension
	if vim.fn.fnamemodify(current_file, ':e') ~= 'tex' then
		vim.notify("Current file is not a LaTeX file (.tex)", vim.log.levels.ERROR)
		return
	end

	-- Get the directory and basename
	local file_dir = vim.fn.fnamemodify(current_file, ':h')
	local file_base = vim.fn.fnamemodify(current_file, ':t:r')

	-- Build the compilation sequence command
	-- Using && to chain commands so they stop on error
	local cmd = string.format(
		'cd "%s" && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex" && biber "%s" && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex" && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex"',
		file_dir, file_base, file_base, file_base, file_base
	)

	vim.notify("Starting LuaLaTeX compilation: latexmk → biber → latexmk × 2", vim.log.levels.INFO)

	-- Create terminal only once, reuse for subsequent compilations
	if latex_compile_terminal == nil then
		local Terminal = require("toggleterm.terminal").Terminal
		latex_compile_terminal = Terminal:new({
			hidden = true,
			direction = "horizontal",
			size = 15,
			close_on_exit = false,
			on_open = function(term)
				-- Exit insert mode immediately so terminal acts like a normal buffer
				vim.cmd("stopinsert")
				-- Set buffer-local keymaps for convenient terminal management
				local opts = { buffer = term.bufnr, noremap = true, silent = true }
				-- q to close the terminal buffer
				vim.keymap.set('n', 'q', '<cmd>close<CR>', opts)
				-- Ensure normal terminal navigation works
				vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
				vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
				vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
				vim.keymap.set('n', '<C-l>', '<C-w>l', opts)
			end,
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					vim.notify("✓ LuaLaTeX compilation complete", vim.log.levels.INFO)
				else
					vim.notify("✗ LuaLaTeX compilation failed with exit code " .. exit_code, vim.log.levels.ERROR)
				end
			end,
		})
	end

	-- Open the terminal if it's not visible
	if not latex_compile_terminal:is_open() then
		latex_compile_terminal:open()
	end

	-- Send the command to the terminal
	latex_compile_terminal:send(cmd)
end

map("n", "<localleader>ll", "<Plug>(vimtex-compile)", { desc = "Compile" })
map("n", "<localleader>lb", compile_lualatex_with_biber, { desc = "Compile LuaLaTeX+Biber" })
map("n", "<localleader>lv", "<Plug>(vimtex-view)", { desc = "View PDF" })
map("n", "<localleader>lk", "<Plug>(vimtex-stop)", { desc = "Stop" })
map("n", "<localleader>lK", "<Plug>(vimtex-stop-all)", { desc = "Stop all" })
map("n", "<localleader>lc", "<Plug>(vimtex-clean)", { desc = "Clean aux" })
map("n", "<localleader>lC", "<Plug>(vimtex-clean-full)", { desc = "Clean full" })
map("n", "<localleader>le", "<Plug>(vimtex-errors)", { desc = "Errors" })
map("n", "<localleader>lo", "<Plug>(vimtex-compile-output)", { desc = "Output" })
map("n", "<localleader>lg", "<Plug>(vimtex-status)", { desc = "Status" })
map("n", "<localleader>lG", "<Plug>(vimtex-status-all)", { desc = "Status all" })
map("n", "<localleader>lt", "<Plug>(vimtex-toc-open)", { desc = "TOC" })
map("n", "<localleader>lT", "<Plug>(vimtex-toc-toggle)", { desc = "TOC toggle" })
map("n", "<localleader>lq", "<Plug>(vimtex-log)", { desc = "Log" })
map("n", "<localleader>li", "<Plug>(vimtex-info)", { desc = "Info" })
map("n", "<localleader>lI", "<Plug>(vimtex-info-full)", { desc = "Info full" })
map("n", "<localleader>lx", "<Plug>(vimtex-reload)", { desc = "Reload" })
map("n", "<localleader>lX", "<Plug>(vimtex-reload-state)", { desc = "Reload state" })
map("n", "<localleader>la", "<Plug>(vimtex-context-menu)", { desc = "Context menu" })
map("n", "<localleader>lm", "<Plug>(vimtex-imaps-list)", { desc = "Insert mode maps" })

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
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- File operations
map("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>F", "<cmd>Telescope frecency<CR>", { desc = "Find files (by frequency/recency)" })
map("n", "<leader>Ff", "<cmd>Telescope frecency<CR>", { desc = "Find files (frecency)" })
map("n", "<leader>Fr", function()
  require('telescope').extensions.frecency.frecency()
end, { desc = "Refresh frecency database" })
map("n", "<leader>Fd", function()
  print('Frecency DB: ' .. vim.fn.stdpath('data') .. '/telescope-frecency.sqlite3')
end, { desc = "Show frecency database location" })
map("n", "<leader>Fb", function()
  vim.fn.delete(vim.fn.stdpath('data') .. '/telescope-frecency.sqlite3')
  print('Frecency database deleted. Restart Neovim to rebuild.')
end, { desc = "Rebuild frecency database" })

-- Git operations
map("n", "<leader>Gs", safe_cmd("!git status"), { desc = "Git Status" })

-- Grep operations (direct command)
map("n", "<leader>g", function()
  local builtin = require('telescope.builtin')
  -- Prefer Git root if available, otherwise fall back to current working directory
  local cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if not cwd or cwd == '' or cwd:match('fatal:') then
    cwd = vim.loop.cwd() or vim.fn.getcwd()
  end
  builtin.live_grep({ cwd = cwd })
end, { desc = "Grep in project" })

-- Search operations (grep with location options)
map("n", "<leader>Sp", function()
  local builtin = require('telescope.builtin')
  -- Prefer Git root if available, otherwise fall back to current working directory
  local cwd = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if not cwd or cwd == '' or cwd:match('fatal:') then
    cwd = vim.loop.cwd() or vim.fn.getcwd()
  end
  builtin.live_grep({ cwd = cwd })
end, { desc = "Search in project" })

map("n", "<leader>Sw", function()
  local builtin = require('telescope.builtin')
  local cwd = vim.loop.cwd() or vim.fn.getcwd()
  builtin.live_grep({ cwd = cwd })
end, { desc = "Search in working directory" })

map("n", "<leader>Sh", function()
  local builtin = require('telescope.builtin')
  local home = vim.loop.os_homedir() or vim.fn.expand("~")
  builtin.live_grep({ search_dirs = { home } })
end, { desc = "Search in home directory" })

map("n", "<leader>Sc", function()
  local builtin = require('telescope.builtin')
  local config_path = vim.fn.stdpath("config")
  builtin.live_grep({ cwd = config_path })
end, { desc = "Search in config" })

map("n", "<leader>Sf", function()
  local builtin = require('telescope.builtin')
  local current_file = vim.fn.expand('%:p')
  if current_file ~= '' then
    local current_dir = vim.fn.fnamemodify(current_file, ':h')
    builtin.live_grep({ cwd = current_dir })
  else
    builtin.live_grep()
  end
end, { desc = "Search in current file directory" })

map("n", "<leader>Gp", safe_cmd("!git pull"), { desc = "Git Pull" })

map("n", "<leader>Gg", function()
  local lazygit = create_terminal("lazygit", {
    dir = "git_dir", -- open in the Git root for correct repo context
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
local function obsidian_operation(operation_name)
  return function()
    local ok, obsidian = pcall(require, "obsidian")
    if ok and obsidian.util[operation_name] then
      obsidian.util[operation_name]()
    else
      vim.notify("Obsidian operation '" .. operation_name .. "' not available", vim.log.levels.WARN)
    end
  end
end

map("n", "<leader>On", obsidian_operation("new_note"), { desc = "New Obsidian note" })
map("n", "<leader>Ol", obsidian_operation("insert_link"), { desc = "Insert Obsidian link" })
map("n", "<leader>Of", obsidian_operation("follow_link"), { desc = "Follow Obsidian link" })
map("n", "<leader>Oc", obsidian_operation("toggle_checkbox"), { desc = "Toggle Obsidian checkbox" })
map("n", "<leader>Ob", obsidian_operation("show_backlinks"), { desc = "Show Obsidian backlinks" })
map("n", "<leader>Og", obsidian_operation("show_outgoing_links"), { desc = "Show Obsidian outgoing links" })

map("n", "<leader>Oo", function()
  -- Match obsidian.nvim workspace path so file picking uses the same vault
  local obsidian_path = "/Users/s_a_b/Notebook"
  require("telescope.builtin").find_files({
    cwd = obsidian_path,
    prompt_title = "Obsidian Vault"
  })
end, { desc = "Find files in Obsidian vault" })

map("n", "<leader>Ot", safe_cmd("ObsidianTemplate"), { desc = "Insert Obsidian template" })
map("n", "<leader>ON", safe_cmd("ObsidianNewFromTemplate"), { desc = "New note from template" })

-- Helper to paste an image into the Obsidian vault and insert a wiki link
local function paste_obsidian_image()
  -- Try obsidian.nvim's own mechanisms first, to benefit from its attachment handling
  local used_obsidian = false

  if vim.fn.exists(":ObsidianPasteImg") == 2 then
    local ok = pcall(vim.cmd, "ObsidianPasteImg")
    if ok then
      used_obsidian = true
    end
  else
    local ok, obsidian = pcall(require, "obsidian")
    if ok then
      if obsidian.util and type(obsidian.util) == "table" then
        if type(obsidian.util.paste_img_and_link) == "function" then
          pcall(obsidian.util.paste_img_and_link)
          used_obsidian = true
        elseif type(obsidian.util.paste_img) == "function" then
          pcall(obsidian.util.paste_img)
          used_obsidian = true
        end
      end
      if (not used_obsidian) and obsidian.commands and type(obsidian.commands) == "table" then
        if type(obsidian.commands.paste_img) == "function" then
          pcall(obsidian.commands.paste_img)
          used_obsidian = true
        end
      end
    end
  end

  if used_obsidian then
    -- Add two blank lines for spacing after whatever text Obsidian inserted
    vim.cmd("put =''")
    vim.cmd("put =''")
    return
  end

  -- Fallback: handle clipboard image ourselves using pngpaste (macOS)
  -- This assumes pngpaste is installed and the clipboard contains an image.
  -- Match obsidian.nvim workspace path so images are saved in the same vault
  local vault_path = "/Users/s_a_b/Notebook"
  local attachments_dir = vault_path .. "/attachments"

  -- Ensure attachments directory exists
  vim.fn.mkdir(attachments_dir, "p")

  -- Build filename using the same timestamp pattern as obsidian.nvim config
  local filename = os.date("%Y%m%d-%H%M%S") .. ".png"
  local fullpath = attachments_dir .. "/" .. filename

  -- Save clipboard image to file
  local cmd = string.format('pngpaste "%s"', fullpath)
  vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Failed to paste image: pngpaste not available or clipboard is not an image", vim.log.levels.ERROR)
    return
  end

  -- Insert markdown image link using the same relative pattern as obsidian.nvim's img_text_func:
  -- note in "notes" folder → image in "../attachments/<filename>"
  local link_line = string.format("![%s](<../attachments/%s>)", filename, filename)
  vim.api.nvim_put({ link_line, "", "" }, "l", true, true)
end

map("n", "<leader>Op", paste_obsidian_image, { desc = "Paste image and add two lines" })

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
local function quarto_operation(operation_name)
  return function()
    local ok, quarto = pcall(require, "quarto")
    if ok and quarto[operation_name] then
      quarto[operation_name]()
    else
      vim.notify("Quarto operation '" .. operation_name .. "' not available", vim.log.levels.WARN)
    end
  end
end

-- Helper function to render Quarto documents to specific formats
local function quarto_render_to_format(format, format_name)
  return function()
    local file = vim.fn.expand("%:p")
    if file == "" then
      vim.notify("No file to render", vim.log.levels.WARN)
      return
    end
    vim.notify("Rendering " .. vim.fn.expand("%:t") .. " to " .. format_name .. "...", vim.log.levels.INFO)
    
    -- Build command with PDF-specific options
    local cmd = {"quarto", "render", file, "--to", format}
    if format == "pdf" then
      -- Add non-stop mode for LaTeX compilation
      -- Pass via --pdf-engine-opt (Pandoc flag)
      table.insert(cmd, "--pdf-engine-opt=-interaction=nonstopmode")
    end
    
    -- Set environment to ensure non-interactive execution
    local current_env = vim.fn.environ()
    local job_opts = {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify("✓ " .. format_name .. " render complete: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
        else
          vim.notify("✗ " .. format_name .. " render failed with exit code " .. exit_code, vim.log.levels.ERROR)
        end
      end,
      on_stderr = function(_, data)
        if data and #data > 0 then
          for _, line in ipairs(data) do
            if line ~= "" then
              print(line)
            end
          end
        end
      end,
      -- Set up environment for non-interactive execution
      env = {},
    }
    
    -- Copy existing environment
    for k, v in pairs(current_env) do
      job_opts.env[k] = v
    end
    
    -- Set environment variables for non-interactive execution
    -- Make Julia run in non-interactive/batch mode
    job_opts.env["JULIA_NUM_THREADS"] = job_opts.env["JULIA_NUM_THREADS"] or "1"
    -- Prevent Julia from prompting (set to empty or no)
    job_opts.env["JULIA_INTERACTIVE"] = "no"
    -- Set TERM to prevent interactive prompts
    job_opts.env["TERM"] = "dumb"
    -- Ensure non-interactive mode
    job_opts.env["NONINTERACTIVE"] = "1"
    -- Disable paging (prevents "Press ENTER" prompts from less/more)
    job_opts.env["PAGER"] = "cat"
    job_opts.env["MANPAGER"] = "cat"
    job_opts.env["LESS"] = "-R"  -- Raw control chars, but no paging
    job_opts.env["MORE"] = "-R"
    
    -- Add environment variable for latexmk if rendering to PDF
    if format == "pdf" then
      -- Set LATEXMKOPTS to ensure non-stop mode for all LaTeX passes
      local latexmkopts = current_env["LATEXMKOPTS"] or ""
      if latexmkopts ~= "" then
        job_opts.env["LATEXMKOPTS"] = latexmkopts .. " -interaction=nonstopmode"
      else
        job_opts.env["LATEXMKOPTS"] = "-interaction=nonstopmode"
      end
    end
    
    -- Execute command directly with environment variables set
    -- The pager environment variables (PAGER=cat, etc.) will prevent paging
    -- Stdin redirection is handled by jobstart's default behavior
    vim.fn.jobstart(cmd, job_opts)
  end
end

map("n", "<leader>Qp", quarto_operation("quartoPreview"), { desc = "Quarto Preview" })
map("n", "<leader>Qc", quarto_operation("quartoClosePreview"), { desc = "Close preview" })

-- Function to render all files in the project
local function quarto_render_all()
  vim.notify("Rendering all files in project...", vim.log.levels.INFO)
  
  -- Build command to render all files (no file specified = render all)
  local cmd = {"quarto", "render"}
  
  -- Set environment to ensure non-interactive execution
  local current_env = vim.fn.environ()
  local job_opts = {
    on_exit = function(_, exit_code)
      if exit_code == 0 then
        vim.notify("✓ Render all complete", vim.log.levels.INFO)
      else
        vim.notify("✗ Render all failed with exit code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line ~= "" then
            print(line)
          end
        end
      end
    end,
    env = {},
  }
  
  -- Copy existing environment
  for k, v in pairs(current_env) do
    job_opts.env[k] = v
  end
  
  -- Set environment variables for non-interactive execution
  job_opts.env["JULIA_NUM_THREADS"] = job_opts.env["JULIA_NUM_THREADS"] or "1"
  job_opts.env["JULIA_INTERACTIVE"] = "no"
  job_opts.env["TERM"] = "dumb"
  job_opts.env["NONINTERACTIVE"] = "1"
  -- Disable paging (prevents "Press ENTER" prompts from less/more)
  job_opts.env["PAGER"] = "cat"
  job_opts.env["MANPAGER"] = "cat"
  job_opts.env["LESS"] = "-R"
  job_opts.env["MORE"] = "-R"
  
  vim.fn.jobstart(cmd, job_opts)
end

-- Format-specific render commands
map("n", "<leader>QRh", quarto_render_to_format("html", "HTML"), { desc = "Render to HTML" })
map("n", "<leader>QRp", quarto_render_to_format("pdf", "PDF"), { desc = "Render to PDF" })
map("n", "<leader>QRw", quarto_render_to_format("docx", "Word"), { desc = "Render to Word" })
map("n", "<leader>QRa", quarto_render_all, { desc = "Render all" })

-- Molten keymaps
local molten_commands = {
  ["<leader>QMi"] = { cmd = "MoltenImagePopup", desc = "Show Image Popup" },
  ["<leader>QMl"] = { cmd = "MoltenEvaluateLine", desc = "Evaluate Line" },
  ["<leader>QMe"] = { cmd = "MoltenEvaluateOperator", desc = "Evaluate Operator" },
  ["<leader>QMn"] = { cmd = "MoltenInit", desc = "Initialise Kernel" },
  ["<leader>QMk"] = { cmd = "MoltenDeinit", desc = "Stop Kernel" },
  ["<leader>QMr"] = { cmd = "MoltenRestart", desc = "Restart Kernel" },
  ["<leader>QMo"] = { cmd = "MoltenEvaluateOperator", desc = "Evaluate Operator" },
  ["<leader>QM<CR>"] = { cmd = "MoltenEvaluateLine", desc = "Evaluate Line" },
  ["<leader>QMv"] = { cmd = "MoltenEvaluateVisual", desc = "Evaluate Visual" },
  ["<leader>QMf"] = { cmd = "MoltenReevaluateCell", desc = "Re-evaluate Cell" },
  ["<leader>QMh"] = { cmd = "MoltenHideOutput", desc = "Hide Output" },
  ["<leader>QMs"] = { cmd = "MoltenShowOutput", desc = "Show Output" },
  ["<leader>QMd"] = { cmd = "MoltenDelete", desc = "Delete Cell" },
  ["<leader>QMb"] = { cmd = "MoltenOpenInBrowser", desc = "Open in Browser" },
}

for key, data in pairs(molten_commands) do
  map("n", key, safe_cmd(data.cmd), { desc = data.desc })
end

-- Toggle options (these were missing from the moved keymaps)
map("n", "<leader>Ys", "<cmd>set spell!<CR>", { desc = "Toggle Spell Check" })
map("n", "<leader>Yse", function()
  local config_dir = vim.fn.stdpath('config')
  vim.cmd("set nospell")  -- Disable first to clear spell cache
  vim.opt.spellfile = config_dir .. '/private/spell/en.utf-8.add'
  vim.cmd("set spelllang=en_gb")
  vim.cmd("set spell")  -- Re-enable with new language
  vim.notify("Spell language: English (British)", vim.log.levels.INFO)
end, { desc = "Set spell language to English (British)" })
map("n", "<leader>Ysf", function()
  local config_dir = vim.fn.stdpath('config')
  vim.cmd("set nospell")  -- Disable first to clear spell cache
  vim.opt.spellfile = config_dir .. '/private/spell/fr.utf-8.add'
  vim.cmd("set spelllang=fr")
  vim.cmd("set spell")  -- Re-enable with new language
  vim.notify("Spell language: French", vim.log.levels.INFO)
end, { desc = "Set spell language to French" })

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
  local project_path = vim.fn.shellescape(vim.fn.getcwd())
  local julia_repl = create_terminal("julia --project=" .. project_path .. " --threads=auto", {
    direction = direction,
  })
  julia_repl:toggle()
end

-- Julia command execution helper
local function julia_command(command, desc)
  return function()
    local project_path = vim.fn.shellescape(vim.fn.getcwd())
    local julia_cmd = "julia --project=. --threads=auto" .. project_path .. " -e '" .. command .. "'"
    local terminal = create_terminal(julia_cmd, { direction = "horizontal" })
    terminal:toggle()
  end
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

map("n", "<leader>Jp", julia_command("using Pkg; Pkg.status()", "Project Status"), { desc = "Project Status" })
map("n", "<leader>Ji", julia_command("using Pkg; Pkg.instantiate()", "Instantiate Project"), { desc = "Instantiate Project" })
map("n", "<leader>Ju", julia_command("using Pkg; Pkg.update()", "Update Project"), { desc = "Update Project" })
map("n", "<leader>Jt", julia_command("using Pkg; Pkg.test()", "Run Tests"), { desc = "Run Tests" })
map("n", "<leader>Jd", julia_command("using Pkg; using Documenter; makedocs()", "Generate Docs"), { desc = "Generate Docs" })

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
map("n", "<leader>CUa", function() call_plugin_manager("update_all_plugins") end, { desc = "Update All Plugins" })
map("n", "<leader>CUs", function() call_plugin_manager("show_status") end, { desc = "Plugin Status" })
map("n", "<leader>CUc", function() call_plugin_manager("cleanup_orphaned") end, { desc = "Cleanup Orphaned Plugins" })

