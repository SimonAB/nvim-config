-- ============================================================================
-- THEME SETTINGS
-- PURPOSE: Shared helpers for opacity and floating highlight preferences
-- ============================================================================

local ConfigManager = require("core.config-manager")

local ThemeSettings = {
	float_highlights = {
		"NormalFloat",
		"FloatBorder",
		"WhichKeyFloat",
		"WhichKeyBorder",
	},
}

---Return the active theme configuration block.
---@return table
function ThemeSettings.get_active_config()
	return ConfigManager.themes.active or {}
end

---Return the configured opacity value for UI elements.
---@return number opacity
function ThemeSettings.get_opacity()
	local config = ThemeSettings.get_active_config()
	return config.opacity or 1
end

---Convert the configured opacity into a Vim winblend value.
---@return integer winblend
function ThemeSettings.get_winblend()
	local opacity = ThemeSettings.get_opacity()
	local blend = math.floor((1 - opacity) * 100 + 0.5)
	return math.max(0, math.min(100, blend))
end

---Return the list of highlight groups that should stay transparent.
---@return string[]
function ThemeSettings.get_float_highlight_groups()
	return vim.deepcopy(ThemeSettings.float_highlights)
end

---Apply winblend to a specific window, safeguarding against invalid IDs.
---@param winid integer|nil
---@return boolean applied
function ThemeSettings.apply_window_blend(winid)
	if not winid or not vim.api.nvim_win_is_valid(winid) then
		return false
	end
	local ok = pcall(vim.api.nvim_set_option_value, "winblend", ThemeSettings.get_winblend(), { win = winid })
	return ok
end

---Apply window blend to every currently listed window.
function ThemeSettings.apply_all_window_blends()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		ThemeSettings.apply_window_blend(win)
	end
end

---Return the colourscheme name for a given appearance.
---@param appearance "dark"|"light"
---@return string
function ThemeSettings.get_default_theme(appearance)
	if appearance ~= "light" and appearance ~= "dark" then
		appearance = "dark"
	end
	local config = ThemeSettings.get_active_config()
	local defaults = config.defaults or {}
	if appearance == "light" then
		return defaults.light or "github_light_default"
	end
	return defaults.dark or "gruvbox"
end

return ThemeSettings
