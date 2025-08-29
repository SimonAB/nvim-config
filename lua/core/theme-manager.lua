-- =============================================================================
-- THEME MANAGER
-- PURPOSE: Centralized theme management with performance optimizations
-- =============================================================================

local ThemeManager = {}
local highlight_cache = {}

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
