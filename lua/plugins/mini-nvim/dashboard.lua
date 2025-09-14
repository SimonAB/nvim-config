-- =============================================================================
-- MINI.NVIM DASHBOARD
-- PURPOSE: Dashboard setup, configuration, and keymaps for mini.nvim
-- =============================================================================

local config = require("plugins.mini-nvim.config")
local utils = require("plugins.mini-nvim.utils")
local dashboard_content = require("plugins.mini-nvim.dashboard-content")

local M = {}

-- Setup the dashboard
function M.setup()
	local starter_ok, starter = utils.safe_require("mini.starter")
	if not starter_ok then
		return
	end

	-- Ensure mini.starter is properly loaded
	vim.g.mini_starter_loaded = true

	-- Setup sessions if available
	local sessions_ok, mini_sessions = utils.safe_require("mini.sessions")
	if sessions_ok and not vim.g._mini_sessions_setup_done then
		mini_sessions.setup()
		vim.g._mini_sessions_setup_done = true
	end

	-- Prewarm cache before creating items for optimal performance
	dashboard_content.prewarm_cache()
	local items = dashboard_content.create_all_items()

	-- Add sessions if available
	local sections = starter.sections or starter.gen_section or {}
	if sessions_ok and sections.sessions then
		local ok_sess, sess = pcall(sections.sessions, 5, true)
		if ok_sess and type(sess) == "table" then
			for _, item in ipairs(sess) do
				table.insert(items, item)
			end
		end
	end

	-- Add builtin actions
	if sections.builtin_actions then
		local ok, builtins = pcall(sections.builtin_actions)
		if ok and type(builtins) == "table" then
			for _, item in ipairs(builtins) do
				table.insert(items, item)
			end
		end
	end

	-- Compose header with startup stats (LazyVim-style)
	local function build_header()
		local ascii = config.HEADER
		local ms = nil
		local ok_hr = (vim.loop and vim.loop.hrtime and type(vim.loop.hrtime) == "function")
		if ok_hr and _G.__nvim_start_ts then
			local now = vim.loop.hrtime()
			if type(now) == "number" and now > _G.__nvim_start_ts then
				ms = math.floor((now - _G.__nvim_start_ts) / 1e6)
			end
		end
		local prefix = ms and ("⚡ Startup: " .. tostring(ms) .. " ms") or "⚡ Startup: n/a"
		return ascii ..  "\n" .. prefix
	end

	starter.setup({
		evaluate_single = true,
		header = build_header(),
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
					config.SECTIONS
				) or function(x)
					return x
				end,
				hooks.padding and hooks.padding(3, 2) or function(x)
					return x
				end,
			}
		end)(),
		autoopen = true,
	})

	-- Configure header colour
	pcall(vim.api.nvim_set_hl, 0, "MiniStarterHeader", { fg = config.DASHBOARD.HEADER_COLOUR, bold = true })
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			pcall(vim.api.nvim_set_hl, 0, "MiniStarterHeader", { fg = config.DASHBOARD.HEADER_COLOUR, bold = true })
		end,
	})
end

-- Refresh dashboard content
function M.refresh()
	local ok_mini, MiniStarter = pcall(function()
		return _G.MiniStarter
	end)

	if ok_mini and MiniStarter then
		-- Prewarm cache before creating new items for consistent behavior
		dashboard_content.prewarm_cache()
		local new_items = dashboard_content.create_all_items()
		MiniStarter.config.items = new_items

		if type(MiniStarter.refresh) == "function" then
			MiniStarter.refresh()
		end
	end
end

-- Setup dashboard keymaps
function M.setup_keymaps()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "ministarter",
		callback = function(args)
			local buf = args.buf
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
					local current_buf = vim.api.nvim_get_current_buf()
					local was_modifiable = vim.bo[current_buf].modifiable

					if not was_modifiable then
						vim.bo[current_buf].modifiable = true
					end

					vim.cmd(action)

					if not was_modifiable then
						vim.bo[current_buf].modifiable = was_modifiable
					end
				elseif type(action) == "function" then
					pcall(action)
				end
			end

			-- Project shortcuts (1-9)
			for i = 1, math.min(#projects, 9) do
				vim.keymap.set("n", tostring(i), function()
					exec_action(projects[i].action)
				end, { buffer = buf, nowait = true, silent = true, desc = "Open Project " .. i })
			end

			-- Recent file shortcuts (a-d)
			for i = 1, math.min(#recent_files, 4) do
				vim.keymap.set("n", config.DASHBOARD.RECENT_FILE_KEYS[i], function()
					exec_action(recent_files[i].action)
				end, { buffer = buf, nowait = true, silent = true, desc = "Open Recent File " .. config.DASHBOARD.RECENT_FILE_KEYS[i] })
			end
		end,
	})
end

-- Setup autocommands
function M.setup_autocommands()
	-- Combined VimEnter autocmd
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			if vim.fn.argc() == 0 then
				local ok = pcall(vim.cmd, "MiniStarter")
				if not ok then
					vim.defer_fn(function()
						pcall(vim.cmd, "MiniStarter")
					end, 100)
				end
			end
			vim.defer_fn(M.refresh, 50) -- Reduced since items load immediately now
		end,
	})

	-- UIEnter fallback
	vim.api.nvim_create_autocmd("UIEnter", {
		once = true,
		callback = function()
			if vim.fn.argc() == 0 and vim.bo.filetype ~= "ministarter" then
				vim.defer_fn(function()
					pcall(vim.cmd, "MiniStarter")
				end, 50)
			end
		end,
	})

	-- Directory change refresh
	vim.api.nvim_create_autocmd("DirChanged", { callback = M.refresh })
end

-- Setup debug and testing
function M.setup_debug()
	vim.defer_fn(function()
		if vim.g.mini_starter_loaded then
			print("✓ Mini.starter loaded successfully")
		else
			print("⚠ Mini.starter not loaded")
		end
	end, 1000)

	vim.api.nvim_create_user_command('TestDashboard', function()
		if vim.g.mini_starter_loaded then
			vim.cmd('MiniStarter')
			print("Dashboard should be visible now")
		else
			print("Mini.starter not loaded - check plugin installation")
		end
	end, { desc = "Test mini.starter dashboard" })
end

return M
