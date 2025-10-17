-- Configuration for which-key.nvim
-- Keymap popup helper with comprehensive keybindings

local ok, wk = pcall(require, "which-key")
if ok then
    wk.setup({
        preset = "classic",
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
				-- nav preset disabled to prevent which-key from intercepting ]s/[s
				-- This sacrifices bracket motion hints but preserves spell navigation
				nav = false,
				z = true,
				g = true,
			},
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
		icons = {
			breadcrumb = "»",
			separator = "→",
			group = "+",
			ellipsis = "...",
			mappings = false, -- Disable icon mappings for a cleaner look
			rules = {},
			colors = false, -- Disable icon colors for text-only
			keys = {
				Up = " ",
				Down = " ",
				Left = " ",
				Right = " ",
				C = "󰘴 ",
				M = "󰘵 ",
				D = "󰘳 ",
				S = "󰘶 ",
				CR = "󰌑 ",
				Esc = "󱊷 ",
				ScrollWheelDown = "󱕐 ",
				ScrollWheelUp = "󱕑 ",
				NL = "󰌑 ",
				BS = "󰁮",
				Space = "󱁐 ",
				Tab = "󰌒 ",
				F1 = "󱊫",
				F2 = "󱊬",
				F3 = "󱊭",
				F4 = "󱊮",
				F5 = "󱊯",
				F6 = "󱊰",
				F7 = "󱊱",
				F8 = "󱊲",
				F9 = "󱊳",
				F10 = "󱊴",
				F11 = "󱊵",
				F12 = "󱊶",
			},
		},
	})

	-- which-key groups for localleader keymaps
	-- These provide display/help for keymaps defined in keymaps.lua
	wk.add({
		{ "<localleader>l", group = "VimTeX" },
		{ "<localleader>t", group = "Typst" },
	})

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

	-- Server management functions
	local function start_nvim_server()
		local socket_path = "/tmp/nvim_server"

		-- Check if server is already running
		if vim.fn.filereadable(socket_path) == 1 then
			print("Neovim server already running at " .. socket_path)
			return
		end

		-- Start server in background
		local cmd = string.format("nvim --listen %s --headless", socket_path)
		vim.fn.system(cmd .. " &")

		-- Wait a moment and verify
		vim.defer_fn(function()
			if vim.fn.filereadable(socket_path) == 1 then
				print("✓ Neovim server started successfully at " .. socket_path)
			else
				print("✗ Failed to start Neovim server")
			end
		end, 1000)
	end

	local function stop_nvim_server()
		local socket_path = "/tmp/nvim_server"

		-- Check if server exists
		if vim.fn.filereadable(socket_path) == 0 then
			print("No Neovim server running")
			return
		end

		-- Try graceful shutdown first
		local success = pcall(function()
			vim.fn.system(string.format("nvr --servername %s --remote-send ':qa!<CR>'", socket_path))
		end)

		-- Force kill if graceful shutdown didn't work
		vim.defer_fn(function()
			if vim.fn.filereadable(socket_path) == 1 then
				vim.fn.system("pkill -f 'nvim.*nvim_server'")
				vim.fn.system("rm -f " .. socket_path)
				print("✓ Neovim server stopped (force killed)")
			else
				print("✓ Neovim server stopped gracefully")
			end
		end, 1000)
	end

	local function restart_nvim_server()
		print("Restarting Neovim server...")
		stop_nvim_server()

		-- Start new server after a delay
		vim.defer_fn(function()
			start_nvim_server()
		end, 2000)
	end

	local function check_nvim_server()
		local socket_path = "/tmp/nvim_server"

		if vim.fn.filereadable(socket_path) == 0 then
			print("✗ Neovim server not running")
			return
		end

		-- Test server responsiveness
		local success = pcall(function()
			local result = vim.fn.system(string.format("nvr --servername %s --remote-expr '1+1'", socket_path))
			if result and result:match("2") then
				print("✓ Neovim server running and responsive at " .. socket_path)
			else
				print("⚠ Neovim server socket exists but not responsive")
			end
		end)

		if not success then
			print("⚠ Neovim server socket exists but nvr communication failed")
		end
	end

	-- Register leader keymap groups for which-key display
	-- Individual keymaps are defined in keymaps.lua with desc fields
	-- Convention: Capital letters = groups with sub-commands, lowercase = direct commands
	wk.add({
		-- Buffer operations
		{ "<leader>B", group = "Buffer" },
		-- Configuration
		{ "<leader>C", group = "Config" },
		-- Frecency operations (capital F for group with sub-commands)
		{ "<leader>F", group = "Frecency" },
		-- Git operations
		{ "<leader>G", group = "Git" },
		-- Obsidian operations
		{ "<leader>O", group = "Obsidian" },
		-- Search operations (grep with location options)
		{ "<leader>S", group = "Search" },
		-- Toggle options
		{ "<leader>Y", group = "Toggle" },
		-- LSP operations
		{ "<leader>L", group = "LSP" },
		-- Quarto operations
		{ "<leader>Q", group = "Quarto" },
		-- Split operations
		{ "<leader>|", group = "Split" },
		-- Terminal operations
		{ "<leader>T", group = "Terminal" },
		-- Window operations
		{ "<leader>W", group = "Window" },
		-- Trouble diagnostics
		{ "<leader>X", group = "Trouble" },
		-- Julia-specific operations
		{ "<leader>J", group = "Julia" },
			-- Mason operations (enhanced with batch operations)
	{ "<leader>M", group = "Mason" },
	{ "<leader>MA", function()
		local ok, MasonUI = pcall(require, "plugins.mason-enhanced")
		if ok then
			MasonUI.install_academic_servers()
		else
			vim.notify("Mason Enhanced UI not available", vim.log.levels.WARN)
		end
	end, desc = "Install Academic LSP Servers" },
	{ "<leader>MR", function()
		local ok, MasonUI = pcall(require, "plugins.mason-enhanced")
		if ok then
			MasonUI.install_all_recommended()
		else
			vim.notify("Mason Enhanced UI not available", vim.log.levels.WARN)
		end
	end, desc = "Install All Recommended Servers" },
	{ "<leader>MU", function()
		local ok, MasonUI = pcall(require, "plugins.mason-enhanced")
		if ok then
			MasonUI.update_all_packages()
		else
			vim.notify("Mason Enhanced UI not available", vim.log.levels.WARN)
		end
	end, desc = "Update All Packages" },
	{ "<leader>MS", function()
		local ok, MasonUI = pcall(require, "plugins.mason-enhanced")
		if ok then
			MasonUI.check_status()
		else
			vim.notify("Mason Enhanced UI not available", vim.log.levels.WARN)
		end
	end, desc = "Mason Status" },
		-- Markdown preview
		{ "<leader>K", group = "Markdown" },

		-- Theme management (enhanced with floating picker)
		{ "<leader>Yt", group = "Themes" },

		-- Plugin management (enhanced with progress feedback)
		{ "<leader>Cu", group = "Update" },
	})

	-- All individual keymaps are now defined in keymaps.lua with desc fields
	-- which-key automatically discovers and displays them
end
