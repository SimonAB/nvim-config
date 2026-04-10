-- Plugin Key Mappings
-- Purpose: All plugin-dependent mappings and helper functions (loaded after plugins)

-- This module intentionally contains everything that may require plugins.
-- Core, plugin-independent mappings live in `keymaps-core.lua`.
--
-- Maintenance notes:
-- - Prefer `pcall(require, ...)` for optional plugins to avoid hard startup failures.
-- - If a mapping can be expressed without plugins, put it in `keymaps-core.lua`.
-- - If you want even tighter lazy-loading, split this file further into per-plugin keymap
--   modules and load them in the same phase as their plugin.

local map = vim.keymap.set

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function safe_cmd(cmd)
	return function()
		local success, err = pcall(vim.cmd, cmd)
		if not success then
			vim.notify("Command failed: " .. (err or "unknown error"), vim.log.levels.ERROR)
		end
	end
end

---Return the Obsidian vault path from obsidian.nvim config if available.
---@return string|nil
local function get_obsidian_vault_path()
	local ok, obsidian = pcall(require, "obsidian")
	if not ok then
		return nil
	end
	if not obsidian.config then
		return nil
	end
	local workspaces = obsidian.config.workspaces
	if type(workspaces) ~= "table" then
		return nil
	end
	local workspace = workspaces[1]
	if type(workspace) ~= "table" then
		return nil
	end
	if type(workspace.path) ~= "string" then
		return nil
	end
	return workspace.path
end

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

-- VimTeX: custom LuaLaTeX compilation with biber
-- Executes: latexmk → biber → latexmk × 2
-- Reuses a single terminal instance for subsequent compilations.
local latex_compile_terminal = nil

---Compile the current .tex file using LuaLaTeX + biber.
local function compile_lualatex_with_biber()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No file is currently open", vim.log.levels.ERROR)
		return
	end

	if vim.fn.fnamemodify(current_file, ":e") ~= "tex" then
		vim.notify("Current file is not a LaTeX file (.tex)", vim.log.levels.ERROR)
		return
	end

	local file_dir = vim.fn.fnamemodify(current_file, ":h")
	local file_base = vim.fn.fnamemodify(current_file, ":t:r")

	local cmd = string.format(
		'cd "%s"'
			.. ' && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex"'
			.. ' && biber "%s"'
			.. ' && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex"'
			.. ' && latexmk -pdf -pdflatex=lualatex -synctex=1 -interaction=nonstopmode -file-line-error "%s.tex"',
		file_dir,
		file_base,
		file_base,
		file_base,
		file_base
	)

	vim.notify("Starting LuaLaTeX compilation: latexmk → biber → latexmk × 2", vim.log.levels.INFO)

	if latex_compile_terminal == nil then
		local Terminal = require("toggleterm.terminal").Terminal
		latex_compile_terminal = Terminal:new({
			hidden = true,
			direction = "horizontal",
			size = 15,
			close_on_exit = false,
			on_open = function(term)
				vim.cmd("stopinsert")
				local opts = { buffer = term.bufnr, noremap = true, silent = true }
				vim.keymap.set("n", "q", "<cmd>close<CR>", opts)
				vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
				vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
				vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
				vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
			end,
			on_exit = function(_, exit_code)
				if exit_code == 0 then
					vim.notify("✓ LuaLaTeX compilation complete", vim.log.levels.INFO)
				else
					vim.notify("✗ LuaLaTeX compilation failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
				end
			end,
		})
	end

	if not latex_compile_terminal:is_open() then
		latex_compile_terminal:open()
	end

	latex_compile_terminal:send(cmd)
end

---Return a best-effort Git root, falling back to the current working directory.
---@return string
local function get_project_root()
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if not git_root or git_root == "" or git_root:match("fatal:") then
		return vim.loop.cwd() or vim.fn.getcwd()
	end
	return git_root
end

local function buffer_operation(bufferline_cmd, fallback_cmd)
	return function()
		local success = pcall(vim.cmd, bufferline_cmd)
		if not success then
			vim.cmd(fallback_cmd)
		end
	end
end

local function toggle_zen_mode()
	local ok, zen_mode = pcall(require, "zen-mode")
	if not ok then
		vim.notify("zen-mode.nvim not available", vim.log.levels.WARN)
		return
	end
	zen_mode.toggle()
end

---Safely call an obsidian.nvim util operation if available.
---@param operation_name string
---@return fun()
local function obsidian_operation(operation_name)
	return function()
		local ok, obsidian = pcall(require, "obsidian")
		if ok and obsidian.util and obsidian.util[operation_name] then
			obsidian.util[operation_name]()
			return
		end
		vim.notify("Obsidian operation '" .. operation_name .. "' not available", vim.log.levels.WARN)
	end
end

---Paste an image into the Obsidian vault and insert a link, then add two blank lines.
---Prefers obsidian.nvim's own paste command/utilities; falls back to pngpaste on macOS.
local function paste_obsidian_image()
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
		vim.cmd("put =''")
		vim.cmd("put =''")
		return
	end

	local vault_path = get_obsidian_vault_path()
	if not vault_path then
		vim.notify("Obsidian vault path not available", vim.log.levels.ERROR)
		return
	end

	local attachments_dir = vault_path .. "/attachments"
	vim.fn.mkdir(attachments_dir, "p")

	local filename = os.date("%Y%m%d-%H%M%S") .. ".png"
	local fullpath = attachments_dir .. "/" .. filename

	local cmd = string.format('pngpaste "%s"', fullpath)
	vim.fn.system(cmd)
	if vim.v.shell_error ~= 0 then
		vim.notify(
			"Failed to paste image: pngpaste not available or clipboard is not an image",
			vim.log.levels.ERROR
		)
		return
	end

	local link_line = string.format("![%s](<../attachments/%s>)", filename, filename)
	vim.api.nvim_put({ link_line, "", "" }, "l", true, true)
end

---Safely call a quarto-nvim operation if available.
---@param operation_name string
---@return fun()
local function quarto_operation(operation_name)
	return function()
		local ok, quarto = pcall(require, "quarto")
		if ok and quarto[operation_name] then
			quarto[operation_name]()
			return
		end
		vim.notify("Quarto operation '" .. operation_name .. "' not available", vim.log.levels.WARN)
	end
end

---Build jobstart options for non-interactive Quarto renders.
---@param format_name string
---@return table
local function build_quarto_job_opts(format_name)
	return {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("✓ " .. format_name .. " render complete", vim.log.levels.INFO)
			else
				vim.notify("✗ " .. format_name .. " render failed (exit " .. exit_code .. ")", vim.log.levels.ERROR)
			end
		end,
		on_stderr = function(_, data)
			if not data or #data == 0 then
				return
			end
			for _, line in ipairs(data) do
				if line ~= "" then
					print(line)
				end
			end
		end,
		env = {
			TERM = "dumb",
			NONINTERACTIVE = "1",
			PAGER = "cat",
			MANPAGER = "cat",
			LESS = "-R",
			MORE = "-R",
		},
	}
end

---Render the current Quarto document to a specific format.
---@param format string
---@param format_name string
---@return fun()
local function quarto_render_to_format(format, format_name)
	return function()
		local file = vim.fn.expand("%:p")
		if file == "" then
			vim.notify("No file to render", vim.log.levels.WARN)
			return
		end

		local cmd = { "quarto", "render", file, "--to", format }
		if format == "pdf" then
			table.insert(cmd, "--pdf-engine-opt=-interaction=nonstopmode")
		end

		vim.notify("Rendering to " .. format_name .. "...", vim.log.levels.INFO)
		vim.fn.jobstart(cmd, build_quarto_job_opts(format_name))
	end
end

---Render all Quarto documents in the current project.
local function quarto_render_all()
	vim.notify("Rendering all files in project...", vim.log.levels.INFO)
	vim.fn.jobstart({ "quarto", "render" }, build_quarto_job_opts("Project"))
end

---Toggle a vertical terminal: hide if visible, otherwise show/create.
local function toggle_terminal_vertical_smart()
	if vim.fn.mode() == "t" then
		vim.cmd("stopinsert")
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
			pcall(vim.api.nvim_win_close, win, true)
			return
		end
	end

	local existing_terminal_buf = nil
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
			if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
				existing_terminal_buf = buf
				break
			end
		end
	end

	if existing_terminal_buf then
		vim.cmd("vsplit")
		local win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(win, existing_terminal_buf)
		vim.cmd("startinsert")
		return
	end

	local size = math.floor(vim.o.columns * 0.3)
	vim.cmd("ToggleTerm direction=vertical size=" .. size)
end

---Clear the first visible terminal buffer (or current one if already in terminal).
local function clear_terminal()
	local current_win = vim.api.nvim_get_current_win()
	local terminal_win = nil
	local terminal_buf = nil

	if vim.bo.buftype == "terminal" then
		terminal_win = current_win
		terminal_buf = vim.api.nvim_get_current_buf()
	else
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
				terminal_win = win
				terminal_buf = buf
				break
			end
		end
	end

	if not (terminal_win and terminal_buf) then
		print("No terminal window found - open a terminal first")
		return
	end

	local original_win = vim.api.nvim_get_current_win()
	vim.api.nvim_set_current_win(terminal_win)
	vim.cmd("startinsert")
	vim.api.nvim_feedkeys("clear", "t", false)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "t", false)

	if original_win ~= terminal_win then
		vim.schedule(function()
			pcall(vim.api.nvim_set_current_win, original_win)
		end)
	end
	print("Terminal cleared")
end

---Kill the first visible terminal buffer (or current one if already in terminal).
local function kill_terminal()
	local terminal_buf = nil

	if vim.bo.buftype == "terminal" then
		terminal_buf = vim.api.nvim_get_current_buf()
	else
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.api.nvim_buf_get_option(buf, "buftype") == "terminal" then
				terminal_buf = buf
				break
			end
		end
	end

	if not terminal_buf then
		print("No terminal window found")
		return
	end

	vim.api.nvim_buf_delete(terminal_buf, { force = true })
	print("Terminal killed")
end

---Open a Julia REPL in a ToggleTerm window.
---@param direction "horizontal"|"vertical"|"float"
local function open_julia_repl(direction)
	local project_path = vim.fn.shellescape(vim.fn.getcwd())
	local julia_repl = create_terminal("julia --project=" .. project_path .. " --threads=auto", {
		direction = direction,
	})
	julia_repl:toggle()
end

---Run a Julia command in a terminal using the current project.
---@param command string
---@return fun()
local function julia_command(command)
	return function()
		local project_path = vim.fn.shellescape(vim.fn.getcwd())
		local julia_cmd = "julia --project=" .. project_path .. " --threads=auto -e '" .. command .. "'"
		local terminal = create_terminal(julia_cmd, { direction = "horizontal", close_on_exit = false })
		terminal:toggle()
	end
end

---Compile the current Typst file to PDF using the CLI (`typst c`).
local function typst_compile_current()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No file is currently open", vim.log.levels.ERROR)
		return
	end

	if vim.fn.fnamemodify(current_file, ":e") ~= "typ" then
		vim.notify("Current file is not a Typst file (.typ)", vim.log.levels.ERROR)
		return
	end

	local cmd = string.format('typst c "%s"', current_file)

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
		end,
	})
end

---Open ToggleTerm with `typst w` for the current Typst file.
local function typst_watch_current()
	local current_file = vim.fn.expand("%:p")
	if current_file == "" then
		vim.notify("No file is currently open", vim.log.levels.ERROR)
		return
	end

	if vim.fn.fnamemodify(current_file, ":e") ~= "typ" then
		vim.notify("Current file is not a Typst file (.typ)", vim.log.levels.ERROR)
		return
	end

	local cmd = string.format('typst w "%s"', current_file)

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
end

-- ============================================================================
-- PLUGIN-DEPENDENT KEYMAPS
-- ============================================================================

local filetype_keymaps_group = vim.api.nvim_create_augroup("FiletypeKeymaps", { clear = true })

-- Buffer Operations (<leader>B)
map("n", "<leader>Bf", "<cmd>Telescope buffers<CR>", { desc = "Find buffers (Telescope)" })
map("n", "<leader>Bp", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
map("n", "<leader>Bb", buffer_operation("BufferLineCyclePrev", "bprevious"), { desc = "Previous buffer" })
map("n", "<leader>Bn", buffer_operation("BufferLineCycleNext", "bnext"), { desc = "Next buffer" })
map("n", "<leader>Bq", buffer_operation("BufferLineClose", "bdelete"), { desc = "Close buffer" })
map("n", "<leader>Bl", "<cmd>ls!<CR>", { desc = "List all buffers (including unlisted)" })

-- Toggle Zen Mode
map("n", "<leader>z", toggle_zen_mode, { desc = "Toggle Zen Mode" })
map("n", "<leader>Yz", toggle_zen_mode, { desc = "Toggle Zen Mode" })

-- Theme management (deferred)
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

map("n", "<leader>Yc", cycle_colorscheme, { desc = "Cycle themes" })
map("n", "<leader>YTp", show_theme_picker, { desc = "Theme picker" })
map("n", "<leader>YTs", function()
	local current = vim.g.colors_name or "default"
	vim.notify("Current theme: " .. current, vim.log.levels.INFO)
end, { desc = "Show current theme" })

-- File tree / Telescope / Search
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<leader>f", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>R", "<cmd>Telescope frecency<CR>", { desc = "Find files (by frequency/recency)" })
map("n", "<leader>Rf", "<cmd>Telescope frecency<CR>", { desc = "Find files (frecency)" })
map("n", "<leader>Rr", function()
	require("telescope").extensions.frecency.frecency()
end, { desc = "Refresh frecency database" })
map("n", "<leader>Rd", function()
	local db_root = vim.fn.stdpath("state")
	print("Frecency DB root: " .. db_root)
	print("  - " .. db_root .. "/file_frecency.bin")
	print("  - " .. db_root .. "/file_frecency_v2.bin")
end, { desc = "Show frecency database location" })
map("n", "<leader>Rb", function()
	local db_root = vim.fn.stdpath("state")
	vim.fn.delete(db_root .. "/file_frecency.bin")
	vim.fn.delete(db_root .. "/file_frecency_v2.bin")
	vim.fn.delete(db_root .. "/file_frecency.bin.lock")
	vim.fn.delete(db_root .. "/file_frecency_v2.bin.lock")
	print("Frecency database deleted. It will rebuild as you use it.")
end, { desc = "Rebuild frecency database" })

-- Git
map("n", "<leader>Gs", safe_cmd("!git status"), { desc = "Git Status" })
map("n", "<leader>Gp", safe_cmd("!git pull"), { desc = "Git Pull" })

map("n", "<leader>Gg", function()
	local lazygit = create_terminal("lazygit", {
		dir = "git_dir",
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
		env = {
			TERM = "xterm-256color",
			COLORTERM = "truecolor",
			EDITOR = "nvim --clean",
			GIT_EDITOR = "nvim --clean",
			NVIM = "",
			NVIM_LISTEN_ADDRESS = "",
		},
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.keymap.set("t", "<esc>", "<esc>", { buffer = term.bufnr })
		end,
		on_close = function()
			vim.cmd("stopinsert")
		end,
	})
	lazygit:toggle()
end, { desc = "LazyGit" })

-- Terminal
map({ "n", "t" }, "<leader>Tt", toggle_terminal_vertical_smart, { desc = "Toggle terminal (vertical)" })
map({ "n", "t" }, "<leader>Th", function()
	vim.cmd("ToggleTerm direction=horizontal size=15")
end, { desc = "Terminal horizontal" })
map({ "n", "t" }, "<leader>Tv", function()
	local size = math.floor(vim.o.columns * 0.3)
	vim.cmd("ToggleTerm direction=vertical size=" .. size)
end, { desc = "Terminal vertical" })
map({ "n", "t" }, "<leader>Tf", function()
	vim.cmd("ToggleTerm direction=float")
end, { desc = "Terminal float" })
map("n", "<leader>Tk", clear_terminal, { desc = "Clear terminal" })
map("n", "<leader>Td", kill_terminal, { desc = "Kill terminal" })

-- Search (Telescope)
map("n", "<leader>g", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	builtin.live_grep({ cwd = get_project_root() })
end, { desc = "Grep in project" })

map("n", "<leader>Sp", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	builtin.live_grep({ cwd = get_project_root() })
end, { desc = "Search in project" })

map("n", "<leader>Sw", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	builtin.live_grep({ cwd = vim.loop.cwd() or vim.fn.getcwd() })
end, { desc = "Search in working directory" })

map("n", "<leader>Sh", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	local home = vim.loop.os_homedir() or vim.fn.expand("~")
	builtin.live_grep({ search_dirs = { home } })
end, { desc = "Search in home directory" })

map("n", "<leader>Sc", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	builtin.live_grep({ cwd = vim.fn.stdpath("config") })
end, { desc = "Search in config" })

map("n", "<leader>Sf", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end

	local current_file = vim.fn.expand("%:p")
	if current_file ~= "" then
		local current_dir = vim.fn.fnamemodify(current_file, ":h")
		builtin.live_grep({ cwd = current_dir })
	else
		builtin.live_grep()
	end
end, { desc = "Search in current file directory" })

-- Config (Telescope)
map("n", "<leader>Cf", function()
	local config_path = vim.fn.stdpath("config")
	vim.cmd("Telescope find_files cwd=" .. config_path)
end, { desc = "Find config files" })

map("n", "<leader>Cg", function()
	local ok, builtin = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end
	builtin.live_grep({ cwd = vim.fn.stdpath("config") })
end, { desc = "Grep config files" })

-- Trouble diagnostics
map("n", "<leader>Xw", ":TroubleToggle workspace_diagnostics<CR>", { desc = "Workspace Diagnostics" })
map("n", "<leader>Xd", ":TroubleToggle document_diagnostics<CR>", { desc = "Document Diagnostics" })
map("n", "<leader>Xl", ":TroubleToggle loclist<CR>", { desc = "Location List" })
map("n", "<leader>Xq", ":TroubleToggle quickfix<CR>", { desc = "Quickfix" })

-- Mason
map("n", "<leader>Mm", "<cmd>Mason<CR>", { desc = "Open Mason" })
map("n", "<leader>Mi", "<cmd>MasonInstall<CR>", { desc = "Install Package" })
map("n", "<leader>Mu", "<cmd>MasonUninstall<CR>", { desc = "Uninstall Package" })
map("n", "<leader>Ml", "<cmd>MasonLog<CR>", { desc = "View Mason Log" })
map("n", "<leader>Mh", "<cmd>MasonHelp<CR>", { desc = "Mason Help" })

map("n", "<leader>Lm", "<cmd>Mason<CR>", { desc = "LSP: Open Mason" })

-- Markdown preview
map("n", "<leader>Kp", "<cmd>MarkdownPreview<CR>", { desc = "Start Markdown Preview" })
map("n", "<leader>Ks", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview" })
map("n", "<leader>Kv", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })

-- Quarto
map("n", "<leader>Qp", quarto_operation("quartoPreview"), { desc = "Quarto preview" })
map("n", "<leader>Qc", quarto_operation("quartoClosePreview"), { desc = "Close Quarto preview" })
map("n", "<leader>QRh", quarto_render_to_format("html", "HTML"), { desc = "Render to HTML" })
map("n", "<leader>QRp", quarto_render_to_format("pdf", "PDF"), { desc = "Render to PDF" })
map("n", "<leader>QRw", quarto_render_to_format("docx", "Word"), { desc = "Render to Word" })
map("n", "<leader>QRa", quarto_render_all, { desc = "Render all" })

-- Molten
local molten_commands = {
	["<leader>QMi"] = { cmd = "MoltenImagePopup", desc = "Show image popup" },
	["<leader>QMl"] = { cmd = "MoltenEvaluateLine", desc = "Evaluate line" },
	["<leader>QMe"] = { cmd = "MoltenEvaluateOperator", desc = "Evaluate operator" },
	["<leader>QMn"] = { cmd = "MoltenInit", desc = "Initialise kernel" },
	["<leader>QMk"] = { cmd = "MoltenDeinit", desc = "Stop kernel" },
	["<leader>QMr"] = { cmd = "MoltenRestart", desc = "Restart kernel" },
	["<leader>QMo"] = { cmd = "MoltenEvaluateOperator", desc = "Evaluate operator" },
	["<leader>QM<CR>"] = { cmd = "MoltenEvaluateLine", desc = "Evaluate line" },
	["<leader>QMv"] = { cmd = "MoltenEvaluateVisual", desc = "Evaluate visual selection" },
	["<leader>QMf"] = { cmd = "MoltenReevaluateCell", desc = "Re-evaluate cell" },
	["<leader>QMh"] = { cmd = "MoltenHideOutput", desc = "Hide output" },
	["<leader>QMs"] = { cmd = "MoltenShowOutput", desc = "Show output" },
	["<leader>QMd"] = { cmd = "MoltenDelete", desc = "Delete cell" },
	["<leader>QMb"] = { cmd = "MoltenOpenInBrowser", desc = "Open in browser" },
}

for key, data in pairs(molten_commands) do
	map("n", key, safe_cmd(data.cmd), { desc = data.desc })
end

-- Julia
map("n", "<leader>Jrh", function()
	open_julia_repl("horizontal")
end, { desc = "Julia REPL (horizontal)" })

map("n", "<leader>Jrv", function()
	open_julia_repl("vertical")
end, { desc = "Julia REPL (vertical)" })

map("n", "<leader>Jrf", function()
	open_julia_repl("float")
end, { desc = "Julia REPL (floating)" })

map("n", "<leader>Jp", julia_command("using Pkg; Pkg.status()"), { desc = "Julia: Project status" })
map("n", "<leader>Ji", julia_command("using Pkg; Pkg.instantiate()"), { desc = "Julia: Instantiate project" })
map("n", "<leader>Ju", julia_command("using Pkg; Pkg.update()"), { desc = "Julia: Update project" })
map("n", "<leader>Jt", julia_command("using Pkg; Pkg.test()"), { desc = "Julia: Run tests" })
map("n", "<leader>Jd", julia_command("using Pkg; using Documenter; makedocs()"), { desc = "Julia: Generate docs" })

-- Filetype-specific (localleader) mappings
vim.api.nvim_create_autocmd("FileType", {
	group = filetype_keymaps_group,
	pattern = "tex",
	desc = "VimTeX localleader mappings",
	callback = function(args)
		local bufnr = args.buf
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		-- Ensure VimTeX is loaded before setting <Plug> mappings.
		vim.cmd("silent! packadd vimtex")

		map("n", "<localleader>ll", "<Plug>(vimtex-compile)", { buffer = bufnr, desc = "Compile" })
		map("n", "<localleader>lb", compile_lualatex_with_biber, { buffer = bufnr, desc = "Compile LuaLaTeX+Biber" })
		map("n", "<localleader>lv", "<Plug>(vimtex-view)", { buffer = bufnr, desc = "View PDF" })
		map("n", "<localleader>lk", "<Plug>(vimtex-stop)", { buffer = bufnr, desc = "Stop" })
		map("n", "<localleader>lK", "<Plug>(vimtex-stop-all)", { buffer = bufnr, desc = "Stop all" })
		map("n", "<localleader>lc", "<Plug>(vimtex-clean)", { buffer = bufnr, desc = "Clean aux" })
		map("n", "<localleader>lC", "<Plug>(vimtex-clean-full)", { buffer = bufnr, desc = "Clean full" })
		map("n", "<localleader>le", "<Plug>(vimtex-errors)", { buffer = bufnr, desc = "Errors" })
		map("n", "<localleader>lo", "<Plug>(vimtex-compile-output)", { buffer = bufnr, desc = "Output" })
		map("n", "<localleader>lg", "<Plug>(vimtex-status)", { buffer = bufnr, desc = "Status" })
		map("n", "<localleader>lG", "<Plug>(vimtex-status-all)", { buffer = bufnr, desc = "Status all" })
		map("n", "<localleader>lt", "<Plug>(vimtex-toc-open)", { buffer = bufnr, desc = "TOC" })
		map("n", "<localleader>lT", "<Plug>(vimtex-toc-toggle)", { buffer = bufnr, desc = "TOC toggle" })
		map("n", "<localleader>lq", "<Plug>(vimtex-log)", { buffer = bufnr, desc = "Log" })
		map("n", "<localleader>li", "<Plug>(vimtex-info)", { buffer = bufnr, desc = "Info" })
		map("n", "<localleader>lI", "<Plug>(vimtex-info-full)", { buffer = bufnr, desc = "Info full" })
		map("n", "<localleader>lx", "<Plug>(vimtex-reload)", { buffer = bufnr, desc = "Reload" })
		map("n", "<localleader>lX", "<Plug>(vimtex-reload-state)", { buffer = bufnr, desc = "Reload state" })
		map("n", "<localleader>la", "<Plug>(vimtex-context-menu)", { buffer = bufnr, desc = "Context menu" })
		map("n", "<localleader>lm", "<Plug>(vimtex-imaps-list)", { buffer = bufnr, desc = "Insert mode maps" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = filetype_keymaps_group,
	pattern = { "typst", "typ" },
	desc = "Typst localleader mappings",
	callback = function(args)
		local bufnr = args.buf
		if not vim.api.nvim_buf_is_valid(bufnr) then
			return
		end

		map("n", "<localleader>tp", function()
			if vim.fn.exists(":TypstPreviewToggle") == 2 then
				pcall(vim.cmd, "TypstPreviewToggle")
				return
			end
			local ok = pcall(require, "typst-preview")
			if not ok then
				vim.notify("typst-preview.nvim not available", vim.log.levels.WARN)
			end
		end, { buffer = bufnr, desc = "Typst preview: Toggle" })

		map("n", "<localleader>ts", function()
			if vim.fn.exists(":TypstPreviewSyncCursor") == 2 then
				pcall(vim.cmd, "TypstPreviewSyncCursor")
				return
			end
			local ok, tp = pcall(require, "typst-preview")
			if ok and tp.sync_with_cursor then
				pcall(tp.sync_with_cursor)
				return
			end
			vim.notify("Typst preview sync not available", vim.log.levels.WARN)
		end, { buffer = bufnr, desc = "Typst preview: Sync cursor" })

		map("n", "<localleader>tc", typst_compile_current, { buffer = bufnr, desc = "Compile PDF (typst c)" })

		map("n", "<localleader>tw", typst_watch_current, { buffer = bufnr, desc = "Watch file (typst w)" })
	end,
})

-- Obsidian
map("n", "<leader>On", obsidian_operation("new_note"), { desc = "New Obsidian note" })
map("n", "<leader>Ol", obsidian_operation("insert_link"), { desc = "Insert Obsidian link" })
map("n", "<leader>Of", obsidian_operation("follow_link"), { desc = "Follow Obsidian link" })
map("n", "<leader>Oc", obsidian_operation("toggle_checkbox"), { desc = "Toggle Obsidian checkbox" })
map("n", "<leader>Ob", obsidian_operation("show_backlinks"), { desc = "Show Obsidian backlinks" })
map("n", "<leader>Og", obsidian_operation("show_outgoing_links"), { desc = "Show Obsidian outgoing links" })

map("n", "<leader>Oo", function()
	local ok, telescope = pcall(require, "telescope.builtin")
	if not ok then
		vim.notify("telescope.nvim not available", vim.log.levels.WARN)
		return
	end

	local vault_path = get_obsidian_vault_path()
	if not vault_path then
		vim.notify("Obsidian vault path not available", vim.log.levels.ERROR)
		return
	end

	telescope.find_files({
		cwd = vault_path,
		prompt_title = "Obsidian Vault",
	})
end, { desc = "Find files in Obsidian vault" })

map("n", "<leader>Ot", safe_cmd("ObsidianTemplate"), { desc = "Insert Obsidian template" })
map("n", "<leader>ON", safe_cmd("ObsidianNewFromTemplate"), { desc = "New note from template" })
map("n", "<leader>Op", paste_obsidian_image, { desc = "Paste image and add two lines" })
map("n", "<leader>Ov", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Obsidian preview" })

-- Enhanced plugin manager keybindings
local function call_plugin_manager(func_name)
	local ok, PluginManager = pcall(require, "core.plugin-manager")
	if ok then
		PluginManager[func_name](PluginManager)
	else
		vim.notify("Plugin Manager not available", vim.log.levels.WARN)
	end
end

map("n", "<leader>CUa", function()
	call_plugin_manager("update_all_plugins")
end, { desc = "Update All Plugins" })
map("n", "<leader>CUs", function()
	call_plugin_manager("show_status")
end, { desc = "Plugin Status" })
map("n", "<leader>CUc", function()
	call_plugin_manager("cleanup_orphaned")
end, { desc = "Cleanup Orphaned Plugins" })

return {}

