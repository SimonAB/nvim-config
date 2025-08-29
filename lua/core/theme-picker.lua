-- =============================================================================
-- THEME PICKER
-- PURPOSE: Enhanced theme selection with floating window interface
-- =============================================================================

local ThemePicker = {}

-- Get available colorschemes from runtime
local function get_themes()
	local themes = {
		"default", "blue", "darkblue", "delek", "desert", "elflord", "evening",
		"habamax", "industry", "koehler", "lunaperche", "morning", "murphy",
		"pablo", "peachpuff", "quiet", "ron", "shine", "slate", "torte", "zellner"
	}

	-- Get colorschemes from runtime paths
	for _, path in ipairs(vim.api.nvim_list_runtime_paths()) do
		local colors_dir = path .. "/colors"
		if vim.fn.isdirectory(colors_dir) == 1 then
			for _, pattern in ipairs({"*.vim", "*.lua"}) do
				for _, file in ipairs(vim.fn.glob(colors_dir .. "/" .. pattern, true, true)) do
					local name = vim.fn.fnamemodify(file, ":t:r")
					if not vim.tbl_contains(themes, name) then
						table.insert(themes, name)
					end
				end
			end
		end
	end

	table.sort(themes)
	return themes
end

-- Create theme entry
local function create_entry(theme)
	local is_current = theme == (vim.g.colors_name or "default")
	local category = theme:find("dark") and "dark" or theme:find("light") and "light" or "special"
	local icon = is_current and "●" or "○"
	local category_icon = category == "dark" and "🌙" or category == "light" and "☀️" or "🎨"

	return {
		value = theme,
		display = string.format("%s %s %s", icon, category_icon, theme:gsub("_", " "):gsub("-", " ")),
		ordinal = theme,
	}
end

-- Load Telescope modules safely
local function load_telescope_modules()
	local modules = {
		pickers = "telescope.pickers",
		finders = "telescope.finders",
		config = "telescope.config",
		actions = "telescope.actions",
		action_state = "telescope.action_state",
		entry_display = "telescope.pickers.entry_display",
		previewers = "telescope.previewers"
	}

	local loaded = {}
	for name, module in pairs(modules) do
		local ok, mod = pcall(require, module)
		if not ok then
			vim.notify("Failed to load " .. module, vim.log.levels.WARN)
			return nil
		end
		loaded[name] = mod
	end

	loaded.config = loaded.config.values
	return loaded
end

-- Notification helper
local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "Theme Picker", timeout = 2000 })
end

-- Create floating window picker
function ThemePicker.show_picker()
	local themes = get_themes()

	if #themes == 0 then
		notify("No themes found!", vim.log.levels.ERROR)
		return
	end

	-- Load Telescope modules
	local mods = load_telescope_modules()
	if not mods then
		notify("Failed to load Telescope modules", vim.log.levels.WARN)
		return
	end

	-- Safely require Telescope modules
	local ok, pickers_mod = pcall(require, "telescope.pickers")
	if not ok then
		notify("Failed to load Telescope pickers, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, finders_mod = pcall(require, "telescope.finders")
	if not ok then
		notify("Failed to load Telescope finders, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, conf_mod = pcall(function() return require("telescope.config").values end)
	if not ok then
		notify("Failed to load Telescope config, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, actions_mod = pcall(require, "telescope.actions")
	if not ok then
		notify("Failed to load Telescope actions, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, action_state_mod = pcall(require, "telescope.action_state")
	if not ok then
		notify("Failed to load Telescope action_state, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, entry_display_mod = pcall(require, "telescope.pickers.entry_display")
	if not ok then
		notify("Failed to load Telescope entry_display, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local ok, previewers_mod = pcall(require, "telescope.previewers")
	if not ok then
		notify("Failed to load Telescope previewers, using fallback", vim.log.levels.WARN)
		ThemePicker.show_fallback_picker(available_themes)
		return
	end

	local displayer = entry_display_mod.create({
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



	-- Create a custom previewer for themes
	local theme_previewer = previewers_mod.new_buffer_previewer({
		title = "Theme Preview",
		dyn_title = function(_, entry)
			return "🎨 " .. (entry.info and entry.info.display_name or entry.value)
		end,

		get_buffer_by_name = function(_, entry)
			return entry.value
		end,

		define_preview = function(self, entry)
			-- Preview the theme by applying it temporarily
			if entry and entry.value then
				ThemePicker.preview_theme(entry.value)
			end

			-- Show theme information in the preview window
			local lines = {
				"🎨 Theme: " .. (entry.info and entry.info.display_name or entry.value),
				"📁 Category: " .. (entry.info and entry.info.category or "unknown"),
				"",
				"💡 This theme is now active in your editor.",
				"   Press <Enter> to keep it permanently,",
				"   or continue browsing other themes.",
				"",
				"🔧 Tips:",
				"   • Use <C-y> to apply without closing",
				"   • Press <Esc> to cancel and revert",
				"   • Type to search/filter themes",
			}

			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
			vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'markdown')
		end,
	})

	-- Create theme entries
	local entries = {}
	for _, theme in ipairs(themes) do
		table.insert(entries, create_entry(theme))
	end

	-- Create picker
	mods.pickers.new({}, {
		prompt_title = "🎨 Select Theme",
		finder = mods.finders.new_table({
			results = entries,
			entry_maker = function(entry)
				return {
					value = entry.value,
					display = make_display,
					ordinal = entry.ordinal,
				}
			end,
		}),
		sorter = mods.config.generic_sorter({}),
		previewer = theme_previewer,

		attach_mappings = function(prompt_bufnr, map)
			-- Quick theme switching without closing
			map("i", "<C-y>", function()
				local selection = mods.action_state.get_selected_entry()
				if selection then
					ThemePicker.select_theme(selection.value)
				end
			end)

			map("n", "<C-y>", function()
				local selection = mods.action_state.get_selected_entry()
				if selection then
					ThemePicker.select_theme(selection.value)
				end
			end)

			-- Numeric prefix navigation
			for i = 1, 9 do
				map("i", tostring(i) .. "j", function()
					mods.actions.move_selection_next(prompt_bufnr)
					for _ = 1, i - 1 do
						mods.actions.move_selection_next(prompt_bufnr)
					end
				end)

				map("n", tostring(i) .. "j", function()
					mods.actions.move_selection_next(prompt_bufnr)
					for _ = 1, i - 1 do
						mods.actions.move_selection_next(prompt_bufnr)
					end
				end)

				map("i", tostring(i) .. "k", function()
					mods.actions.move_selection_previous(prompt_bufnr)
					for _ = 1, i - 1 do
						mods.actions.move_selection_previous(prompt_bufnr)
					end
				end)

				map("n", tostring(i) .. "k", function()
					mods.actions.move_selection_previous(prompt_bufnr)
					for _ = 1, i - 1 do
						mods.actions.move_selection_previous(prompt_bufnr)
					end
				end)
			end

			-- Select theme and close (standard Telescope behavior)
			mods.actions.select_default:replace(function()
				local selection = mods.action_state.get_selected_entry()
				if selection and selection.value then
					ThemePicker.select_theme(selection.value)
				else
					notify("Could not determine selected theme", vim.log.levels.ERROR)
				end
				mods.actions.close(prompt_bufnr)
			end)

			return true
		end,
	}):find()
end

-- Fallback theme picker with scrolling and live preview
function ThemePicker.show_fallback_picker(themes)
	local current_index = 1
	local current_preview_theme = nil

	-- Create theme display entries
	local theme_entries = {}
	for i, theme in ipairs(themes) do
		local info = get_theme_info(theme)
		local entry = {
			index = i,
			theme = theme,
			display = string.format("%s %s %s",
				info.is_current and "●" or "○",
				info.category == "dark" and "🌙" or
				info.category == "light" and "☀️" or "🎨",
				info.display_name
			),
			info = info
		}
		table.insert(theme_entries, entry)
		if info.is_current then
			current_index = i
		end
	end

	-- Create floating window
	local width = 50
	local height = math.min(#theme_entries, 15)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = "🎨 Select Theme (Live Preview)",
		title_pos = "center",
	})

	-- Set buffer content
	local lines = {}
	for _, entry in ipairs(theme_entries) do
		table.insert(lines, entry.display)
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Highlight current selection
	local function update_highlight()
		vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
		vim.api.nvim_buf_add_highlight(buf, -1, "CursorLine", current_index - 1, 0, -1)

		-- Live preview
		local current_entry = theme_entries[current_index]
		if current_entry and current_entry.theme ~= current_preview_theme then
			current_preview_theme = current_entry.theme
			ThemePicker.preview_theme(current_entry.theme)
		end
	end

	-- Set initial highlight
	update_highlight()

	-- Key mappings
	local function close_window()
		-- Close window first
		pcall(vim.api.nvim_win_close, win, true)

		-- Try to delete buffer if it still exists
		local buf_exists = pcall(vim.api.nvim_buf_is_valid, buf)
		if buf_exists then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end

	local function select_current()
		local current_entry = theme_entries[current_index]
		if current_entry then
			ThemePicker.select_theme(current_entry.theme)
		end
		close_window()
	end

	local function move_selection(direction)
		current_index = current_index + direction
		if current_index < 1 then
			current_index = #theme_entries
		elseif current_index > #theme_entries then
			current_index = 1
		end
		update_highlight()

		-- Scroll window if needed
		local first_visible = vim.fn.line('w0', win)
		local last_visible = vim.fn.line('w$', win)

		if current_index < first_visible then
			vim.api.nvim_win_set_cursor(win, {current_index, 0})
		elseif current_index > last_visible then
			local new_top = current_index - (last_visible - first_visible)
			vim.api.nvim_win_set_cursor(win, {new_top, 0})
		end
		vim.api.nvim_win_set_cursor(win, {current_index, 0})
	end

	-- Buffer-local keymaps
	vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
		callback = close_window,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
		callback = select_current,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
		callback = close_window,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', 'j', '', {
		callback = function() move_selection(1) end,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', 'k', '', {
		callback = function() move_selection(-1) end,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', '<Down>', '', {
		callback = function() move_selection(1) end,
		noremap = true,
		silent = true
	})

	vim.api.nvim_buf_set_keymap(buf, 'n', '<Up>', '', {
		callback = function() move_selection(-1) end,
		noremap = true,
		silent = true
	})

	-- Numeric prefix navigation
	for i = 1, 9 do
		vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i) .. 'j', '', {
			callback = function()
				for _ = 1, i do
					move_selection(1)
				end
			end,
			noremap = true,
			silent = true
		})

		vim.api.nvim_buf_set_keymap(buf, 'n', tostring(i) .. 'k', '', {
			callback = function()
				for _ = 1, i do
					move_selection(-1)
				end
			end,
			noremap = true,
			silent = true
		})
	end

	-- Set cursor to current selection
	vim.api.nvim_win_set_cursor(win, {current_index, 0})

	-- Set buffer options
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'wipe' -- Wipe buffer when window closes
end

-- Preview theme (temporary application) with debouncing
local preview_timer = nil
local last_preview_theme = nil

function ThemePicker.preview_theme(theme_name)
	-- Avoid redundant previews
	if theme_name == last_preview_theme then
		return
	end

	-- Clear any pending preview
	if preview_timer then
		vim.loop.timer_stop(preview_timer)
	end

	-- Debounce theme preview to avoid flickering
	preview_timer = vim.defer_fn(function()
		local ok, err = pcall(vim.cmd.colorscheme, theme_name)
		if ok then
			last_preview_theme = theme_name
			-- Only show notification for manual previews, not auto-previews
			local info = get_theme_info(theme_name)
			vim.notify("Previewing: " .. info.display_name, vim.log.levels.INFO, { timeout = 500 })
		else
			notify("Failed to preview theme: " .. theme_name, vim.log.levels.WARN)
		end
		preview_timer = nil
	end, 50) -- 50ms debounce for smooth experience
end

-- Select and apply theme permanently
function ThemePicker.select_theme(theme_name)
	-- Clear any pending preview
	if preview_timer then
		vim.loop.timer_stop(preview_timer)
		preview_timer = nil
	end

	local ok, err = pcall(vim.cmd.colorscheme, theme_name)
	if ok then
		current_theme = theme_name
		last_preview_theme = theme_name -- Update preview state
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
	local available_themes = get_themes()
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
