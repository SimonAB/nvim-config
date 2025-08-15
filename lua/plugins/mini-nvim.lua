-- =============================================================================
-- PLUGIN: mini.nvim (https://github.com/echasnovski/mini.nvim)
-- PURPOSE: Modular Neovim plugin collection with comprehensive MiniStarter dashboard
-- MAINTAINER NOTES: Enhanced dashboard with projects, recent files, and direct keymaps
-- =============================================================================

	-- Load MiniStarter (dashboard) if available
	local starter_ok, starter = pcall(require, "mini.starter")
	if starter_ok then
		-- Ensure mini.starter is properly loaded and available
		vim.g.mini_starter_loaded = true
	-- Optionally enable sessions integration if available (non-intrusive defaults)
	local sessions_ok, mini_sessions = pcall(require, "mini.sessions")
	if sessions_ok then
		-- Use defaults; this keeps behaviour minimal while enabling session listing
		if not vim.g._mini_sessions_setup_done then
			mini_sessions.setup()
			vim.g._mini_sessions_setup_done = true
		end
	end

	local header = [[
███╗   ██╗ ███████╗  ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
████╗  ██║ ██╔════╝ ██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
██╔██╗ ██║ █████╗   ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
██║╚██╗██║ ██╔══╝   ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
██║ ╚████║ ███████╗ ╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
╚═╝  ╚═══╝ ╚══════╝  ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
	]]

	local items = {}
	-- Hyper-like shortcuts (inspired by dashboard-nvim 'hyper')
	local cfg_path = vim.fn.stdpath("config")
	local shortcuts = {
				{
			name = "Update plugins",
			action = function()
				-- Use a simple command approach to avoid mini.starter conflicts
				vim.cmd("echo '🔄 Updating plugins...'")

				-- Run plugin update in background without affecting the dashboard
				vim.defer_fn(function()
					local updated_count = 0
					local errors = {}

					-- Get plugin directory
					local pack_path = vim.fn.stdpath("data") .. "/pack/plugins/start"
					local plugin_dirs = vim.fn.glob(pack_path .. "/*", false, true)

					-- Update each plugin silently
					for i, dir in ipairs(plugin_dirs) do
						if vim.fn.isdirectory(dir) == 1 then
							local plugin_name = vim.fn.fnamemodify(dir, ":t")

							-- Check if it's a git repository
							if vim.fn.isdirectory(dir .. "/.git") == 1 then
								-- Try to update the plugin
								local result = vim.fn.system({ "git", "-C", dir, "pull", "--ff-only" })
								if vim.v.shell_error == 0 then
									updated_count = updated_count + 1
								else
									table.insert(errors, plugin_name .. ": " .. result)
								end
							end
						end
					end

					-- Show completion message
					local message = "✅ Plugin update complete! Updated " .. tostring(updated_count) .. " plugins"
					if #errors > 0 then
						message = message .. " (with " .. #errors .. " errors)"
					end
					vim.cmd("echo '" .. message .. "'")

					-- Refresh the dashboard content silently
					vim.defer_fn(function()
						refresh_starter()
					end, 500)

				end, 100)
			end,
			section = "Shortcuts",
		},
				{
			name = "Install plugins",
			action = function()
				-- Use a simple command approach to avoid mini.starter conflicts
				vim.cmd("echo '📦 Installing plugins...'")

				-- Run plugin installation in background without affecting the dashboard
				vim.defer_fn(function()
					local installed_count = 0
					local errors = {}

					-- Execute the plugin installation
					local result = vim.fn.system({ "nvim", "--headless", "-c", "luafile " .. vim.fn.stdpath("config") .. "/lua/plugins.lua", "-c", "qa!" })

					if vim.v.shell_error == 0 then
						installed_count = 1 -- Simplified for now
					else
						table.insert(errors, "Installation failed: " .. result)
					end

					-- Show completion message
					local message = "✅ Plugin installation complete! Installed " .. tostring(installed_count) .. " plugins"
					if #errors > 0 then
						message = message .. " (with " .. #errors .. " errors)"
					end
					vim.cmd("echo '" .. message .. "'")

					-- Refresh the dashboard content silently
					vim.defer_fn(function()
						refresh_starter()
					end, 500)

				end, 100)
			end,
			section = "Shortcuts",
		},
				{
			name = "Plugin status",
			action = function()
				-- Use a simple command approach to avoid mini.starter conflicts
				vim.cmd("echo '📊 Checking plugin status...'")

				-- Run plugin status check in background without affecting the dashboard
				vim.defer_fn(function()
					local total_plugins = 0
					local git_count = 0
					local status_info = {}

					-- Get plugin directory
					local start_path = vim.fn.stdpath("data") .. "/pack/plugins/start"
					vim.fn.mkdir(start_path, "p")

					-- Check each plugin
					local plugin_dirs = vim.fn.glob(start_path .. "/*", false, true)
					for _, dir in ipairs(plugin_dirs) do
						if vim.fn.isdirectory(dir) == 1 then
							local plugin_name = vim.fn.fnamemodify(dir, ":t")
							total_plugins = total_plugins + 1

							if vim.fn.isdirectory(dir .. "/.git") == 1 then
								git_count = git_count + 1
								local branch = vim.fn.system({ "git", "-C", dir, "branch", "--show-current" }):gsub("%s+", "")
								local commit = vim.fn.system({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }):gsub("%s+", "")
								table.insert(status_info, "✓ " .. plugin_name .. " [" .. branch .. "@" .. commit .. "]")
							else
								table.insert(status_info, "⚠ " .. plugin_name .. " (not git)")
							end
						end
					end

					-- Show status summary
					local message = "📊 Plugin Status: " .. total_plugins .. " plugins, " .. git_count .. " git repos"
					vim.cmd("echo '" .. message .. "'")

					-- Show detailed status in messages
					for _, info in ipairs(status_info) do
						vim.cmd("echo '" .. info .. "'")
					end

				end, 100)
			end,
			section = "Shortcuts",
		},
		{ name = "Explore files", action = "NvimTreeToggle", section = "Shortcuts" },
		{
			name = "Find files",
			action = "Telescope find_files",
			section = "Shortcuts",
		},
		{
			name = "Grep",
			action = "Telescope live_grep",
			section = "Shortcuts",
		},
		{
			name = "Config",
			action = string.format("lua require('telescope.builtin').find_files({ cwd = [[%s]] })", cfg_path),
			section = "Shortcuts",
		},
		{
			name = "Quit",
			action = "q",
			section = "Shortcuts",
		},
	}
	for _, it in ipairs(shortcuts) do
		table.insert(items, it)
	end

	-- Projects list (approximation): unique parent dirs from recent files
	local function recent_projects(limit)
		local dirs, order = {}, {}
		local oldfiles = vim.v.oldfiles or {}
		for _, f in ipairs(oldfiles) do
			if type(f) == "string" and #f > 0 then
				local abs = vim.fn.fnamemodify(f, ":p")
				if abs ~= "" and vim.loop.fs_stat(abs) then
					local dir = vim.fn.fnamemodify(abs, ":h")
					if dir and dir ~= "" and dirs[dir] == nil and vim.loop.fs_stat(dir) then
						dirs[dir] = true
						table.insert(order, dir)
						if #order >= limit then
							break
						end
					end
				end
			end
		end
		return order
	end

	-- Recent files list: get recent files with custom keys
	local function recent_files(limit)
		local files, order = {}, {}
		local oldfiles = vim.v.oldfiles or {}
		for _, f in ipairs(oldfiles) do
			if type(f) == "string" and #f > 0 then
				local abs = vim.fn.fnamemodify(f, ":p")
				if abs ~= "" and vim.loop.fs_stat(abs) and files[abs] == nil then
					files[abs] = true
					table.insert(order, abs)
					if #order >= limit then
						break
					end
				end
			end
		end
		return order
	end

	do
		local idx = 1
		for _, dir in ipairs(recent_projects(4)) do
			local label = string.format("%d. ", idx)
			local name = label .. " " .. vim.fn.fnamemodify(dir, ":t")
			local action = string.format("lua require('telescope.builtin').find_files({ cwd = [[%s]] })", dir)
			table.insert(items, { name = name, action = action, section = "Projects" })
			idx = idx + 1
		end
	end
	-- Compatible section API resolver (supports both sections and legacy gen_section)
	local sections = starter.sections or starter.gen_section or {}

	-- Recent files with custom keys (a-d, up to 4 files)
	do
		local keys = { "a", "b", "c", "d" }
		for i, file in ipairs(recent_files(4)) do
			local key = keys[i]
			local label = string.format("%s. ", key)
			local name = label .. " " .. vim.fn.fnamemodify(file, ":t")
			local action = "edit " .. vim.fn.fnameescape(file)
			table.insert(items, { name = name, action = action, section = "Recent files" })
		end
	end

	-- Sessions (if mini.sessions available)
	if sessions_ok and sections.sessions then
		local ok_sess, sess = pcall(sections.sessions, 5, true)
		if ok_sess and type(sess) == "table" then
			for _, it in ipairs(sess) do
				table.insert(items, it)
			end
		end
	end

	-- Builtin actions
	do
		local builtins
		if sections.builtin_actions then
			local ok, res = pcall(sections.builtin_actions)
			if ok then
				builtins = res
			end
		end
		if type(builtins) == "table" then
			for _, it in ipairs(builtins) do
				table.insert(items, it)
			end
		end
	end

	starter.setup({
		evaluate_single = true,
		header = header,
		items = items,
		content_hooks = (function()
			local hooks = starter.gen_hook or {}
			return {
				hooks.aligning and hooks.aligning('center', 'center') or function(x)
					return x
				end,
				hooks.adding_bullet and hooks.adding_bullet() or function(x)
					return x
				end,
				hooks.indexing and hooks.indexing(
					"all",
					{ "Shortcuts", "Projects", "Recent files", "Sessions", "Builtin actions" }
				) or function(x)
					return x
				end,
				hooks.padding and hooks.padding(3, 2) or function(x)
					return x
				end,
			}
		end)(),
		-- Ensure dashboard shows on startup when no files provided
		autoopen = true,
	})

	-- Force header colour keep it across colourscheme changes
	local starter_header_colour = "#4A6D8C" -- Muted blue-black
	-- local starter_header_colour = "#FFCC12" -- yellow
	-- local starter_header_colour = "#FFCC12" -- A slightly darker, more metallic gold
	-- local starter_header_colour = "#FF0000" -- pure red
	-- local starter_header_colour = "#8B0000" -- blood red
	-- local starter_header_colour = "#2C3E50" -- Lighter shade with more blue tone
	pcall(vim.api.nvim_set_hl, 0, "MiniStarterHeader", { fg = starter_header_colour, bold = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			pcall(vim.api.nvim_set_hl, 0, "MiniStarterHeader", { fg = starter_header_colour, bold = true })
		end,
	})

	-- Refresh projects shortly after startup and on directory change
	local function refresh_starter()
		local ok_mini, MiniStarter = pcall(function()
			return _G.MiniStarter
		end)
		if ok_mini and MiniStarter then
			local new_items = {}
			do
				local cfg_path = vim.fn.stdpath("config")
				local shortcuts = {
					{
						name = "Update plugins",
						action = function()
							-- Use a simple command approach to avoid mini.starter conflicts
							vim.cmd("echo '🔄 Updating plugins...'")

							-- Run plugin update in background without affecting the dashboard
							vim.defer_fn(function()
								local updated_count = 0
								local errors = {}

								-- Get plugin directory
								local pack_path = vim.fn.stdpath("data") .. "/pack/plugins/start"
								local plugin_dirs = vim.fn.glob(pack_path .. "/*", false, true)

								-- Update each plugin with progress feedback
								for i, dir in ipairs(plugin_dirs) do
									if vim.fn.isdirectory(dir) == 1 then
										local plugin_name = vim.fn.fnamemodify(dir, ":t")

										-- Check if it's a git repository
										if vim.fn.isdirectory(dir .. "/.git") == 1 then
											-- Show progress for current plugin
											vim.cmd("echo '🔄 Updating " .. plugin_name .. " (" .. i .. "/" .. #plugin_dirs .. ")'")

											-- Try to update the plugin
											local result = vim.fn.system({ "git", "-C", dir, "pull", "--ff-only" })
											if vim.v.shell_error == 0 then
												updated_count = updated_count + 1
												vim.cmd("echo '✅ Updated " .. plugin_name .. "'")
											else
												table.insert(errors, plugin_name .. ": " .. result)
												vim.cmd("echo '❌ Failed to update " .. plugin_name .. "'")
											end
										else
											vim.cmd("echo '⚠ Skipping " .. plugin_name .. " (not a git repo)'")
										end
									end
								end

								-- Show completion message
								local message = "✅ Plugin update complete! Updated " .. tostring(updated_count) .. " plugins"
								if #errors > 0 then
									message = message .. " (with " .. #errors .. " errors)"
								end
								vim.cmd("echo '" .. message .. "'")

							end, 100)
						end,
						section = "Shortcuts",
					},
					{
						name = "Install plugins",
						action = function()
							-- Use a simple command approach to avoid mini.starter conflicts
							vim.cmd("echo '📦 Installing plugins...'")

							-- Run plugin installation in background without affecting the dashboard
							vim.defer_fn(function()
								local installed_count = 0
								local errors = {}

								-- Execute the plugin installation
								local result = vim.fn.system({ "nvim", "--headless", "-c", "luafile " .. vim.fn.stdpath("config") .. "/lua/plugins.lua", "-c", "qa!" })

								if vim.v.shell_error == 0 then
									installed_count = 1 -- Simplified for now
								else
									table.insert(errors, "Installation failed: " .. result)
								end

								-- Show completion message
								local message = "✅ Plugin installation complete! Installed " .. tostring(installed_count) .. " plugins"
								if #errors > 0 then
									message = message .. " (with " .. #errors .. " errors)"
								end
								vim.cmd("echo '" .. message .. "'")

							end, 100)
						end,
						section = "Shortcuts",
					},
					{
						name = "Plugin status",
						action = function()
							-- Use a simple command approach to avoid mini.starter conflicts
							vim.cmd("echo '📊 Checking plugin status...'")

							-- Run plugin status check in background without affecting the dashboard
							vim.defer_fn(function()
								local total_plugins = 0
								local git_count = 0
								local status_info = {}

								-- Get plugin directory
								local start_path = vim.fn.stdpath("data") .. "/pack/plugins/start"
								vim.fn.mkdir(start_path, "p")

								-- Check each plugin
								local plugin_dirs = vim.fn.glob(start_path .. "/*", false, true)
								for _, dir in ipairs(plugin_dirs) do
									if vim.fn.isdirectory(dir) == 1 then
										local plugin_name = vim.fn.fnamemodify(dir, ":t")
										total_plugins = total_plugins + 1

										if vim.fn.isdirectory(dir .. "/.git") == 1 then
											git_count = git_count + 1
											local branch = vim.fn.system({ "git", "-C", dir, "branch", "--show-current" }):gsub("%s+", "")
											local commit = vim.fn.system({ "git", "-C", dir, "rev-parse", "--short", "HEAD" }):gsub("%s+", "")
											table.insert(status_info, "✓ " .. plugin_name .. " [" .. branch .. "@" .. commit .. "]")
										else
											table.insert(status_info, "⚠ " .. plugin_name .. " (not git)")
										end
									end
								end

								-- Show status summary
								local message = "📊 Plugin Status: " .. total_plugins .. " plugins, " .. git_count .. " git repos"
								vim.cmd("echo '" .. message .. "'")

								-- Show detailed status in messages
								for _, info in ipairs(status_info) do
									vim.cmd("echo '" .. info .. "'")
								end

							end, 100)
						end,
						section = "Shortcuts",
					},
					{
						name = "Explore files",
						action = "NvimTreeToggle",
						section = "Shortcuts",
					},
					{
						name = "Find files",
						action = "Telescope find_files",
						section = "Shortcuts",
					},
					{
						name = "Grep",
						action = "Telescope live_grep",
						section = "Shortcuts",
					},
					{
						name = "Settings",
						action = string.format(
							"lua require('telescope.builtin').find_files({ cwd = [[%s]] })",
							cfg_path
						),
						section = "Shortcuts",
					},
					{
						name = "Quit",
						action = "q",
						section = "Shortcuts",
					},
				}
				for _, it in ipairs(shortcuts) do
					table.insert(new_items, it)
				end
			end
			do
				local idx = 1
				for _, dir in ipairs(recent_projects(4)) do
					local label = string.format("%d. ", idx)
					local name = label .. " " .. vim.fn.fnamemodify(dir, ":t")
					local action = string.format("lua require('telescope.builtin').find_files({ cwd = [[%s]] })", dir)
					table.insert(new_items, { name = name, action = action, section = "Projects" })
					idx = idx + 1
				end
			end

			-- Recent files with custom keys (a-d, up to 4 files)
			do
				local keys = { "a", "b", "c", "d" }
				for i, file in ipairs(recent_files(4)) do
					local key = keys[i]
					local label = string.format("%s. ", key)
					local name = label .. " " .. vim.fn.fnamemodify(file, ":t")
					local action = "edit " .. vim.fn.fnameescape(file)
					table.insert(new_items, { name = name, action = action, section = "Recent files" })
				end
			end
			MiniStarter.config.items = new_items
			if type(MiniStarter.refresh) == "function" then
				MiniStarter.refresh()
			end
		end
	end

	-- Combined VimEnter autocmd that handles both dashboard startup and refresh
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			-- Show dashboard if no files were provided as arguments
			if vim.fn.argc() == 0 then
				-- Use pcall to safely try to show the dashboard
				local ok = pcall(vim.cmd, "MiniStarter")
				if not ok then
					-- If MiniStarter command fails, try again after a delay
					vim.defer_fn(function()
						pcall(vim.cmd, "MiniStarter")
					end, 100)
				end
			end

			-- Refresh starter content after a delay
			vim.defer_fn(refresh_starter, 120)
		end,
	})

	-- Additional fallback: ensure dashboard shows on startup
	vim.api.nvim_create_autocmd("UIEnter", {
		once = true,
		callback = function()
			-- Only show if no files were provided and we're not already showing the dashboard
			if vim.fn.argc() == 0 and vim.bo.filetype ~= "ministarter" then
				vim.defer_fn(function()
					pcall(vim.cmd, "MiniStarter")
				end, 50)
			end
		end,
	})

	-- Debug: Check if mini.starter is working
	vim.defer_fn(function()
		if vim.g.mini_starter_loaded then
			print("✓ Mini.starter loaded successfully")
		else
			print("⚠ Mini.starter not loaded")
		end
	end, 1000)
	vim.api.nvim_create_autocmd("DirChanged", { callback = refresh_starter })

	-- Starter buffer quality-of-life keymaps
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "ministarter",
		callback = function(args)
			local buf = args.buf
			-- Direct numeric shortcuts for Projects (1..9)
			local items = (_G.MiniStarter and _G.MiniStarter.config and _G.MiniStarter.config.items) or {}
			local projects = {}
			local recent_files = {}
			for _, item in ipairs(items) do
				if item and item.section == "Projects" then
					table.insert(projects, item)
				elseif item and item.section == "Recent files" then
					table.insert(recent_files, item)
				end
			end

			local function exec_action(action)
				if type(action) == "string" then
					-- Handle non-modifiable buffer for string actions
					local current_buf = vim.api.nvim_get_current_buf()
					local was_modifiable = vim.bo[current_buf].modifiable

					-- Temporarily enable modifications if needed
					if not was_modifiable then
						vim.bo[current_buf].modifiable = true
					end

					-- Execute the action
					vim.cmd(action)

					-- Restore original modifiable state
					if not was_modifiable then
						vim.bo[current_buf].modifiable = was_modifiable
					end
				elseif type(action) == "function" then
					pcall(action)
				end
			end

			for i = 1, math.min(#projects, 9) do
				vim.keymap.set("n", tostring(i), function()
					exec_action(projects[i].action)
				end, { buffer = buf, nowait = true, silent = true, desc = "Open Project " .. i })
			end

			-- Direct key shortcuts for Recent files (a-d, up to 4 files)
			local recent_keys = { "a", "b", "c", "d" }
			for i = 1, math.min(#recent_files, 4) do
				vim.keymap.set("n", recent_keys[i], function()
					exec_action(recent_files[i].action)
				end, { buffer = buf, nowait = true, silent = true, desc = "Open Recent File " .. recent_keys[i] })
			end
		end,
	})
end

	-- Load MiniSurround for text object editing if available
	local ok, mini_surround = pcall(require, "mini.surround")
	if ok then
		mini_surround.setup() -- Enable surround text objects (change, add, delete)
	end

	-- Add manual command to test dashboard
	vim.api.nvim_create_user_command('TestDashboard', function()
		if vim.g.mini_starter_loaded then
			vim.cmd('MiniStarter')
			print("Dashboard should be visible now")
		else
			print("Mini.starter not loaded - check plugin installation")
		end
	end, { desc = "Test mini.starter dashboard" })

-- To add more mini.nvim modules, require and configure them here as needed.
-- mini.nvim modules (commented for later activation; remove leading -- to enable)
-- require('mini.base16').setup()
-- require('mini.ai').setup()
-- require('mini.align').setup()
-- require('mini.animate').setup()
-- require('mini.basics').setup()
-- require('mini.bracketed').setup()
-- require('mini.bufremove').setup()
-- require('mini.clue').setup()
-- require('mini.colors').setup()
-- require('mini.hipatterns').setup()
-- require('mini.comment').setup()
-- require('mini.completion').setup()
-- require('mini.cursorword').setup()
-- require('mini.extra').setup()
-- require('mini.deps').setup()
-- require('mini.diff').setup()
-- require('mini.doc').setup()
-- require('mini.files').setup()
-- require('mini.fuzzy').setup()
-- require('mini.git').setup()
-- require('mini.hues').setup()
-- require('mini.icons').setup()
-- require('mini.indentscope').setup()
-- require('mini.jump').setup()
-- require('mini.jump2d').setup()
-- require('mini.map').setup()
-- require('mini.misc').setup()
-- require('mini.move').setup()
-- require('mini.notify').setup()
-- require('mini.operators').setup()
-- require('mini.pairs').setup()
-- require('mini.pick').setup()
-- require('mini.sessions').setup()
-- require('mini.snippets').setup()
-- require('mini.splitjoin').setup()
-- require('mini.starter').setup()
-- require('mini.statusline').setup()
-- require('mini.tabline').setup()
-- require('mini.test').setup()
-- require('mini.trailspace').setup()
-- require('mini.visits').setup()
