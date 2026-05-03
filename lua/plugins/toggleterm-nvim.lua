-- Configuration for toggleterm.nvim
-- Terminal management with enhanced features

local ok_ts, ThemeSettings = pcall(require, "core.theme-settings")

---Apply opaque which-key float chrome to the ToggleTerm window when opened as a float.
---@param term table
local function style_float_terminal(term)
	if not ok_ts or not ThemeSettings.style_float_like_which_key then
		return
	end
	if term.direction ~= "float" or not term.window or not vim.api.nvim_win_is_valid(term.window) then
		return
	end
	ThemeSettings.style_float_like_which_key(term.window)
end

local ok, toggleterm = pcall(require, "toggleterm")
if ok then
	toggleterm.setup({
		-- Matches README / docs (`<C-t>` toggles the default ToggleTerm instance).
		open_mapping = [[<c-t>]],
		size = function(term)
			-- Dynamically set terminal size based on direction
			if term.direction == "horizontal" then
				return 15 -- 15 lines for horizontal terminals
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4 -- 40% of editor width for vertical
			end
		end,
		direction = "vertical", -- Default to vertical split
		float_opts = {
			border = "curved", -- Use curved border for floating terminals
		},
		on_open = function(term)
			style_float_terminal(term)
		end,
	})

	-- Terminals that supply their own `on_open` bypass the global hook; restyle on attach.
	local augroup = vim.api.nvim_create_augroup("ToggleTermFloatStyle", { clear = true })
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = augroup,
		desc = "Align floating ToggleTerm with which-key float styling",
		callback = function()
			local win = vim.api.nvim_get_current_win()
			if vim.fn.win_gettype(win) ~= "popup" then
				return
			end
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype ~= "terminal" then
				return
			end
			if ok_ts and ThemeSettings.style_float_like_which_key then
				ThemeSettings.style_float_like_which_key(win)
			end
		end,
	})
end
