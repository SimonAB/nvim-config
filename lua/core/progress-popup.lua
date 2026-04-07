-- =============================================================================
-- PROGRESS POPUP
-- PURPOSE: Lightweight floating progress UI for long-running operations
-- =============================================================================

local ProgressPopup = {}

local DEFAULT_WIDTH = 72
local DEFAULT_HEIGHT = 18

---Create a centred floating window with a scratch buffer.
---@param title string
---@param opts? table
---@return table popup { bufnr:number, winid:number, title:string, lines:string[] }
function ProgressPopup.create(title, opts)
	opts = opts or {}

	local width = opts.width or DEFAULT_WIDTH
	local height = opts.height or DEFAULT_HEIGHT

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")

	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "rounded",
		title = title,
		title_pos = "center",
	}

	local winid = vim.api.nvim_open_win(bufnr, true, win_opts)

	vim.keymap.set("n", "q", function()
		ProgressPopup.close({ bufnr = bufnr, winid = winid })
	end, { buffer = bufnr, silent = true })
	vim.keymap.set("n", "<Esc>", function()
		ProgressPopup.close({ bufnr = bufnr, winid = winid })
	end, { buffer = bufnr, silent = true })

	local popup = {
		bufnr = bufnr,
		winid = winid,
		title = title,
		lines = {},
	}

	ProgressPopup.set_lines(popup, {
		"",
		"Starting...",
		"",
	})

	return popup
end

---Close an existing popup safely.
---@param popup table
function ProgressPopup.close(popup)
	if not popup then
		return
	end

	if popup.winid and vim.api.nvim_win_is_valid(popup.winid) then
		pcall(vim.api.nvim_win_close, popup.winid, true)
	end
end

---Replace buffer lines safely.
---@param popup table
---@param lines string[]
function ProgressPopup.set_lines(popup, lines)
	if not popup or not popup.bufnr or not vim.api.nvim_buf_is_valid(popup.bufnr) then
		return
	end

	popup.lines = lines

	vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
end

---Append a line to the popup (keeps a rolling window of content).
---@param popup table
---@param line string
function ProgressPopup.append_line(popup, line)
	if not popup then
		return
	end

	local lines = popup.lines or {}
	table.insert(lines, line)

	-- Keep the most recent lines visible within the popup height.
	local ok, win_cfg = pcall(vim.api.nvim_win_get_config, popup.winid)
	local max_lines = DEFAULT_HEIGHT
	if ok and win_cfg and win_cfg.height then
		max_lines = tonumber(win_cfg.height) or max_lines
	end

	if #lines > max_lines then
		lines = { unpack(lines, #lines - max_lines + 1, #lines) }
	end

	ProgressPopup.set_lines(popup, lines)
end

---Create a text progress bar.
---@param current number
---@param total number
---@param width? number
---@return string
function ProgressPopup.progress_bar(current, total, width)
	width = width or 28
	if total <= 0 then
		return "[" .. string.rep(" ", width) .. "]"
	end

	local ratio = math.max(0, math.min(1, current / total))
	local filled = math.floor(ratio * width)
	return "[" .. string.rep("█", filled) .. string.rep(" ", width - filled) .. "]"
end

return ProgressPopup

