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
				nav = true,
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

	-- which-key group for VimTeX under localleader
	wk.add({
		{ "<localleader>l", group = "VimTeX" },
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

	-- Add keymaps using modern v3 API (text-only, no icons)
	wk.add({
		-- Buffer operations
		{ "<leader>B", group = "Buffer" },
		-- Configuration
		{ "<leader>C", group = "Config" },
		{
			"<leader>Cs",
			function()
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
			end,
			desc = "Source config",
		},
		-- File explorer
		-- Find files
		-- Git operations
		{ "<leader>G",   group = "Git" },
		-- Git operations
		{
			"<leader>Gs",
			function()
				vim.cmd("!git status")
			end,
			desc = "Git Status",
		},
		{
			"<leader>Gp",
			function()
				vim.cmd("!git pull")
			end,
			desc = "Git Pull",
		},
		{
			"<leader>Gg",
			function()
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
			end,
			desc = "LazyGit",
		},

		-- Toggle options
		{ "<leader>Y",   group = "Toggle" },
		-- Editor utilities
		{ "<leader>Ys",  ":set spell!<CR>",                        desc = "Toggle Spell Check" },
		{ "<leader>Yse", ":set spelllang=en_gb<CR>:set spell<CR>", desc = "Set spell language to English (British)" },
		{ "<leader>Ysf", ":set spelllang=fr<CR>:set spell<CR>",    desc = "Set spell language to French" },

		-- LSP operations
		{ "<leader>L",   group = "LSP" },
		{
			"<leader>Ll",
			function()
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
			end,
			desc = "List available servers",
		},
		{
			"<leader>Lr",
			function()
				local clients = vim.lsp.get_active_clients({ bufnr = 0 })
				if #clients == 0 then
					print("No active LSP clients to restart")
				else
					print("Restarting LSP...")
					vim.cmd("LspRestart")
				end
			end,
			desc = "Restart LSP",
		},
		{
			"<leader>Lf",
			function()
				vim.lsp.buf.format({ async = true })
			end,
			desc = "Format Document",
		},
		{
			"<leader>LR",
			function()
				vim.lsp.buf.references()
			end,
			desc = "Show References",
		},
		-- Plugin management
		{ "<leader>P", group = "Plugin" },
		-- Quit
		{ "<leader>q", ":q<CR>",        desc = "Close buffer" },
		-- Quarto operations
		{ "<leader>Q", group = "Quarto" },
		-- Quarto preview operations
		{
			"<leader>Qp",
			function()
				pcall(function()
					require("quarto").quartoPreview()
				end)
			end,
			desc = "Quarto Preview",
		},
		{
			"<leader>Qc",
			function()
				pcall(function()
					require("quarto").quartoClosePreview()
				end)
			end,
			desc = "Close preview",
		},
		{
			"<leader>Qr",
			function()
				pcall(function()
					vim.cmd("QuartoRender")
				end)
			end,
			desc = "Quarto Render",
		},
		-- Molten keymaps under <leader>Qm prefix
		{ "<leader>Qm",  group = "Molten" },
		{
			"<leader>Qmi",
			function()
				vim.cmd("MoltenImagePopup")
			end,
			desc = "Show Image Popup",
		},
		{
			"<leader>Qml",
			function()
				vim.cmd("MoltenEvaluateLine")
			end,
			desc = "Evaluate Line",
		},
		{
			"<leader>Qme",
			function()
				vim.cmd("MoltenEvaluateOperator")
			end,
			desc = "Evaluate Operator",
		},
		{
			"<leader>Qmn",
			function()
				pcall(function()
					vim.cmd("MoltenInit")
				end)
			end,
			desc = "Initialise Kernel",
		},
		{
			"<leader>Qmk",
			function()
				pcall(function()
					vim.cmd("MoltenDeinit")
				end)
			end,
			desc = "Stop Kernel",
		},
		{
			"<leader>Qmr",
			function()
				pcall(function()
					vim.cmd("MoltenRestart")
				end)
			end,
			desc = "Restart Kernel",
		},
		-- Code evaluation
		{
			"<leader>Qmo",
			function()
				pcall(function()
					vim.cmd("MoltenEvaluateOperator")
				end)
			end,
			desc = "Evaluate Operator",
		},
		{
			"<leader>Qm<CR>",
			function()
				pcall(function()
					vim.cmd("MoltenEvaluateLine")
				end)
			end,
			desc = "Evaluate Line",
		},
		{
			"<leader>Qmv",
			function()
				pcall(function()
					vim.cmd("MoltenEvaluateVisual")
				end)
			end,
			desc = "Evaluate Visual",
		},
		{
			"<leader>Qmf",
			function()
				pcall(function()
					vim.cmd("MoltenReevaluateCell")
				end)
			end,
			desc = "Re-evaluate Cell",
		},
		-- Output management
		{
			"<leader>Qmh",
			function()
				pcall(function()
					vim.cmd("MoltenHideOutput")
				end)
			end,
			desc = "Hide Output",
		},
		{
			"<leader>Qms",
			function()
				pcall(function()
					vim.cmd("MoltenShowOutput")
				end)
			end,
			desc = "Show Output",
		},
		{
			"<leader>Qmd",
			function()
				pcall(function()
					vim.cmd("MoltenDelete")
				end)
			end,
			desc = "Delete Cell",
		},
		{
			"<leader>Qmb",
			function()
				pcall(function()
					vim.cmd("MoltenOpenInBrowser")
				end)
			end,
			desc = "Open in Browser",
		},

		-- Quit
		-- Search operations
		{ "<leader>S",   group = "Search" },
		-- Split operations
		{ "<leader>|",   group = "Split" },
		{ "<leader>|v",  "<cmd>vsplit<CR>",                          desc = "Vertical split" },
		{ "<leader>|h",  "<cmd>split<CR>",                           desc = "Horizontal split" },
		-- Terminal operations
		{ "<leader>T",   group = "Terminal" },
		{ "<leader>Ts",  group = "Server Management" },
		{ "<leader>Tss", start_nvim_server,                          desc = "Start Neovim server" },
		{ "<leader>Tst", stop_nvim_server,                           desc = "Stop Neovim server" },
		{ "<leader>Tr",  group = "Server Restart" },
		{ "<leader>Trs", restart_nvim_server,                        desc = "Restart Neovim server" },
		{ "<leader>TC",  group = "Server Check" },
		{ "<leader>TCk", check_nvim_server,                          desc = "Check Neovim server" },
		-- Vertical split
		-- Window operations
		{ "<leader>W",   group = "Window" },
		-- Trouble diagnostics
		{ "<leader>X",   group = "Trouble" },
		{ "<leader>Xw",  ":TroubleToggle workspace_diagnostics<CR>", desc = "Workspace Diagnostics" },
		{ "<leader>Xd",  ":TroubleToggle document_diagnostics<CR>",  desc = "Document Diagnostics" },
		{ "<leader>Xl",  ":TroubleToggle loclist<CR>",               desc = "Location List" },
		{ "<leader>Xq",  ":TroubleToggle quickfix<CR>",              desc = "Quickfix" },

		-- Julia-specific operations
		{ "<leader>J",   group = "Julia" },
		{ "<leader>Jr",  group = "Julia REPL" },
		{
			"<leader>Jrh",
			function()
				open_julia_repl("horizontal")
			end,
			desc = "Horizontal REPL",
		},
		{
			"<leader>Jrv",
			function()
				open_julia_repl("vertical")
			end,
			desc = "Vertical REPL",
		},
		{
			"<leader>Jrf",
			function()
				open_julia_repl("float")
			end,
			desc = "Floating REPL",
		},
		{
			"<leader>Jp",
			function()
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
			end,
			desc = "Project Status",
		},
		{
			"<leader>Ji",
			function()
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
			end,
			desc = "Instantiate Project",
		},
		{
			"<leader>Ju",
			function()
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
			end,
			desc = "Update Project",
		},
		{
			"<leader>Jt",
			function()
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
			end,
			desc = "Run Tests",
		},
		{
			"<leader>Jd",
			function()
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
			end,
			desc = "Generate Docs",
		},
	})

	-- Mason keymaps for LSP server management
	wk.add({
		{ "<leader>M", group = "Mason" },
		{
			"<leader>Mm",
			"<cmd>Mason<CR>",
			desc = "Open Mason",
		},
		{
			"<leader>Mi",
			"<cmd>MasonInstall<CR>",
			desc = "Install Package",
		},
		{
			"<leader>Mu",
			"<cmd>MasonUninstall<CR>",
			desc = "Uninstall Package",
		},
		{
			"<leader>Ml",
			"<cmd>MasonLog<CR>",
			desc = "View Mason Log",
		},
		{
			"<leader>Mh",
			"<cmd>MasonHelp<CR>",
			desc = "Mason Help",
		},
	})
end
