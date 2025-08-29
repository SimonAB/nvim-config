-- =============================================================================
-- THEME MANAGER
-- PURPOSE: Centralized theme management with performance optimizations
-- =============================================================================

local ThemeManager = {}
local highlight_cache = {}
local ThemePicker = nil -- Lazy load to avoid circular dependencies

-- Detect system appearance
function ThemeManager.detect_system_theme()
	local ok, result = pcall(vim.fn.system, { "defaults", "read", "-g", "AppleInterfaceStyle" })
	if ok and result then
		return result:match("Dark") and "dark" or "light"
	end
	return "dark" -- fallback
end

-- Get theme for current system appearance
function ThemeManager.get_active_theme()
	local appearance = ThemeManager.detect_system_theme()
	return appearance == "dark" and "onedark" or "catppuccin"
end

-- Load and apply theme immediately (no defer)
function ThemeManager.load_immediate()
	local theme = ThemeManager.get_active_theme()
	local ok = pcall(vim.cmd.colorscheme, theme)
	if not ok then
		vim.notify("Failed to load theme: " .. theme, vim.log.levels.WARN)
	end
	return theme
end

-- Setup lazy theme loading for non-active themes
function ThemeManager.setup_lazy_loading()
	vim.api.nvim_create_autocmd("ColorSchemePre", {
		pattern = { "tokyonight", "nord", "github_*" },
		callback = function(ev)
			local theme_name = ev.match:gsub("-", "_")
			pcall(require, "plugins." .. theme_name)
		end,
	})
end

-- Optimized highlight management with caching
function ThemeManager.update_which_key_highlights()
	local theme = vim.g.colors_name or "default"

	-- Return early if already cached
	if highlight_cache[theme] then
		return
	end

	local highlights = {}

	-- Theme-specific highlight configurations
	if theme:match("catppuccin") then
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "String" },
			WhichKeyFloat = { link = "NormalFloat" },
			WhichKeyBorder = { link = "FloatBorder" },
		}
	elseif theme:match("onedark") then
		highlights = {
			WhichKey = { fg = "#61AFEF" },
			WhichKeyGroup = { fg = "#C678DD" },
			WhichKeyDesc = { fg = "#5C6370" },
			WhichKeySeparator = { fg = "#98C379" },
			WhichKeyFloat = { bg = "#282C34" },
			WhichKeyBorder = { fg = "#3E4451" },
		}
	elseif theme:match("tokyonight") then
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "String" },
			WhichKeyFloat = { link = "NormalFloat" },
			WhichKeyBorder = { link = "FloatBorder" },
		}
	else
		-- Default fallback
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "Delimiter" },
			WhichKeyFloat = { link = "NormalFloat" },
			WhichKeyBorder = { link = "FloatBorder" },
		}
	end

	-- Batch apply all highlights
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Cache the result
	highlight_cache[theme] = true
end

-- Clear highlight cache (useful when reloading config)
function ThemeManager.clear_highlight_cache()
	highlight_cache = {}
end

-- Theme picker integration
function ThemeManager.show_theme_picker()
	if not ThemePicker then
		local ok, picker = pcall(require, "core.theme-picker")
		if not ok then
			vim.notify("Theme Picker not available", vim.log.levels.ERROR)
			return
		end
		ThemePicker = picker
	end

	if ThemePicker.show_picker then
		ThemePicker.show_picker()
	else
		vim.notify("Theme picker show function not available", vim.log.levels.ERROR)
	end
end

-- Cycle through themes (legacy support)
function ThemeManager.cycle_theme()
	if not ThemePicker then
		local ok, picker = pcall(require, "core.theme-picker")
		if ok then
			ThemePicker = picker
		end
	end

	if ThemePicker and ThemePicker.cycle_theme then
		ThemePicker.cycle_theme()
	else
		-- Fallback to original cycling logic
		local themes = { "catppuccin", "onedark", "tokyonight", "nord", "github_dark" }
		local current = vim.g.colors_name or "default"
		local current_index = 1

		for i, theme in ipairs(themes) do
			if theme == current then
				current_index = i
				break
			end
		end

		local next_index = current_index % #themes + 1
		local next_theme = themes[next_index]

		local success = pcall(vim.cmd.colorscheme, next_theme)
		if success then
			vim.notify("Switched to " .. next_theme .. " theme", vim.log.levels.INFO)
		else
			vim.notify("Failed to switch to " .. next_theme .. " theme", vim.log.levels.WARN)
		end
	end
end

-- Get current theme
function ThemeManager.get_current_theme()
	if ThemePicker and ThemePicker.get_current_theme then
		return ThemePicker.get_current_theme()
	end
	return vim.g.colors_name or "default"
end

-- Setup auto-updating highlights when theme changes
function ThemeManager.setup_highlight_autocmd()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = function()
			vim.defer_fn(function()
				ThemeManager.update_which_key_highlights()
			end, 50)
		end,
	})
end

-- Main initialization function
function ThemeManager.init()
	-- Load active theme immediately
	local active_theme = ThemeManager.load_immediate()

	-- Setup lazy loading for other themes
	ThemeManager.setup_lazy_loading()

	-- Setup highlight management
	ThemeManager.setup_highlight_autocmd()
	ThemeManager.update_which_key_highlights()

	vim.notify("Theme system initialized: " .. active_theme, vim.log.levels.INFO)
end

return ThemeManager
