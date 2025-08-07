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

-- Buffer navigation (from LunarVim) - fallback if BufferLine not available
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
-- Leader-based shortcuts following LunarVim conventions
-- These provide structured access to most common operations via <Space> prefix
-- Organised into logical groups: files, buffers, search, LSP, git, etc.

-- Core single-key operations (LunarVim style)
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

-- Colourscheme cycling function
local colorschemes = { "catppuccin", "onedark", "tokyonight", "nord", "github_dark" }
local current_scheme_index = 1

local function cycle_colorscheme()
  current_scheme_index = current_scheme_index % #colorschemes + 1
  local scheme = colorschemes[current_scheme_index]

  -- Try to set the colourscheme with fallback
  local success = pcall(vim.cmd.colorscheme, scheme)
  if not success then
    -- If scheme fails, try with fallback names
    local fallback_schemes = {
      catppuccin = "catppuccin-mocha",
      github_dark = "github_dark",
    }
    local fallback = fallback_schemes[scheme]
    if fallback then
      success = pcall(vim.cmd.colorscheme, fallback)
    end
  end

  if success then
    print("Switched to " .. scheme .. " theme")
  else
    print("Failed to switch to " .. scheme .. " theme")
    -- Move to next scheme on failure
    cycle_colorscheme()
  end
end

map("n", "<leader>Yc", cycle_colorscheme, { desc = "Toggle colourscheme" })



-- ============================================================================
-- TERMINAL INTEGRATION (from LunarVim)
-- ============================================================================
-- Advanced terminal integration for code execution and data science workflows
-- Provides smart code block detection and execution for R Markdown/Quarto
-- Key mappings: Ctrl+t (toggle), Ctrl+i (send line), Ctrl+c (send block)

-- Function to select and send current code block in R Markdown/Quarto (from LunarVim)
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

-- Terminal keybindings (exactly matching LunarVim)
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
map({'n', 't'}, "<A-1>", make_terminal_cmd('horizontal', 15), { desc = "Horizontal Terminal (15 lines)" })
map({'n', 't'}, "<A-2>", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)), { desc = "Vertical Terminal (30%)" })
map({'n', 't'}, "<A-3>", make_terminal_cmd('float'), { desc = "Float Terminal" })

-- Alternative Meta notation for macOS (sometimes works better)
map({'n', 't'}, "<M-1>", make_terminal_cmd('horizontal', 15), { desc = "Horizontal Terminal (15 lines, Meta)" })
map({'n', 't'}, "<M-2>", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)), { desc = "Vertical Terminal (30%, Meta)" })
map({'n', 't'}, "<M-3>", make_terminal_cmd('float'), { desc = "Float Terminal (Meta)" })

-- Leader-based alternatives as backup (using T for Terminal group)
map({'n', 't'}, "<leader>T1", make_terminal_cmd('horizontal', 15), { desc = "Terminal Horizontal" })
map({'n', 't'}, "<leader>T2", make_terminal_cmd('vertical', math.floor(vim.o.columns * 0.3)), { desc = "Terminal Vertical" })
map({'n', 't'}, "<leader>T3", make_terminal_cmd('float'), { desc = "Terminal Float" })

-- ============================================================================
-- VIMTEX KEYMAPS
-- ============================================================================
-- VimTeX integration keymaps for LaTeX document processing
-- These provide forward/inverse search and compilation control
-- Using LocalLeader prefix to avoid conflicts with main leader bindings

-- Function to set up VimTeX keymaps after VimTeX is loaded
local function setup_vimtex_keymaps()
  map("n", "<LocalLeader>lv", ":VimtexView<CR>", { noremap = true, silent = true, desc = "View (forward sync)" })
  map("n", "<LocalLeader>li", ":VimtexInverseSearch<CR>", { noremap = true, silent = true, desc = "Inverse search" })
  map("n", "<LocalLeader>ll", ":VimtexCompile<CR>", { noremap = true, silent = true, desc = "Compile (latexmk)" })
  map("n", "<LocalLeader>lc", ":VimtexClean<CR>", { noremap = true, silent = true, desc = "Clean aux files" })
  map("n", "<LocalLeader>lS", ":VimtexStop<CR>", { noremap = true, silent = true, desc = "Stop compiler" })
end

-- Autocmd group for VimTeX keymaps
local vimtex_augroup = vim.api.nvim_create_augroup('VimTexKeymaps', { clear = true })

-- Set up keymaps when opening TeX files (ensures VimTeX is initialised)
vim.api.nvim_create_autocmd('FileType', {
    group = vimtex_augroup,
    pattern = 'tex',
    callback = function()
        -- Small delay to ensure VimTeX is fully initialised
        vim.defer_fn(function()
            setup_vimtex_keymaps()
        end, 100)
    end,
})

-- Alternative trigger when VimTeX finishes initialisation
vim.api.nvim_create_autocmd('User', {
    group = vimtex_augroup,
    pattern = 'VimtexEventInitPost',
    callback = function()
        setup_vimtex_keymaps()
    end,
})
