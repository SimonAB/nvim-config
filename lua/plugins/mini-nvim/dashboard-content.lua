-- =============================================================================
-- MINI.NVIM DASHBOARD CONTENT
-- PURPOSE: Dashboard content generation for mini.nvim
-- =============================================================================

local config = require("plugins.mini-nvim.config")
local utils = require("plugins.mini-nvim.utils")
local plugin_manager = require("plugins.mini-nvim.plugin-manager")

local M = {}

-- Get recent projects from oldfiles
function M.get_recent_projects(limit)
	local dirs, order = {}, {}
	local oldfiles = vim.v.oldfiles or {}

	for _, f in ipairs(oldfiles) do
		if type(f) == "string" and #f > 0 then
			local abs = utils.get_absolute_path(f)
			if abs ~= "" and utils.is_file_accessible(abs) then
				local dir = utils.get_dirname(abs)
				if dir and dir ~= "" and dirs[dir] == nil and utils.is_file_accessible(dir) then
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

-- Get recent files from oldfiles
function M.get_recent_files(limit)
	local files, order = {}, {}
	local oldfiles = vim.v.oldfiles or {}

	for _, f in ipairs(oldfiles) do
		if type(f) == "string" and #f > 0 then
			local abs = utils.get_absolute_path(f)
			if abs ~= "" and utils.is_file_accessible(abs) and files[abs] == nil then
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

-- Create shortcuts section
function M.create_shortcuts()
	local cfg_path = utils.get_config_directory()

	return {
		{
			name = "Update plugins",
			action = plugin_manager.update_plugins,
			section = "Shortcuts",
		},
		{
			name = "Explore files",
			action = "NvimTreeToggle",
			section = "Shortcuts"
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
			action = string.format("lua require('telescope.builtin').find_files({ cwd = [[%s]] })", cfg_path),
			section = "Shortcuts",
		},
		{
			name = "Quit",
			action = "q",
			section = "Shortcuts",
		},
	}
end

-- Create projects section
function M.create_projects()
	local projects = {}
	local idx = 1

	for _, dir in ipairs(M.get_recent_projects(config.DASHBOARD.MAX_PROJECTS)) do
		local label = string.format("%d. ", idx)
		local name = label .. " " .. utils.get_basename(dir)
		local action = string.format("lua require('telescope.builtin').find_files({ cwd = [[%s]] })", dir)
		table.insert(projects, { name = name, action = action, section = "Projects" })
		idx = idx + 1
	end

	return projects
end

-- Create recent files section
function M.create_recent_files()
	local recent_files = {}

	for i, file in ipairs(M.get_recent_files(config.DASHBOARD.MAX_RECENT_FILES)) do
		local key = config.DASHBOARD.RECENT_FILE_KEYS[i]
		local label = string.format("%s. ", key)
		local name = label .. " " .. utils.get_basename(file)
		local action = "edit " .. utils.escape_filename(file)
		table.insert(recent_files, { name = name, action = action, section = "Recent files" })
	end

	return recent_files
end

-- Create all dashboard items
function M.create_all_items()
	local items = {}

	-- Add shortcuts
	for _, item in ipairs(M.create_shortcuts()) do
		table.insert(items, item)
	end

	-- Add projects
	for _, item in ipairs(M.create_projects()) do
		table.insert(items, item)
	end

	-- Add recent files
	for _, item in ipairs(M.create_recent_files()) do
		table.insert(items, item)
	end

	return items
end

return M
