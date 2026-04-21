-- =============================================================================
-- THEME MANAGER
-- PURPOSE: Centralized theme management with performance optimizations
-- =============================================================================

local ThemeManager = {}
local highlight_cache = {}
local formatting_cache = {}
local ThemePicker = nil -- Lazy load to avoid circular dependencies
local ThemeSettings = require("core.theme-settings")

---Ensure floating highlight groups stay transparent after theme changes.
local function ensure_transparent_highlights()
	for _, group in ipairs(ThemeSettings.get_float_highlight_groups()) do
		pcall(vim.api.nvim_set_hl, 0, group, { bg = "none" })
	end
end

-- Detect system appearance with caching
local system_theme_cache = nil
local cache_timeout = 5000 -- 5 seconds
local last_detection_time = 0

function ThemeManager.detect_system_theme()
	local current_time = vim.loop.hrtime() / 1000000 -- Convert to milliseconds
	
	-- Return cached result if still valid
	if system_theme_cache and (current_time - last_detection_time) < cache_timeout then
		return system_theme_cache
	end
	
	local ok, result = pcall(vim.fn.system, { "defaults", "read", "-g", "AppleInterfaceStyle" })
	if ok and result then
		system_theme_cache = result:match("Dark") and "dark" or "light"
		last_detection_time = current_time
		return system_theme_cache
	end
	
	system_theme_cache = "dark" -- fallback
	last_detection_time = current_time
	return system_theme_cache
end

-- Apply red squiggly underline only for misspelled words
function ThemeManager.apply_spell_undercurl()
  -- Prefer undercurl when supported; fall back to solid underline (Warp)
  local is_warp = (vim.env.TERM_PROGRAM == "WarpTerminal")
  if is_warp then
    pcall(vim.api.nvim_set_hl, 0, "SpellBad", { underline = true, undercurl = false, fg = "#ff4d4d" })
  else
    pcall(vim.api.nvim_set_hl, 0, "SpellBad", { undercurl = true, sp = "#ff4d4d" })
  end
end

-- Apply formatting parity with Gruvbox (italics/neutral choices)
function ThemeManager.apply_formatting_parity()
  local theme = vim.g.colors_name or "default"

  -- Only apply for GitHub light variants to match Gruvbox formatting
  if not theme:match("^github") then
    return
  end

  if formatting_cache[theme] then
    return
  end

  -- Match Gruvbox defaults:
  -- - Comments: italic
  -- - Strings: not italic
  -- - Operators: not italic
  -- - Folds: italic
  local groups_to_set = {
    { name = "Comment", opts = { italic = true } },
    { name = "@comment", opts = { italic = true } },

    { name = "String", opts = { italic = false } },
    { name = "@string", opts = { italic = false } },

    { name = "Operator", opts = { italic = false } },
    { name = "@operator", opts = { italic = false } },

    { name = "Folded", opts = { italic = true } },
  }

  for _, group in ipairs(groups_to_set) do
    pcall(vim.api.nvim_set_hl, 0, group.name, group.opts)
  end

  formatting_cache[theme] = true
end

--- Extract the link colour from the current colourscheme.
--- Checks treesitter link groups, the standard Underlined group, and common blue groups.
---@return number|string|nil colour The foreground colour for links
local function get_link_colour()
  -- Priority order for extracting link colour:
  -- 1. Treesitter link groups (most semantic)
  -- 2. Standard Underlined group (Vim convention for links)
  -- 3. Common "blue" groups as fallback
  local groups_to_check = {
    "@markup.link.url",      -- Treesitter: URL part of links
    "@markup.link",          -- Treesitter: general link
    "@string.special.url",   -- Treesitter: URLs as special strings
    "@text.uri",             -- Treesitter: older name for URLs
    "Underlined",            -- Standard Vim group for hyperlinks
    "Special",               -- Often blue in many themes
    "Function",              -- Commonly blue
  }
  
  for _, group_name in ipairs(groups_to_check) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group_name, link = false })
    if ok and hl and hl.fg then
      return hl.fg
    end
  end
  
  return nil
end

-- Apply link highlighting (blue and underlined) for markdown links, wiki links, and URLs
-- Note: No caching - this is fast and must re-apply reliably after theme changes
function ThemeManager.apply_link_highlights()
  local link_colour = get_link_colour()
  
  -- Build highlight options: always underline, use theme colour if found
  local hl_opts = { underline = true }
  if link_colour then
    hl_opts.fg = link_colour
    hl_opts.sp = link_colour -- Underline colour matches foreground
  end

  -- Markdown link highlights (traditional vim syntax)
  pcall(vim.api.nvim_set_hl, 0, "markdownLinkText", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "markdownUrl", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "markdownUrlTitle", hl_opts)
  
  -- Wiki link highlight (for Obsidian-style [[links]])
  pcall(vim.api.nvim_set_hl, 0, "markdownWikiLink", hl_opts)
  
  -- Treesitter link highlights (ensures consistency with modern syntax highlighting)
  pcall(vim.api.nvim_set_hl, 0, "@markup.link", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "@markup.link.url", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "@markup.link.label", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "@string.special.url", hl_opts)
  pcall(vim.api.nvim_set_hl, 0, "@text.uri", hl_opts) -- Older treesitter name
end

---Apply LaTeX lua-ul [soul] style highlights (\st, \hl) for OpenType-friendly display.
---Strikethrough uses gui=strikethrough; highlight uses underline + optional bg (like link styling).
function ThemeManager.apply_tex_style_highlights()
  -- Strikethrough: \st{}, \sout{} — visible in all fonts
  pcall(vim.api.nvim_set_hl, 0, "texStyleStrike", {
    strikethrough = true,
  })

  -- Highlight: \hl{} — underline for OpenType visibility; bg from Search if available
  local hl_opts = { underline = true }
  local ok, search_hl = pcall(vim.api.nvim_get_hl, 0, { name = "Search", link = false })
  if ok and search_hl and search_hl.bg then
    hl_opts.bg = search_hl.bg
  end
  pcall(vim.api.nvim_set_hl, 0, "texStyleHl", hl_opts)
end

---Apply the configured UI opacity across Neovim.
---Note: Blur effects are handled by the terminal emulator/window manager when transparency is enabled.
---On macOS, the window manager automatically applies blur to transparent windows.
function ThemeManager.apply_global_opacity()
	local blend = ThemeSettings.get_winblend()
	vim.o.winblend = blend  -- Transparency for floating windows (enables blur if terminal supports it)
	vim.o.pumblend = blend  -- Transparency for popup menus/completion (enables blur if terminal supports it)
	ensure_transparent_highlights()
	ThemeSettings.apply_all_window_blends()
end

-- Get theme for current system appearance (sync `background`; theme may map flavours per background).
function ThemeManager.get_active_theme()
	local appearance = ThemeManager.detect_system_theme()
	vim.o.background = appearance
	return ThemeSettings.get_default_theme(appearance)
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
			-- GitHub theme exposes many `github_*` colourschemes but shares one setup module.
			if ev.match:match("^github_") then
				pcall(require, "plugins.github-nvim-theme")
				return
			end

			local theme_name = ev.match:gsub("-", "_")
			pcall(require, "plugins." .. theme_name)
		end,
	})
end

-- Optimized highlight management with caching
function ThemeManager.update_which_key_highlights()
	local theme = vim.g.colors_name or "default"
	local background = vim.o.background or "dark"
	local cache_key = theme .. "|" .. background

	-- Return early if already cached
	if highlight_cache[cache_key] then
		return
	end

	local highlights = {}

	---Convert an integer highlight colour to hex (e.g. 0xff00ff -> "#ff00ff").
	---@param colour integer|string|nil
	---@return string|nil
	local function colour_to_hex(colour)
		if type(colour) ~= "number" then
			return nil
		end
		return string.format("#%06x", colour)
	end

	---Return a background colour from the active theme, preferring float groups.
	---@return string|nil
	local function get_theme_float_bg()
		local groups_to_try = { "NormalFloat", "Pmenu", "Normal" }
		for _, group in ipairs(groups_to_try) do
			local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
			if ok and hl and hl.bg then
				return colour_to_hex(hl.bg)
			end
		end
		return nil
	end

	local which_key_bg = get_theme_float_bg() or ((background == "light") and "#f0f0f0" or "#2b2f3a")
	local which_key_border = (background == "light") and "#c0c0c0" or "#4b5263"

	-- If the theme keeps FloatBorder background unset/transparent, the border can look like it has a
	-- different background from an opaque which-key window. Setting a bg only when missing keeps
	-- theme-provided borders intact while ensuring visual continuity.
	local ok_border, float_border_hl = pcall(vim.api.nvim_get_hl, 0, { name = "FloatBorder", link = false })
	if ok_border and float_border_hl and float_border_hl.bg == nil then
		pcall(vim.api.nvim_set_hl, 0, "FloatBorder", { bg = which_key_bg })
	end
	
	-- Match the float title background to the popup background so the centred hint/title doesn't
	-- appear as a separate "pill" on top of the border.
	local ok_title, float_title_hl = pcall(vim.api.nvim_get_hl, 0, { name = "FloatTitle", link = false })
	local which_key_title_fg = nil
	local which_key_title_bold = true
	if ok_title and float_title_hl then
		if float_title_hl.fg then
			which_key_title_fg = colour_to_hex(float_title_hl.fg)
		end
		if float_title_hl.bold ~= nil then
			which_key_title_bold = float_title_hl.bold
		end
	end
	vim.api.nvim_set_hl(0, "WhichKeyTitle", {
		fg = which_key_title_fg or which_key_border,
		bg = which_key_bg,
		bold = which_key_title_bold,
	})

	-- Theme-specific highlight configurations
	if theme:match("catppuccin") then
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "String" },
			WhichKeyFloat = { bg = which_key_bg },
			WhichKeyBorder = { fg = which_key_border, bg = which_key_bg },
		}
	elseif theme:match("onedark") then
		highlights = {
			WhichKey = { fg = "#61AFEF" },
			WhichKeyGroup = { fg = "#C678DD" },
			WhichKeyDesc = { fg = "#5C6370" },
			WhichKeySeparator = { fg = "#98C379" },
			WhichKeyFloat = { bg = which_key_bg },
			WhichKeyBorder = { fg = which_key_border, bg = which_key_bg },
		}
	elseif theme:match("tokyonight") then
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "String" },
			WhichKeyFloat = { bg = which_key_bg },
			WhichKeyBorder = { fg = which_key_border, bg = which_key_bg },
		}
	else
		-- Default fallback
		highlights = {
			WhichKey = { link = "Function" },
			WhichKeyGroup = { link = "Keyword" },
			WhichKeyDesc = { link = "Comment" },
			WhichKeySeparator = { link = "Delimiter" },
			WhichKeyFloat = { bg = which_key_bg },
			WhichKeyBorder = { fg = which_key_border, bg = which_key_bg },
		}
	end

	-- Batch apply all highlights
	for group, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, group, opts)
	end

	-- Cache the result
	highlight_cache[cache_key] = true
end

-- Clear highlight cache (useful when reloading config)
function ThemeManager.clear_highlight_cache()
	highlight_cache = {}
  formatting_cache = {}
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
		local themes = { "catppuccin", "onedark", "tokyonight", "nord", "github_dark", "github_light_high_contrast" }
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
  local group = vim.api.nvim_create_augroup("ThemeManagerHighlights", { clear = true })
  
  -- Helper to apply all highlight customisations
  local function apply_all_highlights()
    ThemeManager.update_which_key_highlights()
    ThemeManager.apply_formatting_parity()
    ThemeManager.apply_spell_undercurl()
    ThemeManager.apply_link_highlights()
    ThemeManager.apply_tex_style_highlights()
    ThemeManager.apply_global_opacity()
  end
  
  -- Primary trigger: ColorScheme change
  -- Use multiple deferred calls to ensure we run after treesitter and other plugins
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = group,
    callback = function()
      -- First pass: quick application
      vim.defer_fn(apply_all_highlights, 10)
      -- Second pass: catch any plugins that apply highlights after us
      vim.defer_fn(apply_all_highlights, 100)
      -- Final pass: ensure everything is correct after all deferred operations
      vim.defer_fn(apply_all_highlights, 300)
    end,
  })
  
  -- Secondary trigger: when background option changes (auto-dark-mode sets this first)
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    callback = function()
      vim.defer_fn(apply_all_highlights, 150)
    end,
  })
  
  -- Tertiary trigger: re-apply when entering markdown buffers
  -- This catches cases where treesitter re-highlights the buffer
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "markdown", "quarto", "pandoc" },
    callback = function()
      vim.defer_fn(ThemeManager.apply_link_highlights, 50)
    end,
  })
end

---Keep opacity synced when new windows appear.
function ThemeManager.setup_opacity_autocmds()
	local group = vim.api.nvim_create_augroup("ThemeManagerOpacity", { clear = true })
	vim.api.nvim_create_autocmd({ "WinNew", "WinEnter", "BufWinEnter", "TermOpen" }, {
		group = group,
		callback = function(event)
			if event and event.win and vim.api.nvim_win_is_valid(event.win) then
				ThemeSettings.apply_window_blend(event.win)
			else
				ThemeSettings.apply_all_window_blends()
			end
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
  ThemeManager.setup_opacity_autocmds()
	ThemeManager.update_which_key_highlights()
  ThemeManager.apply_formatting_parity()
  ThemeManager.apply_spell_undercurl()
  ThemeManager.apply_link_highlights()
  ThemeManager.apply_tex_style_highlights()
  ThemeManager.apply_global_opacity()

	vim.notify("Theme system initialized: " .. active_theme, vim.log.levels.INFO)
end

return ThemeManager
