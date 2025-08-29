-- =============================================================================
-- ENHANCED PLUGIN MANAGER
-- PURPOSE: Comprehensive plugin update system with progress feedback
-- =============================================================================

local PluginManager = {}
local progress_handle = nil

-- Progress and notification system
local function create_progress(title, message)
	if progress_handle then
		progress_handle:finish()
	end

	local ok, fidget = pcall(require, "fidget")
	if ok then
		progress_handle = fidget.progress.handle.create({
			title = title,
			message = message,
			percentage = 0,
		})
	else
		vim.notify(message, vim.log.levels.INFO, {
			title = title,
			timeout = 5000,
		})
	end
	return progress_handle
end

local function notify(message, level, opts)
	local default_opts = {
		title = "Plugin Manager",
		timeout = 3000,
	}
	local final_opts = vim.tbl_extend("force", default_opts, opts or {})
	vim.notify(message, level, final_opts)
end

-- Get plugin directory
function PluginManager.get_plugin_dir()
	return vim.fn.stdpath("data") .. "/pack/plugins/start"
end

-- Get list of installed plugins
function PluginManager.get_installed_plugins()
	local plugin_dir = PluginManager.get_plugin_dir()
	local plugins = {}

	local ok, scandir = pcall(vim.fn.readdir, plugin_dir)
	if not ok then
		return plugins
	end

	for _, dir in ipairs(scandir) do
		local full_path = plugin_dir .. "/" .. dir
		if vim.fn.isdirectory(full_path) == 1 then
			local git_dir = full_path .. "/.git"
			if vim.fn.isdirectory(git_dir) == 1 then
				table.insert(plugins, {
					name = dir,
					path = full_path,
					has_git = true
				})
			else
				table.insert(plugins, {
					name = dir,
					path = full_path,
					has_git = false
				})
			end
		end
	end

	return plugins
end

-- Update all plugins with progress feedback
function PluginManager.update_all_plugins()
	local plugins = PluginManager.get_installed_plugins()
	local handle = create_progress("Updating Plugins", "Checking for updates...")

	if #plugins == 0 then
		notify("No plugins found to update", vim.log.levels.WARN)
		if handle then handle:finish() end
		return
	end

	local total = #plugins
	local completed = 0
	local updated = 0
	local failed = {}

	-- Update plugins sequentially to avoid conflicts
	local function update_next(index)
		if index > total then
			-- All done
			if handle then
				local success_msg = string.format("Plugin update complete! %d/%d updated", updated, total)
				if #failed > 0 then
					success_msg = success_msg .. string.format(" (%d failed)", #failed)
				end
				handle.message = success_msg
				vim.defer_fn(function() handle:finish() end, 1000)
			end

			local final_msg = string.format("Plugin updates: %d/%d successful", updated, total)
			local level = (#failed == 0) and vim.log.levels.INFO or vim.log.levels.WARN

			if #failed > 0 then
				notify(final_msg .. string.format(" (%d failed)", #failed), level, { timeout = 5000 })
				for _, failure in ipairs(failed) do
					notify("Failed: " .. failure, vim.log.levels.ERROR)
				end
			else
				notify(final_msg, vim.log.levels.INFO)
			end
			return
		end

		local plugin = plugins[index]
		if handle then
			handle.message = string.format("Updating %s (%d/%d)", plugin.name, index, total)
			handle.percentage = ((index - 1) / total) * 100
		end

		-- Skip plugins without git
		if not plugin.has_git then
			completed = completed + 1
			vim.defer_fn(function()
				update_next(index + 1)
			end, 100)
			return
		end

		-- Update plugin
		local cmd = { "git", "-C", plugin.path, "pull", "--ff-only", "--quiet" }
		local result = vim.fn.system(cmd)

		if vim.v.shell_error == 0 then
			-- Check if actually updated (not just "Already up to date")
			if not result:match("Already up to date") then
				updated = updated + 1
			end
		else
			table.insert(failed, plugin.name .. ": " .. result:gsub("\n", " "))
		end

		completed = completed + 1

		-- Schedule next update
		vim.defer_fn(function()
			update_next(index + 1)
		end, 200) -- Small delay between updates
	end

	-- Start the update process
	update_next(1)
end

-- Update specific plugin
function PluginManager.update_plugin(plugin_name)
	local plugin_dir = PluginManager.get_plugin_dir()
	local plugin_path = plugin_dir .. "/" .. plugin_name

	if vim.fn.isdirectory(plugin_path) == 0 then
		notify("Plugin not found: " .. plugin_name, vim.log.levels.ERROR)
		return
	end

	local git_dir = plugin_path .. "/.git"
	if vim.fn.isdirectory(git_dir) == 0 then
		notify("Plugin is not a git repository: " .. plugin_name, vim.log.levels.WARN)
		return
	end

	local handle = create_progress("Updating Plugin", "Updating " .. plugin_name .. "...")

	vim.defer_fn(function()
		local cmd = { "git", "-C", plugin_path, "pull", "--ff-only" }
		local result = vim.fn.system(cmd)

		if handle then
			if vim.v.shell_error == 0 then
				if result:match("Already up to date") then
					handle.message = plugin_name .. " is already up to date"
				else
					handle.message = plugin_name .. " updated successfully"
				end
			else
				handle.message = "Failed to update " .. plugin_name
			end
			vim.defer_fn(function() handle:finish() end, 2000)
		end

		if vim.v.shell_error == 0 then
			if result:match("Already up to date") then
				notify(plugin_name .. " is already up to date", vim.log.levels.INFO)
			else
				notify("✓ " .. plugin_name .. " updated successfully", vim.log.levels.INFO)
			end
		else
			notify("✗ Failed to update " .. plugin_name, vim.log.levels.ERROR)
		end
	end, 100)
end

-- Show plugin status
function PluginManager.show_status()
	local plugins = PluginManager.get_installed_plugins()
	local handle = create_progress("Plugin Status", "Analyzing plugins...")

	vim.defer_fn(function()
		local total_plugins = #plugins
		local git_plugins = 0
		local status_lines = {}

		for _, plugin in ipairs(plugins) do
			if plugin.has_git then
				git_plugins = git_plugins + 1

				-- Get git status
				local cmd = { "git", "-C", plugin.path, "status", "--porcelain" }
				local status_result = vim.fn.system(cmd)
				local has_changes = #status_result > 0

				-- Get current commit
				local commit_cmd = { "git", "-C", plugin.path, "rev-parse", "--short", "HEAD" }
				local commit_result = vim.fn.system(commit_cmd)
				local commit = commit_result:gsub("\n", "")

				local status_icon = has_changes and "⚠" or "✓"
				local status_text = has_changes and " (has changes)" or ""
				table.insert(status_lines, string.format("%s %s @%s%s", status_icon, plugin.name, commit, status_text))
			else
				table.insert(status_lines, string.format("⚠ %s (not git)", plugin.name))
			end
		end

		local summary = string.format("Plugin Status: %d total, %d git repos", total_plugins, git_plugins)

		if handle then
			handle.message = summary
			vim.defer_fn(function() handle:finish() end, 2000)
		end

		notify(summary, vim.log.levels.INFO, { timeout = 5000 })

		-- Show detailed status in a floating window
		local buf = vim.api.nvim_create_buf(false, true)
		local width = 60
		local height = math.min(20, #status_lines + 2)

		local lines = { "Plugin Status Details:", "" }
		vim.list_extend(lines, status_lines)

		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

		local win_opts = {
			relative = "editor",
			width = width,
			height = height,
			col = (vim.o.columns - width) / 2,
			row = (vim.o.lines - height) / 2,
			style = "minimal",
			border = "rounded",
		}

		local win = vim.api.nvim_open_win(buf, true, win_opts)

		-- Close window on any key
		vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
		vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":close<CR>", { noremap = true, silent = true })

		-- Auto-close after 10 seconds
		vim.defer_fn(function()
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end, 10000)

	end, 100)
end

-- Clean up orphaned plugins (plugins in pack that aren't in the plugin list)
function PluginManager.cleanup_orphaned()
	local handle = create_progress("Plugin Cleanup", "Checking for orphaned plugins...")

	vim.defer_fn(function()
		local pack_dir = PluginManager.get_plugin_dir()
		local installed = PluginManager.get_installed_plugins()

		-- Get plugins from the global plugins table
		local plugins = _G.neovim_plugins
		if not plugins or type(plugins) ~= "table" then
			notify("Could not access plugin list for cleanup. Plugins table not available.", vim.log.levels.ERROR)
			if handle then handle:finish() end
			return
		end

		local configured_plugins = {}
		for _, plugin in ipairs(plugins) do
			configured_plugins[plugin.name] = true
		end

		local orphaned = {}
		for _, plugin in ipairs(installed) do
			if not configured_plugins[plugin.name] then
				table.insert(orphaned, plugin)
			end
		end

		if #orphaned == 0 then
			if handle then
				handle.message = "No orphaned plugins found"
				vim.defer_fn(function() handle:finish() end, 1000)
			end
			notify("No orphaned plugins found", vim.log.levels.INFO)
			return
		end

		if handle then
			handle.message = string.format("Found %d orphaned plugins", #orphaned)
			vim.defer_fn(function() handle:finish() end, 1000)
		end

		-- Show orphaned plugins
		local message = "Orphaned plugins found:\n"
		for _, plugin in ipairs(orphaned) do
			message = message .. "  - " .. plugin.name .. "\n"
		end
		message = message .. "\nUse :PluginCleanupConfirm to remove them"

		vim.notify(message, vim.log.levels.WARN, { timeout = 10000 })

		-- Store orphaned list for confirmation command
		_G.orphaned_plugins = orphaned

	end, 100)
end

-- Confirm and remove orphaned plugins
function PluginManager.cleanup_confirm()
	if not _G.orphaned_plugins or #_G.orphaned_plugins == 0 then
		notify("No orphaned plugins to clean up", vim.log.levels.INFO)
		return
	end

	local handle = create_progress("Cleaning Plugins", "Removing orphaned plugins...")

	local total = #_G.orphaned_plugins
	local completed = 0
	local failed = {}

	local function cleanup_next(index)
		if index > total then
			if handle then
				local msg = string.format("Cleanup complete! %d/%d removed", completed - #failed, total)
				if #failed > 0 then
					msg = msg .. string.format(" (%d failed)", #failed)
				end
				handle.message = msg
				vim.defer_fn(function() handle:finish() end, 1000)
			end

			if #failed > 0 then
				notify(string.format("Cleanup: %d/%d successful (%d failed)", completed - #failed, total, #failed), vim.log.levels.WARN)
			else
				notify(string.format("Cleanup: %d/%d plugins removed", completed, total), vim.log.levels.INFO)
			end

			_G.orphaned_plugins = nil
			return
		end

		local plugin = _G.orphaned_plugins[index]
		if handle then
			handle.message = string.format("Removing %s (%d/%d)", plugin.name, index, total)
			handle.percentage = ((index - 1) / total) * 100
		end

		-- Remove plugin directory
		local success = vim.fn.delete(plugin.path, "rf") == 0

		if success then
			completed = completed + 1
		else
			table.insert(failed, plugin.name)
		end

		vim.defer_fn(function()
			cleanup_next(index + 1)
		end, 100)
	end

	cleanup_next(1)
end

-- Setup user commands
function PluginManager.setup_commands()
	vim.api.nvim_create_user_command("PluginUpdateAll", function()
		PluginManager.update_all_plugins()
	end, { desc = "Update all Neovim plugins with progress feedback" })

	vim.api.nvim_create_user_command("PluginUpdate", function(opts)
		local plugin_name = opts.args
		if plugin_name == "" then
			notify("Usage: PluginUpdate <plugin-name>", vim.log.levels.ERROR)
			return
		end
		PluginManager.update_plugin(plugin_name)
	end, { nargs = 1, desc = "Update specific plugin" })

	vim.api.nvim_create_user_command("PluginStatus", function()
		PluginManager.show_status()
	end, { desc = "Show plugin status and details" })

	vim.api.nvim_create_user_command("PluginCleanup", function()
		PluginManager.cleanup_orphaned()
	end, { desc = "Check for orphaned plugins" })

	vim.api.nvim_create_user_command("PluginCleanupConfirm", function()
		PluginManager.cleanup_confirm()
	end, { desc = "Confirm and remove orphaned plugins" })
end

-- Initialize the plugin manager
function PluginManager.init()
	PluginManager.setup_commands()
	vim.notify("Enhanced Plugin Manager initialized", vim.log.levels.INFO)
end

return PluginManager
