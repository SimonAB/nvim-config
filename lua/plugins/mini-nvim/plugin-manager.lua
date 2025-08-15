-- =============================================================================
-- MINI.NVIM PLUGIN MANAGER
-- PURPOSE: Plugin management functionality for mini.nvim dashboard
-- =============================================================================

local config = require("plugins.mini-nvim.config")
local utils = require("plugins.mini-nvim.utils")

local M = {}

-- Update all installed plugins
function M.update_plugins()
	utils.show_progress("Updating plugins...")

	vim.defer_fn(function()
		local updated_count = 0
		local errors = {}
		local pack_path = utils.get_plugin_directory()
		local plugin_dirs = vim.fn.glob(pack_path .. "/*", false, true)

		for i, dir in ipairs(plugin_dirs) do
			if utils.is_directory_accessible(dir) then
				local plugin_name = utils.get_basename(dir)

				if utils.is_directory_accessible(dir .. "/.git") then
					utils.show_progress("Updating " .. plugin_name .. " (" .. i .. "/" .. #plugin_dirs .. ")")

					local result, error_code = utils.execute_system_command({ "git", "-C", dir, "pull", "--ff-only" })
					if error_code == 0 then
						updated_count = updated_count + 1
						utils.show_success("Updated " .. plugin_name)
					else
						table.insert(errors, plugin_name .. ": " .. result)
						utils.show_error("Failed to update " .. plugin_name)
					end
				else
					utils.show_warning("Skipping " .. plugin_name .. " (not a git repo)")
				end
			end
		end

		local message = "Plugin update complete! Updated " .. tostring(updated_count) .. " plugins"
		if #errors > 0 then
			message = message .. " (with " .. #errors .. " errors)"
		end
		utils.show_success(message)
	end, config.DASHBOARD.PLUGIN_UPDATE_DELAY)
end

-- Install plugins using the plugin configuration
function M.install_plugins()
	utils.show_progress("Installing plugins...")

	vim.defer_fn(function()
		local installed_count = 0
		local errors = {}
		local config_path = utils.get_config_directory()

		local result, error_code = utils.execute_system_command({
			"nvim", "--headless",
			"-c", "luafile " .. config_path .. "/lua/plugins.lua",
			"-c", "qa!"
		})

		if error_code == 0 then
			installed_count = 1
		else
			table.insert(errors, "Installation failed: " .. result)
		end

		local message = "Plugin installation complete! Installed " .. tostring(installed_count) .. " plugins"
		if #errors > 0 then
			message = message .. " (with " .. #errors .. " errors)"
		end
		utils.show_success(message)
	end, config.DASHBOARD.PLUGIN_UPDATE_DELAY)
end

-- Check the status of all installed plugins
function M.check_status()
	utils.show_progress("Checking plugin status...")

	vim.defer_fn(function()
		local total_plugins = 0
		local git_count = 0
		local status_info = {}
		local start_path = utils.get_plugin_directory()

		vim.fn.mkdir(start_path, "p")
		local plugin_dirs = vim.fn.glob(start_path .. "/*", false, true)

		for _, dir in ipairs(plugin_dirs) do
			if utils.is_directory_accessible(dir) then
				local plugin_name = utils.get_basename(dir)
				total_plugins = total_plugins + 1

				if utils.is_directory_accessible(dir .. "/.git") then
					git_count = git_count + 1
					local branch = utils.execute_system_command({ "git", "-C", dir, "branch", "--show-current" })
					local commit = utils.execute_system_command({ "git", "-C", dir, "rev-parse", "--short", "HEAD" })
					branch = branch:gsub("%s+", "")
					commit = commit:gsub("%s+", "")
					table.insert(status_info, "✓ " .. plugin_name .. " [" .. branch .. "@" .. commit .. "]")
				else
					table.insert(status_info, "⚠ " .. plugin_name .. " (not git)")
				end
			end
		end

		local message = "Plugin Status: " .. total_plugins .. " plugins, " .. git_count .. " git repos"
		utils.show_message(message)

		for _, info in ipairs(status_info) do
			utils.show_message(info)
		end
	end, config.DASHBOARD.PLUGIN_UPDATE_DELAY)
end

return M
