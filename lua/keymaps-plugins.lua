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

-- ============================================================================
-- PLUGIN-DEPENDENT KEYMAPS
-- ============================================================================

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

-- Markdown preview
map("n", "<leader>Kp", "<cmd>MarkdownPreview<CR>", { desc = "Start Markdown Preview" })
map("n", "<leader>Ks", "<cmd>MarkdownPreviewStop<CR>", { desc = "Stop Markdown Preview" })
map("n", "<leader>Kv", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Toggle Markdown Preview" })

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

