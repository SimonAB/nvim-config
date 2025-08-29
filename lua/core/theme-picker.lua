-- =============================================================================
-- THEME PICKER
-- PURPOSE: Enhanced theme selection with floating window interface
-- =============================================================================

local ThemePicker = {}
local themes = {}
local current_theme = nil

-- Get available colorschemes from runtime
local function get_available_themes()
	local available = {}

	-- Get built-in colorschemes
	local builtin_themes = {
		"default", "blue", "darkblue", "delek", "desert", "elflord", "evening",
		"habamax", "industry", "koehler", "lunaperche", "morning", "murphy",
		"pablo", "peachpuff", "quiet", "ron", "shine", "slate", "torte", "zellner"
	}

	-- Get colorschemes from runtime paths
	local runtime_paths = vim.api.nvim_list_runtime_paths()
	for _, path in ipairs(runtime_paths) do
		local colors_dir = path .. "/colors"
		if vim.fn.isdirectory(colors_dir) == 1 then
			local files = vim.fn.glob(colors_dir .. "/*.vim", true, true)
			local lua_files = vim.fn.glob(colors_dir .. "/*.lua", true, true)

			for _, file in ipairs(files) do
				local name = vim.fn.fnamemodify(file, ":t:r")
				if not vim.tbl_contains(builtin_themes, name) then
					table.insert(available, name)
				end
			end

			for _, file in ipairs(lua_files) do
				local name = vim.fn.fnamemodify(file, ":t:r")
				if not vim.tbl_contains(builtin_themes, name) then
					table.insert(available, name)
				end
			end
		end
	end

	-- Add builtin themes
	for _, theme in ipairs(builtin_themes) do
		table.insert(available, theme)
	end

	-- Remove duplicates and sort
	local unique = {}
	for _, theme in ipairs(available) do
		unique[theme] = true
	end

	local result = {}
	for theme, _ in pairs(unique) do
		table.insert(result, theme)
	end

	table.sort(result)
	return result
end

-- Enhanced notification system
local function notify(message, level, opts)
	local default_opts = {
		title = "Theme Picker",
		timeout = 2000,
	}
	local final_opts = vim.tbl_extend("force", default_opts, opts or {})
	vim.notify(message, level, final_opts)
end

-- Get theme display info
local function get_theme_info(theme_name)
	local info = {
		name = theme_name,
		display_name = theme_name:gsub("_", " "):gsub("-", " "),
		is_current = theme_name == (vim.g.colors_name or "default"),
		category = "unknown"
	}

	-- Categorize themes
	local categories = {
		-- Dark themes
		dark = { "onedark", "tokyonight", "nord", "github_dark", "dracula", "gruvbox", "solarized", "monokai" },
		-- Light themes
		light = { "github_light", "catppuccin_latte", "solarized_light", "gruvbox_light", "one_light" },
		-- Special themes
		special = { "catppuccin", "tokyonight_night", "tokyonight_day", "tokyonight_moon" }
	}

	for category, theme_list in pairs(categories) do
		for _, theme in ipairs(theme_list) do
			if theme_name:find(theme) then
				info.category = category
				break
			end
		end
		if info.category ~= "unknown" then break end
	end

	return info
end

-- Format theme entry for display
local function format_theme_entry(theme_name)
	local info = get_theme_info(theme_name)
	local icon = info.is_current and "● " or "○ "
	local category_icon = ""

	if info.category == "dark" then
		category_icon = "🌙 "
	elseif info.category == "light" then
		category_icon = "☀️  "
	else
		category_icon = "🎨 "
	end

	return {
		value = theme_name,
		display = icon .. category_icon .. info.display_name,
		ordinal = theme_name,
		info = info
	}
end

-- Create floating window picker
function ThemePicker.show_picker()
	local available_themes = get_available_themes()

	if #available_themes == 0 then
		notify("No themes found!", vim.log.levels.ERROR)
		return
	end

	-- Format themes for telescope
	local theme_entries = {}
	for _, theme in ipairs(available_themes) do
		table.insert(theme_entries, format_theme_entry(theme))
	end

	-- Telescope picker configuration
	local ok, telescope = pcall(require, "telescope")
	if not ok then
		notify("Telescope not available", vim.log.levels.ERROR)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.action_state")
	local entry_display = require("telescope.pickers.entry_display")

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 2 }, -- Selection indicator
			{ width = 2 }, -- Category icon
			{ remaining = true }, -- Theme name
		},
	})

	local function make_display(entry)
		local info = entry.info
		local icon = info.is_current and "●" or "○"
		local category_icon = info.category == "dark" and "🌙" or
		                     info.category == "light" and "☀️" or "🎨"

		return displayer({
			{ icon, "TelescopeResultsIdentifier" },
			{ category_icon },
			{ info.display_name },
		})
	end

	pickers.new({}, {
		prompt_title = "🎨 Select Theme",
		finder = finders.new_table({
			results = theme_entries,
			entry_maker = function(entry)
				return {
					value = entry.value,
					display = make_display,
					ordinal = entry.ordinal,
					info = entry.info,
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = false, -- Disable preview for faster loading
		attach_mappings = function(prompt_bufnr, map)
			-- Preview theme on selection
			local preview_theme = function()
				local selection = action_state.get_selected_entry()
				if selection then
					ThemePicker.preview_theme(selection.value)
				end
			end

			-- Map preview to selection movement
			map("i", "<C-p>", preview_theme)
			map("n", "<C-p>", preview_theme)

			-- Select theme and close
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				if selection then
					ThemePicker.select_theme(selection.value)
				end
				actions.close(prompt_bufnr)
			end)

			-- Quick theme switching without closing
			map("i", "<C-y>", function()
				local selection = action_state.get_selected_entry()
				if selection then
					ThemePicker.select_theme(selection.value)
				end
			end)

			map("n", "<C-y>", function()
				local selection = action_state.get_selected_entry()
				if selection then
					ThemePicker.select_theme(selection.value)
				end
			end)

			return true
		end,
	}):find()
end

-- Preview theme (temporary application)
function ThemePicker.preview_theme(theme_name)
	local ok, err = pcall(vim.cmd.colorscheme, theme_name)
	if not ok then
		notify("Failed to preview theme: " .. theme_name, vim.log.levels.WARN)
	else
		-- Temporarily show theme name
		local info = get_theme_info(theme_name)
		vim.notify("Previewing: " .. info.display_name, vim.log.levels.INFO, { timeout = 1000 })
	end
end

-- Select and apply theme permanently
function ThemePicker.select_theme(theme_name)
	local ok, err = pcall(vim.cmd.colorscheme, theme_name)
	if ok then
		current_theme = theme_name
		local info = get_theme_info(theme_name)
		notify("Theme changed to: " .. info.display_name, vim.log.levels.INFO)

		-- Update theme manager cache
		local ThemeManager = require("core.theme-manager")
		ThemeManager.clear_highlight_cache()
		ThemeManager.update_which_key_highlights()
	else
		notify("Failed to apply theme: " .. theme_name, vim.log.levels.ERROR)
	end
end

-- Get current theme
function ThemePicker.get_current_theme()
	return vim.g.colors_name or "default"
end

-- Cycle through themes (legacy support)
function ThemePicker.cycle_theme()
	local available_themes = get_available_themes()
	if #available_themes == 0 then return end

	local current = ThemePicker.get_current_theme()
	local current_index = 1

	-- Find current theme index
	for i, theme in ipairs(available_themes) do
		if theme == current then
			current_index = i
			break
		end
	end

	-- Move to next theme
	local next_index = current_index % #available_themes + 1
	local next_theme = available_themes[next_index]

	ThemePicker.select_theme(next_theme)
end

-- Initialize theme picker
function ThemePicker.init()
	current_theme = ThemePicker.get_current_theme()
	notify("Theme Picker initialized", vim.log.levels.INFO)
end

return ThemePicker
